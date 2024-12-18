import Foundation

public struct ChatMessage: Codable, Identifiable {
    public let id: UUID
    public let sessionId: UUID
    public let userId: UUID?
    public let content: String
    public let role: MessageRole
    public let createdAt: Date?
    public let metadata: [String: String]?
    
    public init(
        id: UUID = UUID(),
        sessionId: UUID,
        content: String,
        role: MessageRole,
        createdAt: Date? = Date(),
        userId: UUID? = nil,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.sessionId = sessionId
        self.content = content
        self.role = role
        self.createdAt = createdAt
        self.userId = userId
        self.metadata = metadata
    }
}

public enum MessageRole: String, Codable {
    case system
    case user
    case assistant
}

public struct ChatSession: Codable, Identifiable {
    public let id: UUID
    public var title: String?
    public let userId: UUID
    public let createdAt: Date
    public var updatedAt: Date
    public var lastMessage: String?
    
    public init(
        id: UUID = UUID(),
        title: String? = nil,
        userId: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastMessage: String? = nil
    ) {
        self.id = id
        self.title = title
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastMessage = lastMessage
    }
}
