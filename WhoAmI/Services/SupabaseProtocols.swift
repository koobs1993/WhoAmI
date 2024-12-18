import Foundation
import Supabase

protocol SupabaseProtocol {
    var database: PostgrestClient { get }
    var realtime: RealtimeClient { get }
    func updateChatSession(_ session: ChatSession) async throws
    func saveChatMessage(_ message: WhoAmI.ChatMessage) async throws
    func subscribeToMessages(sessionId: UUID, onMessage: @escaping (WhoAmI.ChatMessage) -> Void) async -> RealtimeChannel?
    func updateProfile(_ profile: UserProfile) async throws
}

extension SupabaseClient: SupabaseProtocol {
    func updateChatSession(_ session: ChatSession) async throws {
        let update = [
            "title": session.title,
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        try await database
            .from("chat_sessions")
            .update(update)
            .eq("id", value: session.id.uuidString)
            .execute()
    }
    
    func saveChatMessage(_ message: WhoAmI.ChatMessage) async throws {
        struct ChatMessageRecord: Codable {
            let sessionId: UUID
            let userId: UUID?
            let role: String
            let content: String
            let metadata: [String: String]?
            
            init(from message: WhoAmI.ChatMessage) {
                self.sessionId = message.sessionId
                self.userId = nil // Set based on your requirements
                self.role = message.role.rawValue
                self.content = message.content
                self.metadata = nil // Set based on your requirements
            }
        }
        
        let record = ChatMessageRecord(from: message)
        
        try await database
            .from("chat_messages")
            .insert(record)
            .execute()
    }
    
    func subscribeToMessages(sessionId: UUID, onMessage: @escaping (WhoAmI.ChatMessage) -> Void) async -> RealtimeChannel? {
        let channel = realtime.channel("chat_messages:\(sessionId.uuidString)")
        
        channel.on("postgres_changes", filter: .init(event: "*", schema: "public", table: "chat_messages")) { message in
            let payload = message.payload
            guard let data = try? JSONSerialization.data(withJSONObject: payload),
                  let chatMessage = try? JSONDecoder().decode(WhoAmI.ChatMessage.self, from: data) else {
                return
            }
            onMessage(chatMessage)
        }
        
        channel.subscribe()
        return channel
    }
    
    func updateProfile(_ profile: UserProfile) async throws {
        struct ProfileUpdate: Codable {
            let email: String
            let firstName: String
            let lastName: String
            let avatarUrl: String?
            let updatedAt: String
            
            init(from profile: UserProfile) {
                self.email = profile.email
                self.firstName = profile.firstName
                self.lastName = profile.lastName
                self.avatarUrl = profile.avatarUrl
                self.updatedAt = ISO8601DateFormatter().string(from: Date())
            }
        }
        
        let update = ProfileUpdate(from: profile)
        
        try await database
            .from("profiles")
            .update(update)
            .eq("id", value: profile.id.uuidString)
            .execute()
    }
} 