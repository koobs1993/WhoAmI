import Foundation
import Supabase

struct Config {
    static let supabaseURL = URL(string: "https://slygbgucywxtriatyuye.supabase.co")!
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNseWdiZ3VjeXd4dHJpYXR5dXllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQwNjk3MTYsImV4cCI6MjA0OTY0NTcxNn0.BEac7s59GHkFHXi8NiGfMFj7aVO4pG6eBIITzUcEBcE"
    
    static let supabaseClient = SupabaseClient(
        supabaseURL: supabaseURL,
        supabaseKey: supabaseAnonKey
    )
    
    static let openAIAPIKey = "YOUR_OPENAI_API_KEY"
    
    static let defaultSettings = UserDeviceSettings(
        id: UUID(),
        userId: UUID(), // This will be replaced with actual user ID when used
        notificationsEnabled: true,
        courseUpdatesEnabled: true,
        testRemindersEnabled: true,
        weeklySummariesEnabled: true,
        analyticsEnabled: true,
        trackingAuthorized: true,
        darkModeEnabled: false,
        hapticsEnabled: true,
        fontSize: 16,
        soundEnabled: true,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let defaultPrivacySettings = UserPrivacySettings(
        id: UUID(),
        userId: UUID(), // This will be replaced with actual user ID when used
        isPublic: true,
        showEmail: false,
        showLocation: false,
        showActivity: true,
        showStats: true,
        createdAt: Date(),
        updatedAt: Date()
    )
}
