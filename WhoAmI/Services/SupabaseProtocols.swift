import Foundation
import Supabase

protocol SupabaseProtocol {
    var database: PostgrestClient { get }
    var auth: GoTrueClient { get }
    var realtime: RealtimeClient { get }
}

extension SupabaseClient: SupabaseProtocol {}

// MARK: - Chat Extensions
extension SupabaseProtocol {
    func createChatSession(userId: UUID) async throws -> ChatSession {
        let session = ChatSession(
            id: UUID(),
            userId: userId,
            status: "active",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await database
            .from("chat_sessions")
            .insert(session)
            .execute()
        
        return session
    }
    
    func getChatSession(id: UUID) async throws -> ChatSession {
        let response = try await database
            .from("chat_sessions")
            .select("*, messages(*)")
            .eq(column: "id", value: id)
            .single()
            .execute()
        
        return try response.decode(ChatSession.self)
    }
    
    func updateChatSession(_ session: ChatSession) async throws {
        try await database
            .from("chat_sessions")
            .update(session)
            .eq(column: "id", value: session.id)
            .execute()
    }
    
    func addMessage(to sessionId: UUID, content: String, role: ChatRole) async throws -> ChatMessage {
        let message = ChatMessage(
            id: UUID(),
            sessionId: sessionId,
            content: content,
            role: role,
            createdAt: Date()
        )
        
        try await database
            .from("chat_messages")
            .insert(message)
            .execute()
        
        return message
    }
    
    func getMessages(for sessionId: UUID) async throws -> [ChatMessage] {
        let response = try await database
            .from("chat_messages")
            .select()
            .eq(column: "session_id", value: sessionId)
            .order(column: "created_at")
            .execute()
        
        return try response.decode([ChatMessage].self)
    }
    
    func subscribeToMessages(sessionId: UUID, onMessage: @escaping (ChatMessage) -> Void) -> RealtimeChannel {
        let channel = realtime
            .channel(.table("chat_messages", schema: "public"))
            .on(.insert) { message in
                guard let messageData = message.newRecord,
                      let chatMessage = try? JSONDecoder().decode(ChatMessage.self, from: messageData) else {
                    return
                }
                onMessage(chatMessage)
            }
        
        channel.subscribe()
        return channel
    }
}

// MARK: - Profile Extensions
extension SupabaseProtocol {
    func updateProfile(_ profile: UserProfile) async throws {
        try await database
            .from("profiles")
            .update(profile)
            .eq(column: "id", value: profile.id)
            .execute()
    }
    
    func getProfile(userId: UUID) async throws -> UserProfile {
        let response = try await database
            .from("profiles")
            .select()
            .eq(column: "id", value: userId)
            .single()
            .execute()
        
        return try response.decode(UserProfile.self)
    }
}

// MARK: - Device Token Extensions
extension SupabaseProtocol {
    func saveDeviceToken(_ token: String, platform: String) async throws {
        let session = try await auth.session
        let userId = session.user.id
        
        try await database
            .from("user_devices")
            .upsert(values: [
                "user_id": userId.uuidString,
                "device_token": token,
                "platform": platform,
                "last_seen": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()
    }
    
    func recordNotificationInteraction(notificationId: String) async throws {
        let session = try await auth.session
        let userId = session.user.id
        
        try await database
            .from("notification_interactions")
            .insert(values: [
                "notification_id": notificationId,
                "user_id": userId.uuidString,
                "interaction_type": "opened",
                "interaction_date": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()
    }
} 