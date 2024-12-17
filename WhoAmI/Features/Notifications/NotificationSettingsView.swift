import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var viewModel: NotificationsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Enable Notifications", isOn: $viewModel.deviceSettings.notificationsEnabled)
                    
                    if viewModel.deviceSettings.notificationsEnabled {
                        Toggle("Course Updates", isOn: $viewModel.deviceSettings.courseUpdatesEnabled)
                        Toggle("Test Reminders", isOn: $viewModel.deviceSettings.testRemindersEnabled)
                        Toggle("Weekly Summaries", isOn: $viewModel.deviceSettings.weeklySummariesEnabled)
                    }
                }
            }
            .navigationTitle("Notification Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            try? await viewModel.updateSettings()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
} 