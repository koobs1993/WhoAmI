import SwiftUI
import Supabase

@MainActor
class UserSettingsViewModel: ObservableObject {
    private let supabase: SupabaseClient
    private let userId: UUID
    
    @Published var settings = UserSettings.default
    @Published var error: Error?
    @Published var isLoading = false
    @Published var showError = false
    @Published var showDeleteAccountAlert = false
    @Published var errorMessage: String?
    
    let availableLanguages = [
        (code: "en", name: "English"),
        (code: "es", name: "Spanish"),
        (code: "fr", name: "French"),
        (code: "de", name: "German"),
        (code: "it", name: "Italian"),
        (code: "ja", name: "Japanese"),
        (code: "ko", name: "Korean"),
        (code: "zh", name: "Chinese")
    ]
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
    }
    
    func loadSettings() async {
        isLoading = true
        do {
            let response: PostgrestResponse<UserSettings> = try await supabase
                .from("user_settings")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
            
            settings = response.value
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    func saveSettings() async {
        do {
            let _: PostgrestResponse<UserSettings> = try await supabase
                .from("user_settings")
                .upsert(settings)
                .execute()
        } catch {
            self.error = error
        }
    }
    
    func updateNotificationSettings(_ notifications: NotificationSettings) async {
        settings.notifications = notifications
        await saveSettings()
    }
    
    func updateAccessibilitySettings(_ accessibility: AccessibilitySettings) async {
        settings.accessibility = accessibility
        await saveSettings()
    }
    
    func updatePrivacySettings(_ privacy: PrivacySettings) async {
        settings.privacy = privacy
        await saveSettings()
    }
    
    func resetSettings() async {
        settings = UserSettings.default
        await saveSettings()
    }
    
    func deleteAccount() async {
        do {
            try await supabase.auth.signOut()
            
            let _: PostgrestResponse<Void> = try await supabase
                .from("user_settings")
                .delete()
                .eq("user_id", value: userId)
                .execute()
        } catch {
            self.error = error
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }
}
