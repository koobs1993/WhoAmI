import Foundation

// MARK: - User Profile Models
struct UserProfile: Codable, Identifiable {
    let id: UUID
    var username: String
    var email: String
    var fullName: String?
    var avatarUrl: String?
    var bio: String?
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case bio
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserStats: Codable {
    var testsCompleted: Int
    var averageScore: Double
    var totalTime: TimeInterval
    var lastActive: Date
    
    enum CodingKeys: String, CodingKey {
        case testsCompleted = "tests_completed"
        case averageScore = "average_score"
        case totalTime = "total_time"
        case lastActive = "last_active"
    }
}

struct UserDevicePreferences: Codable {
    var theme: String
    var fontSize: Int
    var notifications: Bool
    var soundEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case theme
        case fontSize = "font_size"
        case notifications
        case soundEnabled = "sound_enabled"
    }
}

struct UserPrivacySettings: Codable {
    var profileVisibility: String
    var showActivity: Bool
    var allowMessages: Bool
    
    enum CodingKeys: String, CodingKey {
        case profileVisibility = "profile_visibility"
        case showActivity = "show_activity"
        case allowMessages = "allow_messages"
    }
}

// MARK: - Notification Models
enum NotificationType: String, Codable {
    case courseUpdate = "course_update"
    case testReminder = "test_reminder"
    case achievementUnlocked = "achievement_unlocked"
    case systemUpdate = "system_update"
    case newMessage = "new_message"
}

struct UserNotification: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let type: NotificationType
    let title: String
    let message: String
    let metadata: [String: String]?
    let isRead: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type
        case title
        case message
        case metadata
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}

// MARK: - Chat Models
enum MessageRole: String, Codable {
    case user = "user"
    case assistant = "assistant"
    case system = "system"
}

enum ChatSessionStatus: String, Codable {
    case active = "active"
    case completed = "completed"
    case archived = "archived"
}

struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let sessionId: UUID
    let userId: UUID?
    let role: MessageRole
    let content: String
    let metadata: [String: String]?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case userId = "user_id"
        case role
        case content
        case metadata
        case createdAt = "created_at"
    }
}

struct ChatSession: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let title: String?
    let status: ChatSessionStatus
    let startedAt: Date
    let endedAt: Date?
    let messageCount: Int
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case status
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case messageCount = "message_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// Constants for type values
extension UserNotification {
    static let typeSystem = "system"
    static let typeAchievement = "achievement"
    static let typeMessage = "message"
    static let typeReminder = "reminder"
    static let typeCourseUpdate = "course_update"
}

extension ChatSession {
    static let statusActive = "active"
    static let statusCompleted = "completed"
    static let statusArchived = "archived"
}

extension ChatMessage {
    static let roleSystem = "system"
    static let roleUser = "user"
    static let roleAssistant = "assistant"
}

// MARK: - User Device Settings
struct UserDeviceSettings: Codable {
    var analyticsEnabled: Bool
    var trackingAuthorized: Bool
    var theme: String
    var fontSize: Int
    var notifications: Bool
    var soundEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case analyticsEnabled = "analytics_enabled"
        case trackingAuthorized = "tracking_authorized"
        case theme
        case fontSize = "font_size"
        case notifications
        case soundEnabled = "sound_enabled"
    }
}

// Add these enums to SharedModels.swift

enum Gender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    case nonBinary = "non_binary"
    case preferNotToSay = "prefer_not_to_say"
}

enum CourseStatus: String, Codable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case completed = "completed"
    case locked = "locked"
}

struct CourseProgress: Codable {
    let id: Int
    let userId: UUID
    let courseId: UUID
    let completedLessons: Int
    let totalLessons: Int
    let createdAt: Date
    let updatedAt: Date
    
    var progressPercentage: Double {
        guard totalLessons > 0 else { return 0.0 }
        return Double(completedLessons) / Double(totalLessons)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case courseId = "course_id"
        case completedLessons = "completed_lessons"
        case totalLessons = "total_lessons"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Question Models
enum QuestionResponseType: String, Codable {
    case multipleChoice = "multiple_choice"
    case shortAnswer = "short_answer"
    case longAnswer = "long_answer"
    case trueFalse = "true_false"
    case rating = "rating"
}

struct QuestionOption: Codable, Identifiable {
    let id: Int
    let questionId: Int
    let text: String
    let isCorrect: Bool?
    let order: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "option_id"
        case questionId = "question_id"
        case text
        case isCorrect = "is_correct"
        case order
    }
}

// MARK: - Course Models
enum LessonStatus: String, Codable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case completed = "completed"
}