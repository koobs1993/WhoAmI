import SwiftUI
import Supabase

enum Tab {
    case dashboard, courses, tests, chat, profile
    
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
    @State private var showSettings = false
    
    var body: some View {
        TabView {
            NavigationView {
                Group {
                    if let userId = authManager.currentUserId {
                        DashboardView(
                            supabase: authManager.supabase,
                            userId: userId
                        )
                    } else {
                        Text("Please log in to view dashboard")
                    }
                }
            }
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            .tag(0)
            
            NavigationView {
                CourseListView(supabase: authManager.supabase)
                    .navigationTitle("Courses")
            }
            .tabItem {
                Label("Courses", systemImage: "book.fill")
            }
            .tag(1)
            
            NavigationView {
                Group {
                    if let userId = authManager.currentUserId {
                        ChatView(
                            supabase: authManager.supabase,
                            channelId: UUID(),
                            userId: userId
                        )
                        .toolbar {
                            ToolbarItem {
                                Button {
                                    showSettings.toggle()
                                } label: {
                                    Image(systemName: "gear")
                                }
                            }
                        }
                    } else {
                        Text("Please log in to access chat")
                    }
                }
            }
            .tabItem {
                Label("Chat", systemImage: "message.fill")
            }
            .tag(2)
            
            NavigationView {
                Group {
                    if let userId = authManager.currentUserId {
                        ProfileView(
                            supabase: authManager.supabase,
                            userId: userId
                        )
                    } else {
                        Text("Please log in to view profile")
                    }
                }
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
            }
        }
    }
} 