import Foundation
import Supabase
import Realtime

class ChatService {
    private let supabase: SupabaseClient
    private let realtime: RealtimeClient
    
    init(supabase: SupabaseClient, realtime: RealtimeClient) {
        self.supabase = supabase
        self.realtime = realtime
    }
    
    func sendMessage(_ message: ChatMessage) async throws {
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
        
        try await supabase.database
            .from("chat_messages")
            .insert(values: record)
            .execute()
    }
    
    func subscribe(_ topic: String, onMessage: @escaping (ChatMessage) -> Void) -> Channel {
        guard let channelTopic = ChannelTopic(rawValue: topic) else {
            fatalError("Invalid channel topic: \(topic)")
        }
        
        let channel = realtime.channel(channelTopic)
        
        channel.on(.all) { message in
            do {
                let data = try JSONSerialization.data(withJSONObject: message.payload)
                if let chatMessage = try? JSONDecoder().decode(ChatMessage.self, from: data) {
                    onMessage(chatMessage)
                }
            } catch {
                print("Failed to decode message: \(error)")
            }
        }
        
        channel.subscribe()
        return channel
    }
    
    func unsubscribe(_ channel: Channel) {
        channel.unsubscribe()
    }
    
    func fetchMessages(sessionId: UUID) async throws -> [ChatMessage] {
        return try await supabase.database
            .from("chat_messages")
            .select()
            .eq(column: "session_id", value: sessionId.uuidString)
            .order(column: "created_at")
            .execute()
            .value
    }
}
 