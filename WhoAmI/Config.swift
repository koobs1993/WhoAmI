import Foundation
import Supabase

enum Config {
    static let supabaseUrl = URL(string: "https://slwgbgujcywxtrituyue.supabase.co")!
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNseWdiZ3VjeXd4dHJpYXR5dXllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQwNjk3MTYsImV4cCI6MjA0OTY0NTcxNn0.BEac7s59GHkFHXi8NiGfMFj7aVO4pG6eBIITzUcEBcE"
    
    static var supabaseClient: SupabaseClient {
        // Create client with default options
        return SupabaseClient(
            supabaseURL: supabaseUrl,
            supabaseKey: supabaseAnonKey
        )
    }
    
    #if DEBUG
    static var previewClient: SupabaseClient {
        supabaseClient // Use same configured client for previews
    }
    #endif
    
    static let defaultSettings = UserSettings(
        theme: .system,
        notifications: .default,
        accessibility: .default,
        privacy: .default,
        language: Locale.current.language.languageCode?.identifier ?? "en",
        timezone: TimeZone.current.identifier
    )
}
