import SwiftUI
import Supabase

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var reviewManager: ReviewPromptManager
    @State private var showingNotificationPrompt = false
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView(supabase: Config.supabaseClient)
                    .onAppear {
                        reviewManager.incrementActionCount()
                    }
            } else {
                AuthView(supabase: Config.supabaseClient)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager(supabase: Config.supabaseClient))
        .environmentObject(ReviewPromptManager())
} 