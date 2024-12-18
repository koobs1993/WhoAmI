import Foundation
import Supabase

class ChatService: BaseService {
    private let realtime: RealtimeClient
    
    init(supabase: SupabaseClient, realtime: RealtimeClient) {
        self.realtime = realtime
        super.init(supabase: supabase)
    }
    
    func subscribe(_ channelName: String, onMessage: @escaping (ChatMessage) -> Void) -> RealtimeChannel {
        let channel = realtime.channel(channelName)
        
        // Configure channel with proper authentication
        channel.on("*", filter: .init()) { error in
            print("Channel error: \(error)")
        }
        
        channel.on("presence", filter: .init()) { _ in
            print("Channel closed")
        }
        
        channel.on("broadcast", filter: .init()) { _ in
            print("Joined channel: \(channelName)")
        }
        
        // Subscribe to Postgres changes
        channel.on(
            "postgres_changes",
            filter: .init(
                event: "*",
                schema: "public",
                table: "chat_messages"
            )
        ) { message in
            print("Received message: \(message)")
            
            do {
                let payload = message.payload
                let data = try JSONSerialization.data(withJSONObject: payload)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let chatMessage = try decoder.decode(ChatMessage.self, from: data)
                Task { @MainActor in
                    onMessage(chatMessage)
                }
            } catch {
                print("Failed to decode message: \(error)")
                print("Raw payload: \(message.payload)")
            }
        }
        
        Task {
            do {
                // Ensure we have a valid session
                let session = try await supabase.auth.session
                print("Subscribing to channel with authenticated session")
                channel.subscribe()
            } catch {
                print("Failed to get session for channel subscription: \(error)")
            }
        }
        
        return channel
    }
    
    func unsubscribe(_ channel: RealtimeChannel) {
        print("Unsubscribing from channel")
        channel.unsubscribe()
    }
    
    func fetchMessages(limit: Int = 50, offset: Int = 0) async throws -> [ChatMessage] {
        print("Fetching messages with limit: \(limit), offset: \(offset)")
        let response: PostgrestResponse<[ChatMessage]> = try await supabase
            .from("chat_messages")
            .select()
            .order("created_at", ascending: false)
            .limit(limit)
            .range(from: offset, to: offset + limit - 1)
            .execute()
        
        print("Fetched \(response.value.count) messages")
        return response.value
    }
    
    func sendMessage(_ message: ChatMessage) async throws {
        print("Sending message: \(message)")
        try await supabase
            .from("chat_messages")
            .insert([
                "session_id": message.sessionId.uuidString,
                "content": message.content,
                "role": message.role.rawValue,
                "user_id": message.userId?.uuidString ?? "",
                "created_at": formatDate(message.createdAt ?? Date())
            ])
            .execute()
        print("Message sent successfully")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}
