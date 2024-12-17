#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import SwiftUI
import UserNotifications
import Supabase

protocol AppDelegateProtocol: UNUserNotificationCenterDelegate {
    var supabase: SupabaseClient { get }
    func registerForPushNotifications()
    func handleNotification(_ userInfo: [AnyHashable: Any]) async
}

extension AppDelegateProtocol {
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
                return
            }
            
            if granted {
                DispatchQueue.main.async {
                    #if os(iOS)
                    UIApplication.shared.registerForRemoteNotifications()
                    #elseif os(macOS)
                    NSApplication.shared.registerForRemoteNotifications()
                    #endif
                }
            }
        }
    }
    
    func handleNotification(_ userInfo: [AnyHashable: Any]) async {
        guard let notificationId = userInfo["notification_id"] as? String else { return }
        do {
            try await supabase.recordNotificationInteraction(notificationId: notificationId)
        } catch {
            print("Error recording notification interaction: \(error)")
        }
    }
}

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate, AppDelegateProtocol {
    let supabase: SupabaseClient = Config.supabaseClient
    
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        registerForPushNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        Task {
            do {
                try await supabase.saveDeviceToken(token, platform: "ios")
            } catch {
                print("Error saving device token: \(error)")
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse) async {
        await handleNotification(response.notification.request.content.userInfo)
    }
}
#elseif os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate, AppDelegateProtocol {
    let supabase: SupabaseClient
    
    override init() {
        self.supabase = Config.supabaseClient
        super.init()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
        registerForPushNotifications()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up any resources
    }
    
    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        Task {
            do {
                guard let session = try? await supabase.auth.session else {
                    print("No authenticated session")
                    return
                }
                
                let userId = session.user.id.uuidString
                
                try await supabase.database
                    .from("device_tokens")
                    .upsert(values: [
                        "user_id": userId,
                        "token": tokenString,
                        "platform": "macos",
                        "created_at": Date().ISO8601Format(),
                        "updated_at": Date().ISO8601Format()
                    ])
                    .execute()
                
                print("Successfully registered device token")
            } catch {
                print("Error registering device token: \(error)")
            }
        }
    }
    
    func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
        print("Received remote notification: \(userInfo)")
        
        Task {
            do {
                guard let session = try? await supabase.auth.session else {
                    print("No authenticated session")
                    return
                }
                
                let userId = session.user.id.uuidString
                let notificationData = try JSONSerialization.data(withJSONObject: userInfo)
                let notificationString = String(data: notificationData, encoding: .utf8) ?? "{}"
                
                try await supabase.database
                    .from("notification_interactions")
                    .insert(values: [
                        "user_id": userId,
                        "notification_data": notificationString,
                        "interaction_type": "received",
                        "created_at": Date().ISO8601Format()
                    ])
                    .execute()
                
                print("Successfully logged notification interaction")
            } catch {
                print("Error logging notification interaction: \(error)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse) async {
        await handleNotification(response.notification.request.content.userInfo)
    }
}
#endif

// MARK: - Supabase Extensions
extension SupabaseClient {
    func saveDeviceToken(_ token: String, platform: String) async throws {
        let session = try await auth.session
        let userId = session.user.id
        
        try await database.from("device_tokens")
            .upsert(values: [
                "user_id": userId.uuidString,
                "device_token": token,
                "platform": platform,
                "last_seen": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()
    }
    
    func recordNotificationInteraction(notificationId: String) async throws {
        let session = try await auth.session
        let userId = session.user.id
        
        try await database.from("notification_interactions")
            .insert(values: [
                "notification_id": notificationId,
                "user_id": userId.uuidString,
                "interaction_type": "opened",
                "interaction_date": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()
    }
} 