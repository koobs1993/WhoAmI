import SwiftUI
import Supabase

@available(macOS 12.0, *)
struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            if let userId = authManager.currentUser?.id {
                // Dashboard Tab
                NavigationView {
                    DashboardView(supabase: authManager.supabase)
                }
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
                
                // Courses Tab
                NavigationView {
                    CourseListView(supabase: authManager.supabase)
                }
                .tabItem {
                    Label("Courses", systemImage: "book.fill")
                }
                .tag(1)
                
                // Tests Tab
                NavigationView {
                    TestListView(supabase: authManager.supabase)
                }
                .tabItem {
                    Label("Tests", systemImage: "checklist")
                }
                .tag(2)
                
                // Chat Tab
                if #available(macOS 13.0, *) {
                    NavigationView {
                        ChatView(
                            chatService: ChatService(supabase: authManager.supabase),
                            userId: userId
                        )
                    }
                    .tabItem {
                        Label("Chat", systemImage: "message.fill")
                    }
                    .tag(3)
                } else {
                    // Fallback view for older OS versions
                    Text("Chat feature requires macOS 13.0 or later")
                        .tabItem {
                            Label("Chat", systemImage: "message.fill")
                        }
                        .tag(3)
                }
                
                // Profile Tab
                NavigationView {
                    ProfileView(supabase: authManager.supabase, userId: userId)
                }
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
            }
        }
        .onAppear {
            // Set the default selected tab to Dashboard
            selectedTab = 0
            
            // Set platform-specific UI appearance
            #if os(iOS)
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            #endif
        }
    }
}

#if DEBUG
@available(macOS 12.0, *)
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthManager(supabase: Config.supabaseClient))
    }
}
#endif
