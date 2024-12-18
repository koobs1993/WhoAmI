import Foundation

public struct UserStats: Codable {
    public let id: UUID
    public let userId: UUID
    public let completedTests: Int
    public let coursesCompleted: Int
    public let streak: Int
    public let lastActive: Date
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        completedTests: Int = 0,
        coursesCompleted: Int = 0,
        streak: Int = 0,
        lastActive: Date = Date(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.completedTests = completedTests
        self.coursesCompleted = coursesCompleted
        self.streak = streak
        self.lastActive = lastActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
