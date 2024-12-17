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
        analyticsEnabled: false,
        trackingAuthorized: false,
        theme: "system",
        fontSize: 16,
        notifications: true,
        soundEnabled: true
    )
}
