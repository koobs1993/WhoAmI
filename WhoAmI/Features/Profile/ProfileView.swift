#if os(iOS)
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
#endif
import SwiftUI
import Supabase

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(supabase: SupabaseClient, userId: UUID) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(supabase: supabase, userId: userId))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    if let image = viewModel.profileImage {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    }
                    Button("Choose Photo") {
                        // Photo selection logic
                    }
                } header: {
                    Text("Profile Photo")
                }
                
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $viewModel.firstName)
                    TextField("Last Name", text: $viewModel.lastName)
                    TextField("Email", text: $viewModel.email)
                }
                
                Section(header: Text("Account")) {
                    Button("Sign Out") {
                        Task {
                            await viewModel.signOut()
                        }
                    }
                    .foregroundColor(.red)
                }
                
                Button("Save") {
                    Task {
                        do {
                            try await viewModel.saveProfile()
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Failed to save profile:", error)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            do {
                                try await viewModel.saveProfile()
                                presentationMode.wrappedValue.dismiss()
                            } catch {
                                print("Failed to save profile:", error)
                            }
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct StatsSection: View {
    let stats: UserStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Progress")
                .font(.headline)
            
            ProfileStatsView(stats: stats)
        }
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct SettingsSection: View {
    @Binding var showingPrivacySettings: Bool
    @Binding var showingSubscriptionOptions: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)
            
            SettingsButton(
                title: "Privacy Settings",
                icon: "lock.fill",
                action: { showingPrivacySettings = true }
            )
            
            SettingsButton(
                title: "Subscription Options",
                icon: "star.fill",
                action: { showingSubscriptionOptions = true }
            )
        }
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(radius: 2)
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
                            if let profile = viewModel.profile {
                                let updatedProfile = UserProfile(
                                    id: profile.id,
                                    userId: profile.userId,
                                    firstName: firstName,
                                    lastName: lastName,
                                    email: profile.email,
                                    gender: profile.gender,
                                    role: profile.role,
                                    avatarUrl: profile.avatarUrl,
                                    bio: bio,
                                    phone: profile.phone,
                                    isActive: profile.isActive,
                                    emailConfirmedAt: profile.emailConfirmedAt,
                                    createdAt: profile.createdAt,
                                    updatedAt: Date()
                                )
                                try? await viewModel.updateProfile(updatedProfile)
                            }
                            dismiss()
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
                if let settings = viewModel.privacySettings {
                    Section(header: Text("Profile Visibility")) {
                        Toggle("Show Profile", isOn: Binding(
                            get: { settings.showProfile },
                            set: { newValue in
                                Task {
                                    do {
                                        var updatedSettings = settings
                                        updatedSettings.showProfile = newValue
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
                                    do {
                                        var updatedSettings = settings
                                        updatedSettings.showActivity = newValue
                                        try await viewModel.updatePrivacySettings(updatedSettings)
                                    } catch {
                                        self.error = error
                                        self.showingError = true
                                    }
                                }
                            }
                        ))
                    }
                    
                    Section(header: Text("Communication")) {
                        Toggle("Allow Messages", isOn: Binding(
                            get: { settings.allowMessages },
                            set: { newValue in
                                Task {
                                    do {
                                        var updatedSettings = settings
                                        updatedSettings.allowMessages = newValue
                                        try await viewModel.updatePrivacySettings(updatedSettings)
                                    } catch {
                                        self.error = error
                                        self.showingError = true
                                    }
                                }
                            }
                        ))
                        
                        Toggle("Share Progress", isOn: Binding(
                            get: { settings.shareProgress },
                            set: { newValue in
                                Task {
                                    do {
                                        var updatedSettings = settings
                                        updatedSettings.shareProgress = newValue
                                        try await viewModel.updatePrivacySettings(updatedSettings)
                                    } catch {
                                        self.error = error
                                        self.showingError = true
                                    }
                                }
                            }
                        ))
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Privacy Settings")
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
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(error?.localizedDescription ?? "An unknown error occurred")
            }
        }
    }
}

struct SubscriptionOptionsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var error: Error?
    @State private var showingError = false
    
    var body: some View {
        List {
            Section {
                Button {
                    Task {
                        do {
                            _ = try await viewModel.handlePurchase(for: .monthly)
                            dismiss()
                        } catch {
                            self.error = error
                            showingError = true
                        }
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Monthly")
                                .font(.headline)
                            Text("$9.99/month")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                
                Button {
                    Task {
                        do {
                            _ = try await viewModel.handlePurchase(for: .yearly)
                            dismiss()
                        } catch {
                            self.error = error
                            showingError = true
                        }
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Yearly")
                                .font(.headline)
                            Text("$99.99/year")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(error?.localizedDescription ?? "An unknown error occurred")
        }
    }
} 