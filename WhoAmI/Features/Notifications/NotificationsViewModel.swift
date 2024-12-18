import Foundation
import Supabase

struct NotificationItem: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let title: String
    let message: String
    let type: String
    var read: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case message
        case type
        case read
        case createdAt = "created_at"
    }
}

struct UserSettingsRequest: Codable {
    let userId: UUID
    let notificationsEnabled: Bool
    let courseUpdatesEnabled: Bool
    let testRemindersEnabled: Bool
    let weeklySummariesEnabled: Bool
    let analyticsEnabled: Bool
    let trackingAuthorized: Bool
    let darkModeEnabled: Bool
    let hapticsEnabled: Bool
    let fontSize: Int
    let soundEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case notificationsEnabled = "notifications_enabled"
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

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    @Published var deviceSettings: UserDeviceSettings
    @Published var isLoading = false
    @Published var error: Error?
    
    private let supabase: SupabaseClient
    private let userId: UUID
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
        self.deviceSettings = UserDeviceSettings()
    }
    
    func loadSettings() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: PostgrestResponse<[UserDeviceSettings]> = try await supabase.database
                .from("user_settings")
                .select()
                .eq("user_id", value: userId.uuidString)
                .limit(1)
                .execute()
            
            if let settings = response.value.first {
                await MainActor.run {
                    self.deviceSettings = settings
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func fetchNotifications() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: PostgrestResponse<[NotificationItem]> = try await supabase.database
                .from("notifications")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
            
            await MainActor.run {
                self.notifications = response.value
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func saveDeviceSettings() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let request = UserSettingsRequest(
                userId: userId,
                notificationsEnabled: deviceSettings.notificationsEnabled,
                courseUpdatesEnabled: deviceSettings.courseUpdatesEnabled,
                testRemindersEnabled: deviceSettings.testRemindersEnabled,
                weeklySummariesEnabled: deviceSettings.weeklySummariesEnabled,
                analyticsEnabled: deviceSettings.analyticsEnabled,
                trackingAuthorized: deviceSettings.trackingAuthorized,
                darkModeEnabled: deviceSettings.darkModeEnabled,
                hapticsEnabled: deviceSettings.hapticsEnabled,
                fontSize: deviceSettings.fontSize,
                soundEnabled: deviceSettings.soundEnabled
            )
            
            try await supabase.database
                .from("user_settings")
                .upsert(request)
                .execute()
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func markAsRead(_ notification: NotificationItem) async {
        do {
            try await supabase.database
                .from("notifications")
                .update(["read": true])
                .eq("id", value: notification.id.uuidString)
                .execute()
            
            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                await MainActor.run {
                    notifications[index].read = true
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func clearError() {
        error = nil
    }
}
