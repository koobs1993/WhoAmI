import Foundation
import SwiftUI

// MARK: - User Profile Models
public struct UserProfile: Codable, Identifiable, Sendable {
    public let id: UUID
    public let userId: UUID
    public let firstName: String
    public let lastName: String
    public let email: String
    public let gender: Gender?
    public let role: UserRole
    public let avatarUrl: String?
    public let bio: String?
    public let phone: String?
    public let isActive: Bool
    public let emailConfirmedAt: Date?
    public let createdAt: Date
    public let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case gender
        case role
        case avatarUrl = "avatar_url"
        case bio
        case phone
        case isActive = "is_active"
        case emailConfirmedAt = "email_confirmed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Notification Models
public enum NotificationType: String, Codable {
    case info
    case warning
    case success
    case error
    case message
    case achievement
    case system
    case testReminder = "test_reminder"
    case courseUpdate = "course_update"
    
    public var icon: String {
        switch self {
        case .info: return "info.circle"
        case .warning: return "exclamationmark.triangle"
        case .success: return "checkmark.circle"
        case .error: return "xmark.circle"
        case .message: return "message"
        case .achievement: return "trophy"
        case .system: return "gear"
        case .testReminder: return "bell"
        case .courseUpdate: return "book"
        }
    }
    
    public var color: Color {
        switch self {
        case .info: return .blue
        case .warning: return .orange
        case .success: return .green
        case .error: return .red
        case .message: return .blue
        case .achievement: return .purple
        case .system: return .gray
        case .testReminder: return .indigo
        case .courseUpdate: return .blue
        }
    }
}

public struct UserNotification: Codable, Identifiable {
    public let id: UUID
    public let userId: UUID
    public let type: NotificationType
    public let title: String
    public let message: String
    public var read: Bool
    public let createdAt: Date
    public let metadata: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type
        case title
        case message
        case read
        case createdAt = "created_at"
        case metadata
    }
    
    public init(id: UUID = UUID(),
                userId: UUID,
                type: NotificationType,
                title: String,
                message: String,
                metadata: [String: String] = [:],
                read: Bool = false,
                createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.message = message
        self.metadata = metadata
        self.read = read
        self.createdAt = createdAt
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

// MARK: - User Settings Models
public struct UserDeviceSettings: Codable {
    public var notificationsEnabled: Bool
    public var theme: String
    public var language: String
    public var courseUpdatesEnabled: Bool
    public var testRemindersEnabled: Bool
    public var weeklySummariesEnabled: Bool
    public var analyticsEnabled: Bool
    public var trackingAuthorized: Bool
    public var darkModeEnabled: Bool
    public var hapticsEnabled: Bool
    public var fontSize: Int
    public var soundEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case notificationsEnabled = "notifications_enabled"
        case theme
        case language
        case courseUpdatesEnabled = "course_updates_enabled"
        case testRemindersEnabled = "test_reminders_enabled"
        case weeklySummariesEnabled = "weekly_summaries_enabled"
        case analyticsEnabled = "analytics_enabled"
        case trackingAuthorized = "tracking_authorized"
        case darkModeEnabled = "dark_mode_enabled"
        case hapticsEnabled = "haptics_enabled"
        case fontSize = "font_size"
        case soundEnabled = "sound_enabled"
    }
}

public struct UserPrivacySettings: Codable {
    public var showProfile: Bool
    public var showActivity: Bool
    public var allowMessages: Bool
    public var shareProgress: Bool
    
    enum CodingKeys: String, CodingKey {
        case showProfile = "show_profile"
        case showActivity = "show_activity"
        case allowMessages = "allow_messages"
        case shareProgress = "share_progress"
    }
}

// MARK: - Notification Action Models
public struct NotificationAction: Identifiable {
    public let id = UUID()
    public enum ActionType {
        case openTest
        case openChat
        case openURL
        case openCourse
    }
    
    public let type: ActionType
    public let title: String
    public let icon: String
    public let metadata: [String: String]
    
    public init(type: ActionType, title: String, icon: String, metadata: [String: String] = [:]) {
        self.type = type
        self.title = title
        self.icon = icon
        self.metadata = metadata
    }
    
    public static func actions(for type: NotificationType, metadata: [String: String]) -> [NotificationAction] {
        switch type {
        case .courseUpdate:
            return [NotificationAction(type: .openCourse, title: "View Course", icon: "book", metadata: metadata)]
        case .testReminder:
            return [NotificationAction(type: .openTest, title: "Start Test", icon: "pencil", metadata: metadata)]
        case .message:
            return [NotificationAction(type: .openChat, title: "View Message", icon: "message", metadata: metadata)]
        case .achievement:
            return [NotificationAction(type: .openURL, title: "View Achievement", icon: "trophy", metadata: metadata)]
        case .system:
            if metadata["url"] != nil {
                return [NotificationAction(type: .openURL, title: "Learn More", icon: "arrow.right", metadata: metadata)]
            }
            return []
        default:
            if metadata["url"] != nil {
                return [NotificationAction(type: .openURL, title: "Learn More", icon: "arrow.right", metadata: metadata)]
            }
            return []
        }
    }
}

// MARK: - Test Models
public struct TestResult: Codable {
    public let id: UUID
    public let score: Double
    public let completedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case score
        case completedAt = "completed_at"
    }
}

// MARK: - Store Models
public enum SubscriptionDuration: String, Codable {
    case monthly = "monthly"
    case yearly = "yearly"
    
    public var productId: String {
        switch self {
        case .monthly:
            return "com.whoami.subscription.monthly"
        case .yearly:
            return "com.whoami.subscription.yearly"
        }
    }
}

// Add these enums to SharedModels.swift

