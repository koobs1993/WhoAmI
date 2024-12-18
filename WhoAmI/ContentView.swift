import SwiftUI
import Supabase

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var reviewManager = ReviewPromptManager(supabase: Config.supabaseClient)
    @State private var showingNotificationPrompt = false
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView(authManager: authManager)
                    .onAppear {
                        reviewManager.incrementCount()
                    }
            } else {
                AuthView(supabase: Config.supabaseClient)
            }
        }
        .environmentObject(reviewManager)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager(supabase: Config.supabaseClient))
} 