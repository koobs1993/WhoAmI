import Foundation
import Supabase

@MainActor
class ProfileViewModel: ObservableObject {
    private let supabase: SupabaseClient
    @Published private(set) var profile: UserProfile?
    @Published private(set) var settings: UserSettings?
    @Published private(set) var stats: UserStats?
    @Published private(set) var error: Error?
    @Published private(set) var isLoading = false
    
    private let userId: UUID
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
    }
    
    func loadProfile() async {
        isLoading = true
        error = nil
        
        do {
            let response: PostgrestResponse<UserProfile> = try await supabase
                .from("profiles")
                .select()
                .single()
                .execute()
            
            profile = response.value
            await loadSettings()
            await loadStats()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func loadSettings() async {
        do {
            let response: PostgrestResponse<UserSettings> = try await supabase
                .from("user_settings")
                .select()
                .single()
                .execute()
            
            settings = response.value
        } catch {
            settings = Config.defaultSettings
            self.error = error
        }
    }
    
    func loadStats() async {
        do {
            let response: PostgrestResponse<UserStats> = try await supabase
                .from("user_stats")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
            
            stats = response.value
        } catch {
            self.error = error
        }
    }
    
    func updateProfile(_ profile: UserProfile) async throws {
        isLoading = true
        error = nil
        
        do {
            let _: PostgrestResponse<UserProfile> = try await supabase
                .from("profiles")
                .update(profile)
                .eq("id", value: profile.id)
                .execute()
            
            self.profile = profile
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    func uploadProfileImage(imageData: Data, path: String) async throws -> String {
        do {
            try await supabase.storage
                .from("avatars")
                .upload(path, data: imageData, options: FileOptions(contentType: "image/jpeg"))
            
            let response = try await supabase.storage
                .from("avatars")
                .createSignedURL(path: path, expiresIn: 3600)
            
            return response.absoluteString
        } catch {
            self.error = error
            throw error
        }
    }
    
    func updateSettings(_ settings: UserSettings) async throws {
        isLoading = true
        error = nil
        
        do {
            try await supabase
                .from("user_settings")
                .upsert(settings)
                .execute()
            
            self.settings = settings
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    func signOut() async throws {
        isLoading = true
        error = nil
        
        do {
            try await supabase.auth.signOut()
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    func deleteAccount() async throws {
        isLoading = true
        error = nil
        
        do {
            try await supabase.auth.signOut()
            
            let _: PostgrestResponse<Void> = try await supabase
                .from("profiles")
                .delete()
                .execute()
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    @MainActor
    func fetchProfile() async throws {
        let response: PostgrestResponse<UserProfile> = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
        
        profile = response.value
        
        let settingsResponse: PostgrestResponse<UserSettings> = try await supabase
            .from("user_settings")
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
        
        settings = settingsResponse.value
        
        let statsResponse: PostgrestResponse<UserStats> = try await supabase
            .from("user_stats")
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
        
        stats = statsResponse.value
    }
}
