import Foundation
import Supabase
#if os(iOS)
import UIKit
#else
import AppKit
#endif

@MainActor
class PushNotificationHandler: ObservableObject {
    private let supabase: SupabaseClient
    private let userId: UUID
    
    @Published var isRegistered = false
    @Published var error: Error?
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
    }
    
    func registerDevice(token: String) async {
        do {
            let deviceName = await getDeviceName()
            let osVersion = await getOSVersion()
            let appVersion = await getAppVersion()
            
            let device = UserDevice(
                id: UUID(),
                userId: userId,
                name: deviceName,
                platform: getPlatform(),
                osVersion: osVersion,
                appVersion: appVersion,
                lastActive: Date(),
                pushToken: token,
                settings: .default
            )
            
            try await supabase
                .from("user_devices")
                .upsert(device)
                .execute()
            
            isRegistered = true
        } catch {
            self.error = error
            isRegistered = false
        }
    }
    
    func unregisterDevice(token: String) async {
        do {
            try await supabase
                .from("user_devices")
                .delete()
                .eq("push_token", value: token)
                .execute()
            
            isRegistered = false
        } catch {
            self.error = error
        }
    }
    
    private func getPlatform() -> DevicePlatform {
        #if os(iOS)
        return .iOS
        #else
        return .macOS
        #endif
    }
    
    private func getDeviceName() async -> String {
        #if os(iOS)
        return UIDevice.current.name
        #else
        return Host.current().localizedName ?? "Unknown Device"
        #endif
    }
    
    private func getOSVersion() async -> String {
        #if os(iOS)
        return UIDevice.current.systemVersion
        #else
        return ProcessInfo.processInfo.operatingSystemVersionString
        #endif
    }
    
    private func getAppVersion() async -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
}
