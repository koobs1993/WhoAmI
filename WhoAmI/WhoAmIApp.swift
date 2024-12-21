import SwiftUI
import Supabase
import UIKit

@main
struct WhoAmIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager: AuthManager
    
    init() {
        let supabase = Config.supabaseClient
        _authManager = StateObject(wrappedValue: AuthManager(supabase: supabase))
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                MainTabView()
                    .environmentObject(authManager)
            } else {
                AuthView(supabase: Config.supabaseClient)
                    .environmentObject(authManager)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    WhoAmIApp()
}
