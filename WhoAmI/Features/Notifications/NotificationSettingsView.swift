import SwiftUI

struct NotificationSettingsView: View {
    @StateObject var viewModel: NotificationsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section {
                Toggle("Enable Notifications", isOn: $viewModel.deviceSettings.notificationsEnabled)
            }
            
            Section {
                Toggle("Course Updates", isOn: $viewModel.deviceSettings.courseUpdatesEnabled)
                    .disabled(!viewModel.deviceSettings.notificationsEnabled)
                Toggle("Test Reminders", isOn: $viewModel.deviceSettings.testRemindersEnabled)
                    .disabled(!viewModel.deviceSettings.notificationsEnabled)
                Toggle("Weekly Summaries", isOn: $viewModel.deviceSettings.weeklySummariesEnabled)
                    .disabled(!viewModel.deviceSettings.notificationsEnabled)
            } header: {
                Text("Notification Types")
            }
            
            Section {
                Button {
                    Task {
                        await viewModel.saveDeviceSettings()
                        dismiss()
                    }
                } label: {
                    Text("Save")
                }
            }
        }
        .navigationTitle("Notification Settings")
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
