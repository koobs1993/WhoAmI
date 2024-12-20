import SwiftUI

struct ProfileAvatar: View {
    let profile: UserProfile
    
    var body: some View {
        ZStack {
            if let avatarUrl = profile.avatarUrl {
                AsyncImage(url: URL(string: avatarUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
            } else {
                Circle()
                    .foregroundStyle(.accent.opacity(0.2))
                Text(getInitials())
                    .font(.adaptiveTitle())
                    .fontWeight(.medium)
                    .foregroundStyle(.accent)
            }
        }
        .frame(width: 100, height: 100)
        .clipShape(Circle())
    }
    
    private func getInitials() -> String {
        let firstInitial = profile.firstName.prefix(1)
        let lastInitial = profile.lastName.prefix(1)
        return "\(firstInitial)\(lastInitial)"
    }
}

struct ProfileSettingsSection: View {
    let settings: UserSettings
    let onSettingsTap: () -> Void
    
    var body: some View {
        Section {
            Button(action: onSettingsTap) {
                VStack(spacing: 12) {
                    SettingRow(icon: "bell", title: "Notifications", value: settings.notifications.pushEnabled ? "On" : "Off")
                    SettingRow(icon: "eye", title: "Privacy", value: settings.privacy.profileVisibility.rawValue.capitalized)
                    SettingRow(icon: "globe", title: "Language", value: settings.language)
                    SettingRow(icon: "clock", title: "Timezone", value: settings.timezone)
                }
            }
            .foregroundStyle(.primary)
        } header: {
            Text("Settings")
                .font(.adaptiveHeadline())
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.blue)
            
            Text(title)
                .font(.adaptiveBody())
            
            Spacer()
            
            Text(value)
                .font(.adaptiveSubheadline())
                .foregroundStyle(.secondary)
            
            Image(systemName: "chevron.right")
                .font(.adaptiveCaption())
                .foregroundStyle(.secondary)
        }
    }
}

struct PrivacyToggle: View {
    let settings: UserSettings
    let onUpdate: (UserSettings) -> Void
    
    var body: some View {
        Toggle("Public Profile", isOn: Binding(
            get: { settings.privacy.profileVisibility == .public },
            set: { newValue in
                var newSettings = settings
                newSettings.privacy.profileVisibility = newValue ? .public : .private
                onUpdate(newSettings)
            }
        ))
        .font(.adaptiveBody())
    }
}
