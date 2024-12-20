// import Foundation
// import Supabase
// import Realtime

/*
public class ChatService {
    public let supabase: SupabaseClient
    private let openAIService: OpenAIService
    private var channel: RealtimeChannelV2?
    private var messageHandler: ((ChatMessage) -> Void)?
    
    public init(supabase: SupabaseClient) {
        self.supabase = supabase
        self.openAIService = OpenAIService()
    }
    
    public func connect(sessionId: UUID) async throws {
        channel = supabase.realtimeV2
            .channel("chat_messages")
            .onPostgresChanges(
                event: "INSERT",
                schema: "public",
                table: "chat_messages",
                filter: "session_id=eq.\(sessionId.uuidString)"
            ) { [weak self] payload in
                guard let change = payload as? [String: Any],
                      let record = change["new"] as? [String: Any],
                      let self = self,
                      let data = try? JSONSerialization.data(withJSONObject: record),
                      let chatMessage = try? JSONDecoder().decode(ChatMessage.self, from: data) else {
                    return
                }
                self.messageHandler?(chatMessage)
            }
        
        try await channel?.subscribe()
        
        if channel == nil {
            throw ChatError.channelInitializationFailed
        }
    }
    
    public func subscribe(onMessage: @escaping (ChatMessage) -> Void) {
        self.messageHandler = onMessage
    }
    
    public func createSession(userId: UUID, title: String? = nil) async throws -> ChatSession {
        let session = ChatSession(userId: userId, title: title)
        
        let sessionData: [String: String] = [
            "id": session.id.uuidString,
            "user_id": session.userId.uuidString,
            "title": title ?? "",
            "created_at": ISO8601DateFormatter().string(from: session.createdAt ?? Date()),
            "updated_at": ISO8601DateFormatter().string(from: session.updatedAt ?? Date())
        ]
        
        try await supabase
            .from("chat_sessions")
            .insert(sessionData)
            .execute()
        
        return session
    }
    
    public func sendMessage(_ content: String, sessionId: UUID, userId: UUID) async throws {
        // Verify session exists
        let sessionResponse: PostgrestResponse<[ChatSession], [String: AnyObject]> = try await supabase
            .from("chat_sessions")
            .select()
            .eq("id", value: sessionId.uuidString)
            .execute()
        
        guard !sessionResponse.value.isEmpty else {
            throw ChatError.sessionNotFound
        }
        
        // Save user message
        let userMessage = ChatMessage(
            sessionId: sessionId,
            content: content,
            role: .user,
            userId: userId
        )
        
        let userMessageData: [String: String] = [
            "id": userMessage.id.uuidString,
            "session_id": userMessage.sessionId.uuidString,
            "content": userMessage.content,
            "role": userMessage.role.rawValue,
            "user_id": userId.uuidString,
            "created_at": ISO8601DateFormatter().string(from: userMessage.createdAt ?? Date()),
            "updated_at": ISO8601DateFormatter().string(from: userMessage.updatedAt ?? Date())
        ]
        
        try await supabase
            .from("chat_messages")
            .insert(userMessageData)
            .execute()
        
        // Get AI response
        let systemPrompt = """
        You are the AI assistant for Psychology (WhoAmI), an app dedicated to helping users understand \
        themselves better through psychological insights and self-discovery. Your role is to:

        1. Guide users on their journey of self-discovery and personal growth
        2. Provide insights based on established psychological theories and research
        3. Help users understand their thoughts, emotions, and behaviors
        4. Encourage reflection and self-awareness
        5. Maintain a supportive, empathetic, yet professional tone
        6. Use accessible language while accurately representing psychological concepts
        7. Connect insights to the app's features (tests, courses, and character analysis)

        Important: Always clarify that you are part of the Psychology (WhoAmI) app experience and not \
        a replacement for professional mental health care. When appropriate, encourage users to explore \
        the app's psychological tests and courses for deeper insights.
        """
        
        let messages = try await fetchMessages(sessionId: sessionId)
        let aiResponse = try await openAIService.generateResponse(
            userMessage: content,
            chatHistory: messages,
            systemPrompt: systemPrompt
        )
        
        // Save AI response
        let aiMessage = ChatMessage(
            sessionId: sessionId,
            content: aiResponse,
            role: .assistant,
            userId: nil
        )
        
        let aiMessageData: [String: String] = [
            "id": aiMessage.id.uuidString,
            "session_id": aiMessage.sessionId.uuidString,
            "content": aiMessage.content,
            "role": aiMessage.role.rawValue,
            "created_at": ISO8601DateFormatter().string(from: aiMessage.createdAt ?? Date()),
            "updated_at": ISO8601DateFormatter().string(from: aiMessage.updatedAt ?? Date())
        ]
        
        try await supabase
            .from("chat_messages")
            .insert(aiMessageData)
            .execute()
    }
    
    public func disconnect() async {
        await channel?.unsubscribe()
        channel = nil
        messageHandler = nil
    }
    
    public func fetchMessages(sessionId: UUID) async throws -> [ChatMessage] {
        let response: PostgrestResponse<[ChatMessage], [String: AnyObject]> = try await supabase
            .from("chat_messages")
            .select()
            .eq("session_id", value: sessionId.uuidString)
            .order("created_at")
            .execute()
        
        return response.value
    }
    
    public func fetchSessions(userId: UUID) async throws -> [ChatSession] {
        let response: PostgrestResponse<[ChatSession], [String: AnyObject]> = try await supabase
            .from("chat_sessions")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
        
        return response.value
    }
    
    public func clearMessages(sessionId: UUID) async throws {
        // Delete all messages for the session
        try await supabase
            .from("chat_messages")
            .delete()
            .eq("session_id", value: sessionId.uuidString)
            .execute()
        
        // Update session's updated_at timestamp
        try await supabase
            .from("chat_sessions")
            .update([
                "updated_at": ISO8601DateFormatter().string(from: Date())
            ])
            .eq("id", value: sessionId.uuidString)
            .execute()
    }
}

enum ChatError: Error {
    case channelInitializationFailed
    case sessionNotFound
}
*/
