import SwiftUI

struct NotificationSettingsView: View {
    @StateObject var viewModel: NotificationsViewModel
    
    var body: some View {
        Form {
            Section(header: Text("General")) {
                Toggle("Enable Notifications", isOn: $viewModel.deviceSettings.notificationsEnabled)
                Toggle("Sound", isOn: $viewModel.deviceSettings.soundEnabled)
                    .disabled(!viewModel.deviceSettings.notificationsEnabled)
                Toggle("Badges", isOn: $viewModel.deviceSettings.badgesEnabled)
                    .disabled(!viewModel.deviceSettings.notificationsEnabled)
                Toggle("Vibration", isOn: $viewModel.deviceSettings.vibrationEnabled)
                    .disabled(!viewModel.deviceSettings.notificationsEnabled)
            }
            
            Section(header: Text("Categories")) {
                Toggle("Course Updates", isOn: .constant(true))
                    .disabled(!viewModel.deviceSettings.notificationsEnabled)
                Toggle("Test Reminders", isOn: .constant(true))
                    .disabled(!viewModel.deviceSettings.notificationsEnabled)
                Toggle("Achievement Alerts", isOn: .constant(true))
                    .disabled(!viewModel.deviceSettings.notificationsEnabled)
                Toggle("System Messages", isOn: .constant(true))
                    .disabled(!viewModel.deviceSettings.notificationsEnabled)
            }
        }
        .navigationTitle("Notification Settings")
        .onChange(of: viewModel.deviceSettings) { _ in
            Task {
                await viewModel.updateSettings()
            }
        }
        .task {
            await viewModel.loadSettings()
        }
    }
}

#Preview {
    NavigationView {
        NotificationSettingsView(viewModel: NotificationsViewModel(supabase: Config.supabaseClient, userId: UUID()))
    }
}
