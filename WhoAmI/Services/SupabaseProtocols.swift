import Foundation
import Supabase
import Realtime

protocol SupabaseProtocol {
    var database: PostgrestClient { get }
    var realtime: RealtimeClient { get }
    func updateChatSession(_ session: ChatSession) async throws
    func saveChatMessage(_ message: ChatMessage) async throws
    func subscribeToMessages(sessionId: UUID, onMessage: @escaping (ChatMessage) -> Void) -> Channel?
    func updateProfile(_ profile: UserProfile) async throws
}

extension SupabaseClient: SupabaseProtocol {
    func updateChatSession(_ session: ChatSession) async throws {
        struct ChatSessionUpdate: Codable {
            let status: String
            let endedAt: Date?
            let messageCount: Int
            let updatedAt: Date
            
            enum CodingKeys: String, CodingKey {
                case status
                case endedAt = "ended_at"
                case messageCount = "message_count"
                case updatedAt = "updated_at"
            }
        }
        
        let update = ChatSessionUpdate(
            status: session.status.rawValue,
            endedAt: session.endedAt,
            messageCount: session.messageCount,
            updatedAt: Date()
        )
        
        try await database
            .from("chat_sessions")
            .update(values: update)
            .eq(column: "id", value: session.id.uuidString)
            .execute()
    }
    
    func saveChatMessage(_ message: ChatMessage) async throws {
        struct ChatMessageRecord: Codable {
            let sessionId: UUID
            let userId: UUID?
            let role: String
            let content: String
            let metadata: [String: String]?
            
            enum CodingKeys: String, CodingKey {
                case sessionId = "session_id"
                case userId = "user_id"
                case role
                case content
                case metadata
            }
        }
        
        let record = ChatMessageRecord(
            sessionId: message.sessionId,
            userId: message.userId,
            role: message.role.rawValue,
            content: message.content,
            metadata: message.metadata
        )
        
        try await database
            .from("chat_messages")
            .insert(values: record)
            .execute()
    }
    
    func subscribeToMessages(sessionId: UUID, onMessage: @escaping (ChatMessage) -> Void) -> Channel? {
        guard let topic = ChannelTopic(rawValue: "public:chat_messages") else {
            return nil
        }
        
        let channel = realtime.channel(topic)
        
        channel.on(.all) { message in
            if let data = try? JSONSerialization.data(withJSONObject: message.payload),
               let chatMessage = try? JSONDecoder().decode(ChatMessage.self, from: data),
               chatMessage.sessionId == sessionId {
                onMessage(chatMessage)
            }
        }
        
        channel.subscribe()
        return channel
    }
    
    func updateProfile(_ profile: UserProfile) async throws {
        struct ProfileUpdate: Codable {
            let firstName: String
            let lastName: String
            let email: String
            let gender: String?
            let avatarUrl: String?
            let bio: String?
            let phone: String?
            let updatedAt: Date
            
            enum CodingKeys: String, CodingKey {
                case firstName = "first_name"
                case lastName = "last_name"
                case email
                case gender
                case avatarUrl = "avatar_url"
                case bio
                case phone
                case updatedAt = "updated_at"
            }
        }
        
        let update = ProfileUpdate(
            firstName: profile.firstName,
            lastName: profile.lastName,
            email: profile.email,
            gender: profile.gender?.rawValue,
            avatarUrl: profile.avatarUrl,
            bio: profile.bio,
            phone: profile.phone,
            updatedAt: Date()
        )
        
        try await database
            .from("profiles")
            .update(values: update)
            .eq(column: "id", value: profile.id.uuidString)
            .execute()
    }
} 