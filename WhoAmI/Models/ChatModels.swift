import Foundation

public struct ChatMessage: Codable, Identifiable {
    public let id: UUID
    public let sessionId: UUID
    public let content: String
    public let role: MessageRole
    public let userId: UUID?
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public init(
        id: UUID = UUID(),
        sessionId: UUID,
        content: String,
        role: MessageRole,
        userId: UUID? = nil,
        createdAt: Date? = Date(),
        updatedAt: Date? = Date()
    ) {
        self.id = id
        self.sessionId = sessionId
        self.content = content
        self.role = role
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case content
        case role
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public enum MessageRole: String, Codable {
    case system
    case user
    case assistant
}

public struct ChatSession: Codable, Identifiable {
    public let id: UUID
    public let userId: UUID
    public let title: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        title: String? = nil,
        createdAt: Date? = Date(),
        updatedAt: Date? = Date()
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
