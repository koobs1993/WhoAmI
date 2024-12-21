import Foundation
import SwiftUI

// MARK: - User Models
struct UserProfile: Codable, Identifiable, Equatable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var avatarUrl: String?
    var bio: String?
    var settings: UserSettings?
    var stats: UserStats?
    var subscription: SubscriptionStatus?
    var devices: [UserDevice]?
    var createdAt: Date
    var updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case avatarUrl = "avatar_url"
        case bio
        case settings
        case stats
        case subscription
        case devices
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserSettings: Codable, Equatable {
    var theme: AppTheme
    var notifications: NotificationSettings
    var accessibility: AccessibilitySettings
    var privacy: PrivacySettings
    var language: String
    var timezone: String
    
    static var `default`: UserSettings {
        UserSettings(
            theme: .system,
            notifications: .default,
            accessibility: .default,
            privacy: .default,
            language: Locale.current.language.languageCode?.identifier ?? "en",
            timezone: TimeZone.current.identifier
        )
    }
}

struct NotificationSettings: Codable, Equatable {
    var pushEnabled: Bool
    var emailEnabled: Bool
    var testReminders: Bool
    var courseUpdates: Bool
    var weeklyDigest: Bool
    
    static var `default`: NotificationSettings {
        NotificationSettings(
            pushEnabled: true,
            emailEnabled: true,
            testReminders: true,
            courseUpdates: true,
            weeklyDigest: true
        )
    }
}

struct AccessibilitySettings: Codable, Equatable {
    var reduceMotion: Bool
    var increaseContrast: Bool
    var largerText: Bool
    var speakScreen: Bool
    
    static var `default`: AccessibilitySettings {
        AccessibilitySettings(
            reduceMotion: false,
            increaseContrast: false,
            largerText: false,
            speakScreen: false
        )
    }
}

struct PrivacySettings: Codable, Equatable {
    var profileVisibility: ProfileVisibility
    var shareProgress: Bool
    var shareResults: Bool
    
    static var `default`: PrivacySettings {
        PrivacySettings(
            profileVisibility: .public,
            shareProgress: true,
            shareResults: true
        )
    }
}

enum ProfileVisibility: String, Codable, Equatable {
    case `public`
    case friends
    case `private`
}

enum AppTheme: String, Codable, Equatable {
    case light
    case dark
    case system
}

// MARK: - User Device
enum DevicePlatform: String, Codable, Equatable {
    case iOS = "ios"
    case web = "web"
}

struct UserDevice: Codable, Identifiable, Equatable {
    let id: UUID
    let userId: UUID
    let name: String
    let platform: DevicePlatform
    let osVersion: String
    let appVersion: String
    let lastActive: Date
    let pushToken: String?
    let settings: DeviceSettings?
    
    private enum CodingKeys: String, CodingKey {
        case id = "device_id"
        case userId = "user_id"
        case name
        case platform
        case osVersion = "os_version"
        case appVersion = "app_version"
        case lastActive = "last_active"
        case pushToken = "push_token"
        case settings
    }
}

struct DeviceSettings: Codable, Equatable {
    var notificationsEnabled: Bool
    var soundEnabled: Bool
    var badgesEnabled: Bool
    var vibrationEnabled: Bool
    
    private enum CodingKeys: String, CodingKey {
        case notificationsEnabled = "notifications_enabled"
        case soundEnabled = "sound_enabled"
        case badgesEnabled = "badges_enabled"
        case vibrationEnabled = "vibration_enabled"
    }
    
    static let `default` = DeviceSettings(
        notificationsEnabled: true,
        soundEnabled: true,
        badgesEnabled: true,
        vibrationEnabled: true
    )
}

// MARK: - Subscription Status
struct SubscriptionStatus: Codable, Equatable {
    var isSubscribed: Bool
    var plan: SubscriptionPlan?
    var startDate: Date?
    var endDate: Date?
    var autoRenew: Bool
    var status: Status
    
    private enum CodingKeys: String, CodingKey {
        case isSubscribed = "is_subscribed"
        case plan
        case startDate = "start_date"
        case endDate = "end_date"
        case autoRenew = "auto_renew"
        case status
    }
    
    enum Status: String, Codable, Equatable {
        case active
        case canceled
        case expired
        case trial
    }
}

enum SubscriptionPlan: String, Codable, Equatable {
    case free
    case basic
    case premium
    case enterprise
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .basic: return "Basic"
        case .premium: return "Premium"
        case .enterprise: return "Enterprise"
        }
    }
    
    var features: [String] {
        switch self {
        case .free:
            return [
                "Access to basic tests",
                "Limited course access",
                "Basic analytics"
            ]
        case .basic:
            return [
                "All free features",
                "Full test access",
                "Course progress tracking",
                "Email support"
            ]
        case .premium:
            return [
                "All basic features",
                "Priority support",
                "Advanced analytics",
                "Personalized recommendations",
                "No ads"
            ]
        case .enterprise:
            return [
                "All premium features",
                "Custom branding",
                "API access",
                "Dedicated support",
                "Team management"
            ]
        }
    }
}

// MARK: - Notification Models
struct UserNotification: Codable, Identifiable, Equatable {
    let id: UUID
    let userId: UUID
    let title: String
    let message: String
    let type: NotificationType
    var status: NotificationStatus
    let metadata: [String: String]?
    let createdAt: Date
    let updatedAt: Date
    
    enum NotificationType: String, Codable, Equatable {
        case system
        case course
        case test
        case achievement
        case message
    }
    
    enum NotificationStatus: String, Codable, Equatable {
        case unread
        case read
        case archived
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case message
        case type
        case status
        case metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Achievement Models
struct Achievement: Codable, Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let type: AchievementType
    let requirement: Int
    let reward: AchievementReward?
    
    private enum CodingKeys: String, CodingKey {
        case id = "achievement_id"
        case title
        case description
        case icon
        case type
        case requirement
        case reward
    }
}

enum AchievementType: String, Codable, Equatable {
    case testsCompleted = "tests_completed"
    case coursesCompleted = "courses_completed"
    case streakDays = "streak_days"
    case perfectScore = "perfect_score"
}

struct AchievementReward: Codable, Equatable {
    let type: RewardType
    let value: Int
    
    enum RewardType: String, Codable, Equatable {
        case points
        case badge
        case feature
    }
}
