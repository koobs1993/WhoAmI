import Foundation
import Supabase

enum TestError: Error {
    case invalidTest
    case invalidQuestion
    case invalidResponse
    case networkError
    case databaseError
}

@MainActor
class TestViewModel: ObservableObject {
    @Published var test: PsychTest?
    @Published var currentQuestionIndex = 0
    @Published var responses: [String: String] = [:]
    @Published var isLoading = false
    @Published var error: Error?
    @Published var progress: Double = 0.0
    @Published var isComplete = false
    @Published var score: Int?
    
    private let supabase: SupabaseClient
    private let userId: UUID
    private let testId: UUID
    
    init(supabase: SupabaseClient, userId: UUID, testId: UUID) {
        self.supabase = supabase
        self.userId = userId
        self.testId = testId
    }
    
    var currentQuestion: PsychTest.TestQuestion? {
        guard let test = test,
              currentQuestionIndex < test.questions.count else {
            return nil
        }
        return test.questions[currentQuestionIndex]
    }
    
    func loadTest() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: PostgrestResponse<PsychTest> = try await supabase.database
                .from("psychtests")
                .select("""
                    id,
                    title,
                    short_description,
                    category,
                    image_url,
                    duration_minutes,
                    is_active,
                    questions (
                        uuid,
                        id,
                        text,
                        type,
                        required,
                        options,
                        correct_answer,
                        points
                    ),
                    benefits (
                        id,
                        title,
                        description
                    ),
                    created_at,
                    updated_at
                """)
                .eq("id", value: testId)
                .single()
                .execute()
            
            test = response.value
            updateProgress()
        } catch {
            self.error = error
            throw error
        }
    }
    
    func submitResponse(_ response: String) async throws {
        guard let question = currentQuestion else {
            throw TestError.invalidQuestion
        }
        
        responses[question.id.uuidString] = response
        updateProgress()
        
        if currentQuestionIndex + 1 < (test?.questions.count ?? 0) {
            currentQuestionIndex += 1
        } else {
            try await completeTest()
        }
    }
    
    private func completeTest() async throws {
        guard test != nil else {
            throw TestError.invalidTest
        }
        
        let totalPoints = calculateScore()
        score = totalPoints
        isComplete = true
        
        // Save progress
        try await supabase.database
            .from("testprogress")
            .upsert([
                "id": UUID().uuidString,
                "user_id": userId.uuidString,
                "test_id": testId.uuidString,
                "status": TestStatus.completed.rawValue,
                "score": String(totalPoints),
                "last_updated": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()
        
        // Save detailed results
        try await saveTestResults(totalPoints)
    }
    
    private func calculateScore() -> Int {
        guard let test = test else { return 0 }
        
        return test.questions.reduce(0) { total, question in
            guard let response = responses[question.id.uuidString],
                  let correctAnswer = question.correctAnswer,
                  Int(response) == correctAnswer else {
                return total
            }
            return total + (question.points)
        }
    }
    
    private func saveTestResults(_ totalPoints: Int) async throws {
        let data: [String: String] = [
            "id": UUID().uuidString,
            "user_id": userId.uuidString,
            "test_id": testId.uuidString,
            "score": String(totalPoints),
            "answers": try encodeToJsonString(responses),
            "completed_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        try await supabase.database
            .from("test_results")
            .insert(data)
            .execute()
    }
    
    private func updateProgress() {
        guard let test = test else { return }
        progress = Double(responses.count) / Double(test.questions.count)
    }
    
    private func encodeToJsonString<T: Encodable>(_ value: T) throws -> String {
        let data = try JSONEncoder().encode(value)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw TestError.invalidResponse
        }
        return jsonString
    }
}
