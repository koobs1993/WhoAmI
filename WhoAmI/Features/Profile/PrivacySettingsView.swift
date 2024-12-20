import SwiftUI

struct PrivacySettingsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var profileVisibility: ProfileVisibility = .public
    @State private var shareProgress = true
    @State private var shareResults = true
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Profile Visibility", selection: $profileVisibility) {
                        Text("Public").tag(ProfileVisibility.public)
                        Text("Friends Only").tag(ProfileVisibility.friends)
                        Text("Private").tag(ProfileVisibility.private)
                    }
                } footer: {
                    Text("Choose who can see your profile information")
                }
                
                Section {
                    Toggle("Share Progress", isOn: $shareProgress)
                    Toggle("Share Results", isOn: $shareResults)
                } footer: {
                    Text("Control what information is shared with others")
                }
            }
            .navigationTitle("Privacy Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveSettings()
                        }
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                if let settings = viewModel.settings {
                    profileVisibility = settings.privacy.profileVisibility
                    shareProgress = settings.privacy.shareProgress
                    shareResults = settings.privacy.shareResults
                }
            }
        }
    }
    
    private func saveSettings() async {
        guard var settings = viewModel.settings else { return }
        
        settings.privacy = PrivacySettings(
            profileVisibility: profileVisibility,
            shareProgress: shareProgress,
            shareResults: shareResults
        )
        
        do {
            try await viewModel.updateSettings(settings)
            dismiss()
        } catch {
            showingError = true
            errorMessage = error.localizedDescription
        }
    }
}

#if DEBUG
struct PrivacySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacySettingsView(
            viewModel: ProfileViewModel(
                supabase: Config.previewClient,
                userId: UUID()
            )
        )
    }
}
#endif
