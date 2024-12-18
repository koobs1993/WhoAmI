import Foundation
import Supabase

struct NotificationSettings: Codable {
    let enabled: Bool
    let types: [NotificationType]
}

@MainActor
class NotificationsViewModel: ObservableObject {
    private let supabase: SupabaseClient
    private let cache = NSCache<NSString, CacheEntry<[UserNotification]>>()
    private let cacheDuration: TimeInterval = 300 // 5 minutes
    private let userId: UUID
    
    @Published var notifications: [UserNotification] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var deviceSettings = UserDeviceSettings(
        notificationsEnabled: true,
        theme: "system",
        language: "en",
        courseUpdatesEnabled: true,
        testRemindersEnabled: true,
        weeklySummariesEnabled: true,
        analyticsEnabled: true,
        trackingAuthorized: false,
        darkModeEnabled: false,
        hapticsEnabled: true,
        fontSize: 16,
        soundEnabled: true
    )
    
    var isEnabled: Bool {
        deviceSettings.notificationsEnabled
    }
    
    var enabledTypes: [NotificationType] {
        var types: [NotificationType] = []
        if deviceSettings.courseUpdatesEnabled { types.append(.courseUpdate) }
        if deviceSettings.testRemindersEnabled { types.append(.testReminder) }
        if deviceSettings.weeklySummariesEnabled { types.append(.info) }
        return types
    }
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
        self.userId = UUID() // This should be set from auth session
        setupCache()
    }
    
    private func setupCache() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    func saveSettings() async {
        do {
            try await updateSettings()
        } catch {
            self.error = error
        }
    }
    
    func updateSettings() async throws {
        let settings = NotificationSettings(
            enabled: isEnabled,
            types: enabledTypes
        )
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(settings)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        
        try await supabase.database
            .from("user_settings")
            .upsert(values: [
                "user_id": userId.uuidString,
                "notification_settings": try JSONSerialization.data(withJSONObject: dict).base64EncodedString()
            ])
            .execute()
    }
    
    func fetchNotifications() async throws {
        let response = try await supabase.database
            .from("notifications")
            .select()
            .eq(column: "user_id", value: userId)
            .order(column: "created_at", ascending: false)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let data = try JSONSerialization.data(withJSONObject: response.underlyingResponse.data)
        notifications = try decoder.decode([UserNotification].self, from: data)
        cache.setObject(CacheEntry(value: notifications), forKey: "notifications" as NSString)
    }
    
    private func getCachedNotifications() -> [UserNotification]? {
        guard let entry = cache.object(forKey: "notifications" as NSString) else { return nil }
        if entry.isExpired {
            return nil
        }
        return entry.value
    }
    
    func markAsRead(_ notification: UserNotification) async throws {
        try await supabase.database
            .from("notifications")
            .update(values: ["read": true])
            .eq(column: "id", value: notification.id)
            .execute()
        
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            var updatedNotification = notifications[index]
            updatedNotification.read = true
            notifications[index] = updatedNotification
        }
    }
    
    func saveNotificationSettings() async throws {
        let settings = NotificationSettings(
            enabled: deviceSettings.notificationsEnabled,
            types: enabledTypes
        )
        let dict = try JSONEncoder().encode(settings)
        let jsonString = String(data: dict, encoding: .utf8) ?? "{}"
        
        try await supabase.database
            .from("user_settings")
            .upsert(values: [
                "user_id": userId.uuidString,
                "notification_settings": jsonString
            ])
            .execute()
    }
} 