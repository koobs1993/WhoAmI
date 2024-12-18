import Foundation
import Supabase

public class ChatService {
    public let supabase: SupabaseClient
    private let openAIService: OpenAIService
    private var channel: RealtimeChannel?
    private var messageHandler: ((ChatMessage) -> Void)?
    
    public init(supabase: SupabaseClient) {
        self.supabase = supabase
        self.openAIService = OpenAIService()
    }
    
    public func connect() async throws {
        channel = supabase.realtime
            .channel("chat")
            .on("INSERT", filter: ChannelFilter(event: "chatmessages", schema: "public")) { [weak self] message in
                let payload = message.payload
                if let data = try? JSONSerialization.data(withJSONObject: payload),
                   let chatMessage = try? JSONDecoder().decode(ChatMessage.self, from: data) {
                    self?.messageHandler?(chatMessage)
                }
            }
        
        if let channel = channel {
            try await channel.subscribe()
        } else {
            throw ChatError.channelInitializationFailed
        }
    }
    
    public func subscribe(onMessage: @escaping (ChatMessage) -> Void) {
        self.messageHandler = onMessage
    }
    
    public func sendMessage(_ content: String, sessionId: UUID, userId: UUID) async throws {
        // Save user message
        let userMessage = ChatMessage(
            sessionId: sessionId,
            content: content,
            role: .user,
            userId: userId
        )
        
        try await supabase.database
            .from("chatmessages")
            .insert(userMessage)
            .execute()
        
        // Get AI response
        let systemPrompt = """
        You are a psychology-focused AI assistant. Your responses should be empathetic, \
        thoughtful, and based on psychological principles. Engage with users in a warm, \
        conversational manner while maintaining professional boundaries. Draw from various \
        psychological theories and therapeutic approaches when appropriate, but communicate \
        in an accessible way. Remember to:
        1. Show empathy and active listening
        2. Ask clarifying questions when needed
        3. Provide insights based on psychological concepts
        4. Maintain a supportive and non-judgmental tone
        5. Encourage self-reflection and growth
        Note: Always clarify that you are an AI assistant and not a replacement for \
        professional mental health care when discussing sensitive topics.
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
        
        try await supabase.database
            .from("chatmessages")
            .insert(aiMessage)
            .execute()
    }
    
    public func disconnect() {
        channel?.unsubscribe()
        channel = nil
        messageHandler = nil
    }
    
    public func fetchMessages(sessionId: UUID) async throws -> [ChatMessage] {
        let response: PostgrestResponse<[ChatMessage]> = try await supabase.database
            .from("chatmessages")
            .select()
            .eq("session_id", value: sessionId.uuidString)
            .order("created_at")
            .execute()
        
        return response.value
    }
}

enum ChatError: Error {
    case channelInitializationFailed
}
