import Foundation
import Supabase
import Realtime

class ChatService {
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func sendMessage(_ values: [String: Any]) async throws -> ChatMessage {
        let response: PostgrestResponse<ChatMessage> = try await supabase.database
            .from("chatmessages")
            .insert(values: values)
            .select()
            .single()
            .execute()
        
        guard let message = response.value else {
            throw DatabaseError.noData
        }
        
        return message
    }
    
    func fetchMessages(sessionId: UUID) async throws -> [ChatMessage] {
        let response: PostgrestResponse<[ChatMessage]> = try await supabase.database
            .from("chatmessages")
            .select()
            .eq(column: "session_id", value: sessionId.uuidString)
            .order(column: "created_at")
            .execute()
        
        return response.value ?? []
    }
    
    func subscribeToMessages(sessionId: UUID, onMessage: @escaping (ChatMessage) -> Void) -> Channel {
        let channel = supabase.realtime
            .channel("public:chatmessages")
            .on(.all) { [weak self] message in
                guard let self = self,
                      let payload = message.payload,
                      let jsonData = try? JSONSerialization.data(withJSONObject: payload),
                      let chatMessage = try? JSONDecoder().decode(ChatMessage.self, from: jsonData)
                else { return }
                
                onMessage(chatMessage)
            }
            .subscribe()
        
        return channel
    }
    
    func unsubscribe(_ channel: Channel) {
        channel.unsubscribe()
    }
}

enum DatabaseError: Error {
    case noData
}
 