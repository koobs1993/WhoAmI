import SwiftUI
import Supabase

// MARK: - Appearance Section
private struct AppearanceSection: View {
    @Binding var theme: AppTheme
    
    var body: some View {
        Section("Appearance") {
            Picker("Theme", selection: $theme) {
                Text("System").tag(AppTheme.system)
                Text("Light").tag(AppTheme.light)
                Text("Dark").tag(AppTheme.dark)
            }
            .pickerStyle(.segmented)
        }
    }
}

// MARK: - Notifications Section
private struct NotificationsSection: View {
    @Binding var notifications: NotificationSettings
    
    var body: some View {
        Section("Notifications") {
            Toggle("Push Notifications", isOn: $notifications.pushEnabled)
            Toggle("Email Notifications", isOn: $notifications.emailEnabled)
            Toggle("Test Reminders", isOn: $notifications.testReminders)
            Toggle("Course Updates", isOn: $notifications.courseUpdates)
            Toggle("Weekly Digest", isOn: $notifications.weeklyDigest)
        }
    }
}

// MARK: - Accessibility Section
private struct AccessibilitySection: View {
    @Binding var accessibility: AccessibilitySettings
    
    var body: some View {
        Section("Accessibility") {
            Toggle("Reduce Motion", isOn: $accessibility.reduceMotion)
            Toggle("Increase Contrast", isOn: $accessibility.increaseContrast)
            Toggle("Larger Text", isOn: $accessibility.largerText)
            Toggle("Speak Screen", isOn: $accessibility.speakScreen)
        }
    }
}

// MARK: - Privacy Section
private struct PrivacySection: View {
    @Binding var privacy: PrivacySettings
    
    var body: some View {
        Section("Privacy") {
            Picker("Profile Visibility", selection: $privacy.profileVisibility) {
                Text("Public").tag(ProfileVisibility.public)
                Text("Friends Only").tag(ProfileVisibility.friends)
                Text("Private").tag(ProfileVisibility.private)
            }
            
            Toggle("Share Progress", isOn: $privacy.shareProgress)
            Toggle("Share Results", isOn: $privacy.shareResults)
        }
    }
}

// MARK: - Language and Region Section
private struct LanguageRegionSection: View {
    @Binding var language: String
    @Binding var timezone: String
    let availableLanguages: [(code: String, name: String)]
    
    var body: some View {
        Section("Language & Region") {
            Picker("Language", selection: $language) {
                ForEach(availableLanguages, id: \.code) { language in
                    Text(language.name).tag(language.code)
                }
            }
            
            Picker("Time Zone", selection: $timezone) {
                ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { timezone in
                    Text(timezone).tag(timezone)
                }
            }
        }
    }
}

// MARK: - Account Actions Section
private struct AccountActionsSection: View {
    let onDeleteAccount: () -> Void
    
    var body: some View {
        Section {
            Button(role: .destructive, action: onDeleteAccount) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Account")
                }
            }
        }
    }
}

// MARK: - Main View
struct UserSettingsView: View {
    @StateObject private var viewModel: UserSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(supabase: SupabaseClient, userId: UUID) {
        _viewModel = StateObject(wrappedValue: UserSettingsViewModel(supabase: supabase, userId: userId))
    }
    
    var body: some View {
        Form {
            AppearanceSection(theme: $viewModel.settings.theme)
            NotificationsSection(notifications: $viewModel.settings.notifications)
            AccessibilitySection(accessibility: $viewModel.settings.accessibility)
            PrivacySection(privacy: $viewModel.settings.privacy)
            LanguageRegionSection(
                language: $viewModel.settings.language,
                timezone: $viewModel.settings.timezone,
                availableLanguages: viewModel.availableLanguages
            )
            AccountActionsSection {
                viewModel.showDeleteAccountAlert = true
            }
        }
        .navigationTitle("Settings")
        .alert("Delete Account", isPresented: $viewModel.showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteAccount()
                }
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .onChange(of: viewModel.settings) { _ in
            Task {
                await viewModel.saveSettings()
            }
        }
        .task {
            await viewModel.loadSettings()
        }
    }
}

#Preview {
    NavigationView {
        UserSettingsView(
            supabase: Config.supabaseClient,
            userId: UUID()
        )
    }
}
