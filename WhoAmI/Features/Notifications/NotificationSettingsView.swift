import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var viewModel: NotificationsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("General")) {
                    Toggle("Push Notifications", isOn: $viewModel.deviceSettings.notificationsEnabled)
                    Toggle("Course Updates", isOn: $viewModel.deviceSettings.courseUpdatesEnabled)
                }
                
                Section(header: Text("Notification Types")) {
                    Toggle("Test Reminders", isOn: $viewModel.deviceSettings.testRemindersEnabled)
                    Toggle("Weekly Summaries", isOn: $viewModel.deviceSettings.weeklySummariesEnabled)
                    Toggle("System Notifications", isOn: $viewModel.deviceSettings.notificationsEnabled)
                }
                
                Section(header: Text("Sound & Haptics")) {
                    Toggle("Sound", isOn: $viewModel.deviceSettings.soundEnabled)
                    Toggle("Haptics", isOn: $viewModel.deviceSettings.hapticsEnabled)
                }
            }
            .navigationTitle("Notification Settings")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(macOS)
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        Task {
                            await viewModel.saveSettings()
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.saveSettings()
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
} 