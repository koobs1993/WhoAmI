import Foundation

public struct UserDeviceSettings: Codable {
    public let id: UUID
    public let userId: UUID
    public var notificationsEnabled: Bool
    public var courseUpdatesEnabled: Bool
    public var testRemindersEnabled: Bool
    public var weeklySummariesEnabled: Bool
    public var analyticsEnabled: Bool
    public var trackingAuthorized: Bool
    public var darkModeEnabled: Bool
    public var hapticsEnabled: Bool
    public var fontSize: Int
    public var soundEnabled: Bool
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
