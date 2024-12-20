import Foundation
import Supabase
import Realtime

protocol SupabaseProtocol {
    var realtimeV2: RealtimeClientV2 { get }
    // Chat methods temporarily disabled
    /*
    func saveChatMessage(_ message: WhoAmI.ChatMessage) async throws
    func subscribeToMessages(sessionId: UUID, onMessage: @escaping (WhoAmI.ChatMessage) -> Void) async -> RealtimeChannelV2?
    */
    func updateProfile(_ profile: UserProfile) async throws
}

extension SupabaseClient: SupabaseProtocol {
    // Chat methods temporarily disabled
    /*
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
        
        try await from("chat_messages")
            .insert(record)
            .execute()
    }
    
    func subscribeToMessages(sessionId: UUID, onMessage: @escaping (WhoAmI.ChatMessage) -> Void) async -> RealtimeChannelV2? {
        let channel = realtimeV2.channel("realtime:public:chat_messages")
        
        // Set up notification observer
        NotificationCenter.default.addObserver(forName: Notification.Name("RealtimeMessage"), object: nil, queue: .main) { notification in
            guard let message = notification.object as? RealtimeMessageV2,
                  let record = message.payload["record"] as? [String: Any],
                  let data = try? JSONSerialization.data(withJSONObject: record),
                  let chatMessage = try? JSONDecoder().decode(WhoAmI.ChatMessage.self, from: data) else {
                return
            }
            onMessage(chatMessage)
        }
        
        do {
            await channel.subscribe()
            return channel
        } catch {
            print("Failed to subscribe to chat messages: \(error)")
            return nil
        }
    }
    */
    
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
        
        try await from("profiles")
            .update(update)
            .eq("id", value: profile.id.uuidString)
            .execute()
    }
}
