import Foundation
import Supabase
import UserNotifications

@MainActor
class PushNotificationHandler: BaseService {
    static let shared = PushNotificationHandler()
    private let cache = NSCache<NSString, CacheEntry<[UserDevice]>>()
    private let cacheDuration: TimeInterval = 300 // 5 minutes
    
    private override init() {
        super.init()
        setupCache(cache)
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
        try await upsert(into: "user_devices", values: [
            "user_id": try validateUser(),
            "device_token": token,
            "platform": "macos",
            "device_type": "macos",
            "is_active": true,
            "last_active": Date()
        ])
        
        invalidateCache()
    }
    
    func fetchUserDevices() async throws -> [UserDevice] {
        if let devices = getCachedValue(from: cache, forKey: "user_devices", duration: cacheDuration) {
            return devices
        }
        
        let devices: [UserDevice] = try await select(from: "user_devices")
            .eq("user_id", value: try validateUser())
            .eq("is_active", value: true)
            .execute()
            .value
        
        setCachedValue(devices, in: cache, forKey: "user_devices")
        return devices
    }
    
    func deactivateDevice(deviceId: Int) async throws {
        let updateData: [String: Any] = [
            "is_active": false,
            "updated_at": Date()
        ]
        
        try await supabase
            .from("user_devices")
            .update(updateData)
            .eq("id", value: deviceId)
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