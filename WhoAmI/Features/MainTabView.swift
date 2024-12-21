import SwiftUI
import Supabase

@available(iOS 16.0, *)
struct MainTabView: View {
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        TabView {
            if let userId = authManager.currentUser?.id.uuidString {
                DashboardView(supabase: authManager.supabase, userId: userId)
                    .tabItem {
                        Label("Dashboard", systemImage: "house")
                    }
                
                CourseListView(supabase: authManager.supabase, userId: userId)
                    .tabItem {
                        Label("Courses", systemImage: "book")
                    }
                
                ProfileView(supabase: authManager.supabase, userId: userId)
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            } else {
                ContentUnavailableView(
                    "Sign In Required",
                    systemImage: "person.crop.circle.badge.exclamationmark",
                    description: Text("Please sign in to access the app")
                )
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthManager(supabase: Config.previewClient))
    }
}
#endif
