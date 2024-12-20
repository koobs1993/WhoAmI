import Foundation

public struct UserProfile: Codable, Identifiable, Sendable {
    public let id: UUID
    public let userId: UUID
    public var firstName: String
    public var lastName: String
    public var displayName: String
    public let email: String
    public var bio: String?
    public var avatarUrl: String?
    public var location: String?
    public var website: String?
    public var socialLinks: [String: String]?
    public var interests: [String]?
    public let createdAt: Date
    public let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case displayName = "display_name"
        case email
        case bio
        case avatarUrl = "avatar_url"
        case location
        case website
        case socialLinks = "social_links"
        case interests
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        firstName: String,
        lastName: String,
        displayName: String? = nil,
        email: String,
        bio: String? = nil,
        avatarUrl: String? = nil,
        location: String? = nil,
        website: String? = nil,
        socialLinks: [String: String]? = nil,
        interests: [String]? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.displayName = displayName ?? "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        self.email = email
        self.bio = bio
        self.avatarUrl = avatarUrl
        self.location = location
        self.website = website
        self.socialLinks = socialLinks
        self.interests = interests
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct UserPrivacySettings: Codable, Identifiable, Sendable {
    public let id: UUID
    public let userId: UUID
    public var isPublic: Bool
    public var showEmail: Bool
    public var showLocation: Bool
    public var showActivity: Bool
    public var showStats: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case isPublic = "is_public"
        case showEmail = "show_email"
        case showLocation = "show_location"
        case showActivity = "show_activity"
        case showStats = "show_stats"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        isPublic: Bool = false,
        showEmail: Bool = false,
        showLocation: Bool = false,
        showActivity: Bool = true,
        showStats: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.isPublic = isPublic
        self.showEmail = showEmail
        self.showLocation = showLocation
        self.showActivity = showActivity
        self.showStats = showStats
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct DashboardItem: Codable, Identifiable, Sendable {
    public let id: UUID
    public let userId: UUID
    public let title: String
    public let description: String
    public let type: DashboardItemType
    public let status: DashboardItemStatus
    public let metadata: [String: String]?
    public let createdAt: Date
    public let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case description
        case type
        case status
        case metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        title: String,
        description: String,
        type: DashboardItemType,
        status: DashboardItemStatus = .active,
        metadata: [String: String]? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.description = description
        self.type = type
        self.status = status
        self.metadata = metadata
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum DashboardItemType: String, Codable, Sendable {
    case course
    case test
    case achievement
    case notification
}

public enum DashboardItemStatus: String, Codable, Sendable {
    case active
    case completed
    case archived
}

public struct UserStats: Codable, Identifiable, Sendable {
    public let id: UUID
    public let userId: UUID
    public let coursesCompleted: Int
    public let testsCompleted: Int
    public let averageScore: Double
    public let totalPoints: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case coursesCompleted = "courses_completed"
        case testsCompleted = "tests_completed"
        case averageScore = "average_score"
        case totalPoints = "total_points"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        coursesCompleted: Int = 0,
        testsCompleted: Int = 0,
        averageScore: Double = 0.0,
        totalPoints: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.coursesCompleted = coursesCompleted
        self.testsCompleted = testsCompleted
        self.averageScore = averageScore
        self.totalPoints = totalPoints
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
