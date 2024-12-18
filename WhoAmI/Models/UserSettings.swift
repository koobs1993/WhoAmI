import Foundation

public struct UserDeviceSettings: Codable {
    public let id: UUID
    public let userId: UUID
    public let notificationsEnabled: Bool
    public let courseUpdatesEnabled: Bool
    public let testRemindersEnabled: Bool
    public let weeklySummariesEnabled: Bool
    public let analyticsEnabled: Bool
    public let trackingAuthorized: Bool
    public let darkModeEnabled: Bool
    public let hapticsEnabled: Bool
    public let fontSize: Int
    public let soundEnabled: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        notificationsEnabled: Bool = true,
        courseUpdatesEnabled: Bool = true,
        testRemindersEnabled: Bool = true,
        weeklySummariesEnabled: Bool = true,
        analyticsEnabled: Bool = false,
        trackingAuthorized: Bool = false,
        darkModeEnabled: Bool = false,
        hapticsEnabled: Bool = true,
        fontSize: Int = 16,
        soundEnabled: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.notificationsEnabled = notificationsEnabled
        self.courseUpdatesEnabled = courseUpdatesEnabled
        self.testRemindersEnabled = testRemindersEnabled
        self.weeklySummariesEnabled = weeklySummariesEnabled
        self.analyticsEnabled = analyticsEnabled
        self.trackingAuthorized = trackingAuthorized
        self.darkModeEnabled = darkModeEnabled
        self.hapticsEnabled = hapticsEnabled
        self.fontSize = fontSize
        self.soundEnabled = soundEnabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
