#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import SwiftUI
import Supabase

struct ProfileView: View {
    @ObservedObject private var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(supabase: SupabaseClient, userId: UUID) {
        _viewModel = ObservedObject(wrappedValue: ProfileViewModel(supabase: supabase, userId: userId))
    }
    
    var body: some View {
        NavigationView {
            Form {
                if let profile = viewModel.profile {
                    Section(header: Text("Personal Information")) {
                        Text("First Name: \(profile.firstName)")
                        Text("Last Name: \(profile.lastName)")
                        Text("Email: \(profile.email)")
                        
                        if let bio = profile.bio {
                            Text("Bio: \(bio)")
                        }
                    }
                    
                    if let avatarUrl = profile.avatarUrl {
                        Section(header: Text("Profile Photo")) {
                            AsyncImage(url: URL(string: avatarUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            } placeholder: {
                                Color.gray.opacity(0.3)
                                    .frame(height: 100)
                            }
                        }
                    }
                }
                
                if let stats = viewModel.stats {
                    Section(header: Text("Statistics")) {
                        StatsSection(stats: stats)
                    }
                }
                
                Section(header: Text("Account")) {
                    NavigationLink("Edit Profile") {
                        EditProfileView(viewModel: viewModel)
                    }
                    
                    NavigationLink("Privacy Settings") {
                        PrivacySettingsView(viewModel: viewModel)
                    }
                    
                    Button("Sign Out") {
                        Task {
                            // Sign out logic
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct StatsSection: View {
    let stats: UserStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Progress")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatItem(title: "Tests", value: "\(stats.testsCompleted)")
                StatItem(title: "Courses", value: "\(stats.coursesCompleted)")
                StatItem(title: "Score", value: String(format: "%.1f%%", stats.averageScore))
            }
            
            StatItem(title: "Total Points", value: "\(stats.totalPoints)")
        }
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(NSColor.windowBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
    }
}

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var bio: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextEditor(text: $bio)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if let profile = viewModel.profile {
                                var updatedProfile = profile
                                updatedProfile.firstName = firstName
                                updatedProfile.lastName = lastName
                                updatedProfile.bio = bio
                                do {
                                    try await viewModel.updateProfile(updatedProfile)
                                    dismiss()
                                } catch {
                                    print("Error updating profile: \(error)")
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                if let profile = viewModel.profile {
                    firstName = profile.firstName
                    lastName = profile.lastName
                    bio = profile.bio ?? ""
                }
            }
        }
    }
}

struct PrivacySettingsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingError = false
    @State private var error: Error?
    
    var body: some View {
        NavigationView {
            Form {
                if let settings = viewModel.settings {
                    Section(header: Text("Profile Visibility")) {
                        Toggle("Show Profile", isOn: Binding(
                            get: { settings.isPublic },
                            set: { newValue in
                                Task {
                                    var updatedSettings = settings
                                    updatedSettings.isPublic = newValue
                                    do {
                                        try await viewModel.updatePrivacySettings(updatedSettings)
                                    } catch {
                                        self.error = error
                                        self.showingError = true
                                    }
                                }
                            }
                        ))
                        
                        Toggle("Show Activity", isOn: Binding(
                            get: { settings.showActivity },
                            set: { newValue in
                                Task {
                                    var updatedSettings = settings
                                    updatedSettings.showActivity = newValue
                                    do {
                                        try await viewModel.updatePrivacySettings(updatedSettings)
                                    } catch {
                                        self.error = error
                                        self.showingError = true
                                    }
                                }
                            }
                        ))
                        
                        Toggle("Show Stats", isOn: Binding(
                            get: { settings.showStats },
                            set: { newValue in
                                Task {
                                    var updatedSettings = settings
                                    updatedSettings.showStats = newValue
                                    do {
                                        try await viewModel.updatePrivacySettings(updatedSettings)
                                    } catch {
                                        self.error = error
                                        self.showingError = true
                                    }
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle("Privacy Settings")
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                if let error = error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    ProfileView(supabase: Config.supabaseClient, userId: UUID())
}
