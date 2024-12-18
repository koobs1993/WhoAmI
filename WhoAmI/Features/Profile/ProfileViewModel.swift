import Foundation
import Supabase

struct ProfileUpdateRequest: Codable {
    let firstName: String
    let lastName: String
    let displayName: String
    let bio: String
    let avatarUrl: String
    let location: String
    let website: String
    let socialLinks: String
    let interests: String
    let updatedAt: String
    
    init(from profile: UserProfile) {
        self.firstName = profile.firstName
        self.lastName = profile.lastName
        self.displayName = profile.displayName
        self.bio = profile.bio ?? ""
        self.avatarUrl = profile.avatarUrl ?? ""
        self.location = profile.location ?? ""
        self.website = profile.website ?? ""
        self.socialLinks = (try? JSONEncoder().encode(profile.socialLinks ?? [:]))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        self.interests = (try? JSONEncoder().encode(profile.interests ?? []))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        self.updatedAt = ISO8601DateFormatter().string(from: Date())
    }
    
    var dictionary: [String: String] {
        [
            "first_name": firstName,
            "last_name": lastName,
            "display_name": displayName,
            "bio": bio,
            "avatar_url": avatarUrl,
            "location": location,
            "website": website,
            "social_links": socialLinks,
            "interests": interests,
            "updated_at": updatedAt
        ]
    }
}

struct PrivacySettingsUpdateRequest: Codable {
    let isPublic: String
    let showEmail: String
    let showLocation: String
    let showActivity: String
    let showStats: String
    let updatedAt: String
    
    init(from settings: UserPrivacySettings) {
        self.isPublic = String(settings.isPublic)
        self.showEmail = String(settings.showEmail)
        self.showLocation = String(settings.showLocation)
        self.showActivity = String(settings.showActivity)
        self.showStats = String(settings.showStats)
        self.updatedAt = ISO8601DateFormatter().string(from: Date())
    }
    
    var dictionary: [String: String] {
        [
            "is_public": isPublic,
            "show_email": showEmail,
            "show_location": showLocation,
            "show_activity": showActivity,
            "show_stats": showStats,
            "updated_at": updatedAt
        ]
    }
}

@MainActor
class ProfileViewModel: ObservableObject {
    @Published private(set) var profile: UserProfile?
    @Published private(set) var settings: UserPrivacySettings?
    @Published private(set) var stats: UserStats?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let supabase: SupabaseClient
    private let userId: UUID
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
    }
    
    func fetchProfile() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: PostgrestResponse<UserProfile> = try await supabase.database
                .from("user_profiles")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
            
            profile = response.value
            
            let settingsResponse: PostgrestResponse<UserPrivacySettings> = try await supabase.database
                .from("user_privacy_settings")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
            
            settings = settingsResponse.value
            
            let statsResponse: PostgrestResponse<UserStats> = try await supabase.database
                .from("user_stats")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
            
            stats = statsResponse.value
        } catch {
            self.error = error
            throw error
        }
    }
    
    func updateProfile(_ profile: UserProfile) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let request = ProfileUpdateRequest(from: profile)
        
        try await supabase.database
            .from("user_profiles")
            .update(request.dictionary)
            .eq("id", value: profile.id.uuidString)
            .execute()
        
        self.profile = profile
    }
    
    func updatePrivacySettings(_ settings: UserPrivacySettings) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let request = PrivacySettingsUpdateRequest(from: settings)
        
        try await supabase.database
            .from("user_privacy_settings")
            .update(request.dictionary)
            .eq("id", value: settings.id.uuidString)
            .execute()
        
        self.settings = settings
    }
    
    func deleteProfile() async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await supabase.database
            .from("user_profiles")
            .delete()
            .eq("id", value: profile?.id.uuidString ?? "")
            .execute()
        
        reset()
    }
    
    func reset() {
        profile = nil
        settings = nil
        stats = nil as UserStats?
    }
}
