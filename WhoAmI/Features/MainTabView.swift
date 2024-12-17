import SwiftUI
import Supabase
@_spi(AuthUI) import Auth

enum Tab {
    case dashboard
    case courses
    case tests
    case chat
    case profile
    
    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .courses: return "Courses"
        case .tests: return "Tests"
        case .chat: return "Chat"
        case .profile: return "Profile"
        }
    }
    
    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .courses: return "book.fill"
        case .tests: return "checklist"
        case .chat: return "message.fill"
        case .profile: return "person.fill"
        }
    }
}

struct MainTabView: View {
    @StateObject var authManager: AuthManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView {
            NavigationView {
                if let userId = try? authManager.supabase.auth.session?.user.id {
                    DashboardView(
                        supabase: authManager.supabase,
                        userId: userId
                    )
                } else {
                    Text("Please log in to view dashboard")
                }
            }
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            .tag(0)
            
            NavigationView {
                CourseListView(
                    viewModel: CourseViewModel(
                        supabase: authManager.supabase
                    )
                )
            }
            .tabItem {
                Label("Courses", systemImage: "book.fill")
            }
            .tag(1)
            
            NavigationView {
                ChatView(
                    viewModel: ChatViewModel(
                        supabase: authManager.supabase,
                        userId: UUID()
                    )
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NotificationButton(
                            supabase: authManager.supabase,
                            userId: UUID().uuidString
                        )
                    }
                }
            }
            .tabItem {
                Label("Chat", systemImage: "message.fill")
            }
            .tag(2)
            
            NavigationView {
                ProfileView(
                    viewModel: ProfileViewModel(
                        supabase: authManager.supabase,
                        userId: UUID()
                    )
                )
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(3)
        }
    }
}

#Preview {
    MainTabView(
        authManager: AuthManager(supabase: Config.supabaseClient)
    )
}

struct NotificationButton: View {
    let supabase: SupabaseClient
    let userId: String
    
    var body: some View {
        Button(action: {
            // Implement notification button action
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                
                // Implement unread count logic
            }
        }
    }
} 