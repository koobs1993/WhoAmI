import Foundation
import Supabase
import GoTrue
import Models

@main
struct InsertExampleData {
    static func main() async throws {
        // Initialize Supabase client with actual values
        let client = SupabaseClient(
            supabaseURL: URL(string: "https://slygbgucywxtriatyuye.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNseWdiZ3VjeXd4dHJpYXR5dXllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQwNjk3MTYsImV4cCI6MjA0OTY0NTcxNn0.BEac7s59GHkFHXi8NiGfMFj7aVO4pG6eBIITzUcEBcE"
        )
        
        do {
            // Sign in with admin credentials
            print("🔐 Signing in...")
            let auth = try await client.auth.signIn(
                email: "kyle@whoami.ai",
                password: "whoami123"
            )
            
            let userId = auth.user.id
            print("✅ Signed in with ID: \(userId)")
            
            // Create example user profile
            let userProfile = UserProfile(
                userId: userId,
                firstName: "John",
                lastName: "Doe",
                email: "kyle@whoami.ai",
                bio: "Example user bio",
                location: "San Francisco, CA",
                interests: ["Psychology", "Self-improvement"]
            )
            
            // Create privacy settings
            let privacySettings = UserPrivacySettings(
                userId: userId,
                isPublic: true,
                showEmail: false,
                showLocation: true
            )
            
            // Create user stats
            let userStats = UserStats(
                userId: userId,
                coursesCompleted: 5,
                testsCompleted: 10,
                averageScore: 85.5,
                totalPoints: 1000
            )
            
            // Create dashboard items
            let dashboardItems = [
                DashboardItem(
                    userId: userId,
                    title: "Introduction to Psychology",
                    description: "Learn the basics of psychology",
                    type: .course,
                    status: .completed
                ),
                DashboardItem(
                    userId: userId,
                    title: "Personality Assessment",
                    description: "Complete your personality assessment",
                    type: .test,
                    status: .active
                )
            ]
            
            // Insert user profile
            try await client.from("user_profiles")
                .insert(userProfile)
                .execute()
            print("✅ Inserted user profile")
            
            // Insert privacy settings
            try await client.from("user_privacy_settings")
                .insert(privacySettings)
                .execute()
            print("✅ Inserted privacy settings")
            
            // Insert user stats
            try await client.from("user_stats")
                .insert(userStats)
                .execute()
            print("✅ Inserted user stats")
            
            // Insert dashboard items
            try await client.from("dashboard_items")
                .insert(dashboardItems)
                .execute()
            print("✅ Inserted dashboard items")
            
            print("✨ Successfully inserted all example data")
            
            // Sign out
            try await client.auth.signOut()
            print("👋 Signed out")
            
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
