import Foundation

public struct UserProfile: Codable, Identifiable {
    public let id: UUID
    public let userId: UUID
    public var firstName: String
    public var lastName: String
    public var email: String
    public var bio: String?
    public var avatarUrl: String?
    public let createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        firstName: String,
        lastName: String,
        email: String,
        bio: String? = nil,
        avatarUrl: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.bio = bio
        self.avatarUrl = avatarUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct UserPrivacySettings: Codable, Identifiable {
    public let id: UUID
    public let userId: UUID
    public var showProfile: Bool
    public var showActivity: Bool
    public var showStats: Bool
    public let createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        showProfile: Bool = true,
        showActivity: Bool = true,
        showStats: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.showProfile = showProfile
        self.showActivity = showActivity
        self.showStats = showStats
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct UserCourse: Codable, Identifiable {
    public let id: UUID
    public let userId: UUID
    public let courseId: Int
    public var progress: Double
    public let startedAt: Date
    public var completedAt: Date?
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        courseId: Int,
        progress: Double = 0.0,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.courseId = courseId
        self.progress = progress
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.updatedAt = updatedAt
    }
}

public struct EnrolledCourseResponse: Codable {
    public let course: Course
    public let enrollment: UserCourse
    
    public init(course: Course, enrollment: UserCourse) {
        self.course = course
        self.enrollment = enrollment
    }
}
