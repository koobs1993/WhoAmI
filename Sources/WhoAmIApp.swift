import SwiftUI
import Supabase

@main
struct WhoAmIApp: App {
    @StateObject private var authViewModel = AuthViewModel(supabase: SupabaseClient.shared)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
} 