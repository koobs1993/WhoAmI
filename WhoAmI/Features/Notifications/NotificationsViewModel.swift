import Foundation
import Supabase

@MainActor
class NotificationsViewModel: BaseService, ObservableObject {
    @Published var notifications: [UserNotification] = []
    @Published var isLoading = false
    @Published var deviceSettings = NotificationSettings()
    
    private let cache = NSCache<NSString, BaseService.CacheEntry<[UserNotification]>>()
    private let cacheDuration: TimeInterval = 300 // 5 minutes
    
    override init(supabase: SupabaseClient = Config.supabaseClient) {
        super.init(supabase: supabase)
        Task {
            await setupCache()
            try? await loadSettings()
        }
    }
    
    private func setupCache() {
        super.setupCache(cache)
    }
    
    func loadNotifications() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Check cache first
        if let notifications = getCachedValue(from: cache, forKey: "notifications", duration: cacheDuration) {
            self.notifications = notifications
            return
        }
        
        // Fetch from network
        let response = try await supabase.database
            .from("notifications")
            .select()
            .eq(column: "user_id", value: try validateUser())
            .order(column: "created_at", ascending: false)
            .execute()
        
        guard let data = response.data else {
            return
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        notifications = try decoder.decode([UserNotification].self, from: jsonData)
        
        // Update cache
        setCachedValue(notifications, in: cache, forKey: "notifications")
    }
    
    func markAsRead(_ notification: UserNotification) async throws {
        guard let index = notifications.firstIndex(where: { $0.id == notification.id }) else {
            return
        }
        
        try await supabase.database
            .from("notifications")
            .update(values: ["is_read": true])
            .eq(column: "id", value: notification.id)
            .execute()
        
        notifications[index].read = true
    }
    
    func markAllAsRead() async throws {
        try await supabase.database
            .from("notifications")
            .update(values: ["is_read": true])
            .eq(column: "user_id", value: try validateUser())
            .execute()
        
        for index in notifications.indices {
            notifications[index].read = true
        }
    }
    
    func deleteNotification(_ notification: UserNotification) async throws {
        try await supabase.database
            .from("notifications")
            .delete()
            .eq(column: "id", value: notification.id)
            .execute()
        
        notifications.removeAll { $0.id == notification.id }
    }
    
    func loadSettings() async throws {
        let response = try await supabase.database
            .from("notification_settings")
            .select()
            .eq(column: "user_id", value: try validateUser())
            .single()
            .execute()
        
        if let data = response.data {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            deviceSettings = try decoder.decode(NotificationSettings.self, from: jsonData)
        }
    }
    
    func updateSettings() async throws {
        try await supabase.database
            .from("notification_settings")
            .upsert(values: [
                "user_id": try validateUser(),
                "notifications_enabled": deviceSettings.notificationsEnabled,
                "course_updates_enabled": deviceSettings.courseUpdatesEnabled,
                "test_reminders_enabled": deviceSettings.testRemindersEnabled,
                "weekly_summaries_enabled": deviceSettings.weeklySummariesEnabled
            ])
            .execute()
    }
} 