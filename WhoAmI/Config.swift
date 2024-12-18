import Foundation
import Supabase

struct Config {
    static let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
    static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
    
    static let supabaseClient = SupabaseClient(
        supabaseURL: supabaseURL,
        supabaseKey: supabaseAnonKey
    )
    
    static let openAIAPIKey = "YOUR_OPENAI_API_KEY"
    
    static let defaultSettings = UserDeviceSettings(
        notificationsEnabled: true,
        theme: "system",
        language: "en",
        courseUpdatesEnabled: true,
        testRemindersEnabled: true,
        weeklySummariesEnabled: true,
        analyticsEnabled: false,
        trackingAuthorized: false,
        darkModeEnabled: false,
        hapticsEnabled: true,
        fontSize: 16,
        soundEnabled: true
    )
    
    static let defaultPrivacySettings = UserPrivacySettings(
        showProfile: true,
        showActivity: true,
        allowMessages: true,
        shareProgress: true
    )
}
