import Foundation
import Supabase

@MainActor
class NotificationsViewModel: ObservableObject {
    private let supabase: SupabaseClient
    private let userId: UUID
    
    @Published var notifications: [UserNotification] = []
    @Published var deviceSettings = DeviceSettings.default
    @Published var error: Error?
    @Published var isLoading = false
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
    }
    
    func loadSettings() async {
        isLoading = true
        do {
            let response: PostgrestResponse<UserDevice> = try await supabase
                .from("user_devices")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
            
            deviceSettings = response.value.settings ?? .default
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    func updateSettings() async {
        do {
            try await supabase
                .from("user_devices")
                .update(["settings": deviceSettings])
                .eq("user_id", value: userId)
                .execute()
        } catch {
            self.error = error
        }
    }
    
    func fetchNotifications() async {
        isLoading = true
        do {
            let response: PostgrestResponse<[UserNotification]> = try await supabase
                .from("notifications")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
            
            notifications = response.value
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    func markAsRead(_ notification: UserNotification) async {
        do {
            let updateData: [String: String] = ["status": UserNotification.NotificationStatus.read.rawValue]
            
            try await supabase
                .from("notifications")
                .update(updateData)
                .eq("id", value: notification.id)
                .execute()
            
            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                var updatedNotification = notification
                updatedNotification.status = .read
                notifications[index] = updatedNotification
            }
        } catch {
            self.error = error
        }
    }
    
    func deleteNotification(_ notification: UserNotification) async {
        do {
            try await supabase
                .from("notifications")
                .delete()
                .eq("id", value: notification.id)
                .execute()
            
            notifications.removeAll { $0.id == notification.id }
        } catch {
            self.error = error
        }
    }
    
    func clearAll() async {
        do {
            try await supabase
                .from("notifications")
                .delete()
                .eq("user_id", value: userId)
                .execute()
            
            notifications = []
        } catch {
            self.error = error
        }
    }
}
