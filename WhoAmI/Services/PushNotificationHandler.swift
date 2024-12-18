import Foundation
import Supabase
import UserNotifications

@MainActor
class PushNotificationHandler: BaseService {
    static let shared = PushNotificationHandler(supabase: Config.supabaseClient)
    
    private let cache = NSCache<NSString, CacheEntry<[UserDevice]>>()
    private let cacheDuration: TimeInterval = 300 // 5 minutes
    
    private override init(supabase: SupabaseClient) {
        super.init(supabase: supabase)
        Task { @MainActor in
            setupCache(cache)
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                PlatformUtils.registerForRemoteNotifications()
            }
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            }
        }
    }
    
    func handleNotification(_ notification: [AnyHashable: Any], completion: @escaping () -> Void) {
        if let type = notification["type"] as? String {
            switch type {
            case "message":
                handleMessageNotification(notification)
            case "reminder":
                handleReminderNotification(notification)
            case "course":
                handleCourseNotification(notification)
            default:
                print("Unknown notification type: \(type)")
            }
        }
        completion()
    }
    
    // MARK: - Device Management
    
    func registerDevice(token: String) async throws {
        let userId = try await validateUser()
        let values = [
            "user_id": userId.uuidString,
            "device_token": token,
            "platform": "macos",
            "device_type": "macos",
            "is_active": "true",
            "last_active": ISO8601DateFormatter().string(from: Date())
        ]
        
        try await supabase.database
            .from("user_devices")
            .upsert(values: values)
            .execute()
    }
    
    func fetchUserDevices() async throws -> [UserDevice] {
        if let devices = getCachedValue(from: cache, forKey: "user_devices") {
            return devices
        }
        
        let response = try await supabase.database
            .from("user_devices")
            .select()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let data = try JSONSerialization.data(withJSONObject: response.underlyingResponse.data)
        let devices = try decoder.decode([UserDevice].self, from: data)
        
        setCachedValue(devices, in: cache, forKey: "user_devices")
        return devices
    }
    
    func updateDeviceStatus(deviceId: Int, isActive: Bool) async throws {
        let updateData = [
            "is_active": String(isActive),
            "last_active": ISO8601DateFormatter().string(from: Date())
        ]
        
        try await supabase.database
            .from("user_devices")
            .update(values: updateData)
            .eq(column: "id", value: deviceId)
            .execute()
    }
    
    // MARK: - Notification Handlers
    
    private func handleMessageNotification(_ notification: [AnyHashable: Any]) {
        guard let messageId = notification["message_id"] as? String else { return }
        print("Handling message notification: \(messageId)")
        // Add your message handling logic here
    }
    
    private func handleReminderNotification(_ notification: [AnyHashable: Any]) {
        guard let reminderId = notification["reminder_id"] as? String else { return }
        print("Handling reminder notification: \(reminderId)")
        // Add your reminder handling logic here
    }
    
    private func handleCourseNotification(_ notification: [AnyHashable: Any]) {
        guard let courseId = notification["course_id"] as? String else { return }
        print("Handling course notification: \(courseId)")
        // Add your course handling logic here
    }
    
    // MARK: - Local Notifications
    
    func scheduleLocalNotification(title: String, body: String, identifier: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Cache Management
    
    private func invalidateCache() {
        cache.removeObject(forKey: "user_devices" as NSString)
    }
} 