public enum Gender: String, Codable, CaseIterable, Sendable {
    case male = "male"
    case female = "female"
    case other = "other"
    case preferNotToSay = "prefer_not_to_say"
}

public enum UserRole: String, Codable, Sendable {
    case user = "user"
    case admin = "admin"
    case student = "student"
    case teacher = "teacher"
}

// MARK: - Status Enums
public enum CourseStatus: String, Codable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case completed = "completed"
    case locked = "locked"
}

public enum TestStatus: String, Codable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case completed = "completed"
}

public struct CourseProgress: Codable {
    public let id: Int
    public let userId: UUID
    public let courseId: UUID
    public let completedLessons: Int
    public let totalLessons: Int
    public let createdAt: Date
    public let updatedAt: Date
    
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
public enum QuestionResponseType: String, Codable {
    case multipleChoice = "multiple_choice"
    case shortAnswer = "short_answer"
    case longAnswer = "long_answer"
    case trueFalse = "true_false"
    case rating = "rating"
}

public struct QuestionOption: Codable, Identifiable {
    public let id: Int
    public let questionId: Int
    public let text: String
    public let value: String
    public let order: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case questionId = "question_id"
        case text
        case value
        case order
    }
    
    public init(id: Int, questionId: Int, text: String, value: String, order: Int) {
        self.id = id
        self.questionId = questionId
        self.text = text
        self.value = value
        self.order = order
    }
}

// MARK: - Course Models
public enum LessonStatus: String, Codable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case completed = "completed"
}

public struct OnboardingQuestion: Codable, Identifiable {
    public let id: Int
    public let question: String
    public let options: [String]
    public let correctAnswer: Int
    public let explanation: String
    public let order: Int
    
    private enum CodingKeys: String, CodingKey {
        case id
        case question
        case options
        case correctAnswer = "correct_answer"
        case explanation
        case order
    }
}

public struct UserStats: Codable {
    public let totalTests: Int
    public let completedTests: Int
    public let averageScore: Double
    public let totalTime: TimeInterval
    public let lastActive: Date
    public let coursesStarted: Int
    public let coursesCompleted: Int
    public let streak: Int
    
    public var completionRate: Double {
        guard totalTests > 0 else { return 0 }
        return Double(completedTests) / Double(totalTests) * 100
    }
}

extension NotificationType {
    func getActions(metadata: [String: String]) -> [NotificationAction] {
        switch self {
        case .achievement:
            return [NotificationAction(type: .openURL, title: "View Achievement", icon: "trophy", metadata: metadata)]
        case .system:
            if metadata["url"] != nil {
                return [NotificationAction(type: .openURL, title: "Learn More", icon: "arrow.right", metadata: metadata)]
            }
            return []
        default:
            if metadata["url"] != nil {
                return [NotificationAction(type: .openURL, title: "Learn More", icon: "arrow.right", metadata: metadata)]
            }
            return []
        }
    }
}

// MARK: - Store Models
public enum StoreError: Error, LocalizedError {
    case productNotFound
    case purchaseFailed
    case userCancelled
    case verificationFailed
    case unknown
    case notAuthorized
    case networkError
    
    public var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        case .userCancelled:
            return "Purchase was cancelled"
        case .verificationFailed:
            return "Transaction verification failed"
        case .unknown:
            return "An unknown error occurred"
        case .notAuthorized:
            return "Not authorized to make purchases"
        case .networkError:
            return "Network error occurred"
        }
    }
}

// MARK: - Psych Test Models
public struct PsychTest: Codable, Identifiable {
    public let id: UUID
    public let title: String
    public let shortDescription: String
    public let category: TestCategory
    public let imageUrl: String?
    public let durationMinutes: Int
    public let isActive: Bool
    public let createdAt: Date
    public let updatedAt: Date
    public var userProgress: TestProgress?
    public var questions: [TestQuestion]?
    public var benefits: [TestBenefit]?
    
    // Computed properties
    public var description: String { shortDescription }
    public var estimatedDuration: Int { durationMinutes }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case shortDescription = "short_description"
        case category
        case imageUrl = "image_url"
        case durationMinutes = "duration_minutes"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userProgress = "test_progress"
        case questions = "testquestions"
        case benefits = "testbenefits"
    }
}

public struct TestBenefit: Codable, Identifiable {
    public let id: Int
    public let title: String
    public let description: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
    }
}

public struct TestProgress: Codable {
    public let status: TestStatus
    public let lastUpdated: Date
    public let score: Double?
    
    enum CodingKeys: String, CodingKey {
        case status
        case lastUpdated = "last_updated"
        case score
    }
}

extension TestStatus {
    var sortOrder: Int {
        switch self {
        case .inProgress: return 0
        case .notStarted: return 1
        case .completed: return 2
        }
    }
}

public enum TestCategory: String, Codable, CaseIterable {
    case personality = "Personality"
    case anxiety = "Anxiety"
    case depression = "Depression"
    case stress = "Stress"
    case relationships = "Relationships"
    case career = "Career"
    case other = "Other"
}

// MARK: - Test Models
public struct TestQuestion: Codable, Identifiable, QuestionType {
    public let id: Int
    public let questionId: Int
    public let testId: Int
    public let questionText: String
    public let sequenceOrder: Int
    public let options: [QuestionOption]?
    public let questionType: QuestionResponseType
    public let isRequired: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    public var uuid: UUID { UUID() }
    
    enum CodingKeys: String, CodingKey {
        case id
        case questionId = "question_id"
        case testId = "test_id"
        case questionText = "question_text"
        case sequenceOrder = "sequence_order"
        case options = "questionoptions"
        case questionType = "question_type"
        case isRequired = "is_required"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}