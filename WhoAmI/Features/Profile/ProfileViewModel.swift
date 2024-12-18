import Foundation
import Supabase
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    private let supabase: SupabaseClient
    private let userId: UUID
    
    @Published var profile: UserProfile?
    @Published var privacySettings: UserPrivacySettings?
    @Published var stats: UserStats?
    @Published var error: Error?
    @Published var isLoading = false
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
        Task {
            await fetchProfile()
            await fetchPrivacySettings()
            await fetchStats()
        }
    }
    
    func fetchProfile() async {
        isLoading = true
        do {
            print("Fetching profile for user: \(userId)")
            let response: PostgrestResponse<UserProfile> = try await supabase.from("user_profiles")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
            
            profile = response.value
            print("Fetched profile: \(String(describing: profile))")
        } catch {
            print("Error fetching profile: \(error)")
            self.error = error
        }
        isLoading = false
    }
    
    func fetchPrivacySettings() async {
        do {
            print("Fetching privacy settings")
            let response: PostgrestResponse<UserPrivacySettings> = try await supabase.from("user_privacy_settings")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
            
            privacySettings = response.value
            print("Fetched privacy settings: \(String(describing: privacySettings))")
        } catch {
            print("Error fetching privacy settings: \(error)")
            self.error = error
        }
    }
    
    func fetchStats() async {
        do {
            print("Fetching user stats")
            let response: PostgrestResponse<UserStats> = try await supabase.from("user_stats")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
            
            stats = response.value
            print("Fetched stats: \(String(describing: stats))")
        } catch {
            print("Error fetching stats: \(error)")
            self.error = error
        }
    }
    
    func updateProfile(_ updatedProfile: UserProfile) async {
        isLoading = true
        do {
            print("Updating profile")
            try await supabase.from("user_profiles")
                .update([
                    "first_name": updatedProfile.firstName,
                    "last_name": updatedProfile.lastName,
                    "bio": updatedProfile.bio ?? "",
                    "updated_at": ISO8601DateFormatter().string(from: Date())
                ])
                .eq("id", value: updatedProfile.id.uuidString)
                .execute()
            
            profile = updatedProfile
            print("Profile updated successfully")
        } catch {
            print("Error updating profile: \(error)")
            self.error = error
        }
        isLoading = false
    }
    
    func updatePrivacySettings(_ settings: UserPrivacySettings) async {
        do {
            print("Updating privacy settings")
            try await supabase.from("user_privacy_settings")
                .update([
                    "show_profile": settings.showProfile,
                    "show_activity": settings.showActivity,
                    "show_stats": settings.showStats,
                    "updated_at": Date()
                ])
                .eq("id", value: settings.id.uuidString)
                .execute()
            
            privacySettings = settings
            print("Privacy settings updated successfully")
        } catch {
            print("Error updating privacy settings: \(error)")
            self.error = error
        }
    }
}
