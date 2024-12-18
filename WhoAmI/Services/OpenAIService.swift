import Foundation

class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4"
    
    init() {
        // In production, this should be securely stored and accessed
        self.apiKey = Config.openAIAPIKey
    }
    
    func generateResponse(
        userMessage: String,
        chatHistory: [ChatMessage],
        systemPrompt: String
    ) async throws -> String {
        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        // Add chat history
        for message in chatHistory {
            messages.append([
                "role": message.role.rawValue,
                "content": message.content
            ])
        }
        
        // Add current user message
        messages.append([
            "role": "user",
            "content": userMessage
        ])
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 1000,
            "top_p": 1,
            "frequency_penalty": 0,
            "presence_penalty": 0
        ]
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                throw OpenAIError.apiError(errorResponse.error.message)
            }
            throw OpenAIError.httpError(httpResponse.statusCode)
        }
        
        let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let message = result.choices.first?.message.content else {
            throw OpenAIError.noResponse
        }
        
        return message
    }
}

// MARK: - Error Types
enum OpenAIError: Error {
    case invalidResponse
    case noResponse
    case apiError(String)
    case httpError(Int)
}

// MARK: - Response Types
struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let content: String
        }
    }
}

struct OpenAIErrorResponse: Codable {
    let error: ErrorDetail
    
    struct ErrorDetail: Codable {
        let message: String
    }
}
