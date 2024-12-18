import Foundation

// MARK: - Chat-specific models
struct TypingIndicator: Codable, Equatable {
    let userId: UUID
    let channelId: UUID
    let isTyping: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case channelId = "channel_id"
        case isTyping = "is_typing"
    }
}