import SwiftUI
import Supabase
import StoreKit
#if os(iOS)
import UIKit
#endif

// Define the subscription duration type
enum SubscriptionDuration {
    case monthly
    case yearly
    
    var productId: String {
        switch self {
        case .monthly:
            return "com.whoami.subscription.monthly"
        case .yearly:
            return "com.whoami.subscription.yearly"
        }
    }
}

struct EmailFieldView: View {
    @Binding var email: String
    
    var body: some View {
        TextField("Email", text: $email)
            .textFieldStyle(.roundedBorder)
            #if os(iOS)
            .keyboardType(.emailAddress)
            .textContentType(.username)
            .textInputAutocapitalization(.never)
            #endif
    }
}

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingImagePicker = false
    @State private var showingSubscriptionSheet = false
    @State private var selectedImage: PlatformImage?
    @State private var showingDeleteConfirmation = false
    @State private var showingPasswordSheet = false
    @State private var showingEmailSheet = false
    @State private var showingEditProfile = false
    
    init(supabase: SupabaseClient) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(supabase: supabase))
    }
    
    var body: some View {
        NavigationView {
            ProfileContentView(
                viewModel: viewModel,
                showingImagePicker: $showingImagePicker,
                showingSubscriptionSheet: $showingSubscriptionSheet,
                selectedImage: $selectedImage,
                showingDeleteConfirmation: $showingDeleteConfirmation,
                showingPasswordSheet: $showingPasswordSheet,
                showingEmailSheet: $showingEmailSheet,
                showingEditProfile: $showingEditProfile
            )
        }
    }
}

struct ProfileContentView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Binding var showingImagePicker: Bool
    @Binding var showingSubscriptionSheet: Bool
    @Binding var selectedImage: PlatformImage?
    @Binding var showingDeleteConfirmation: Bool
    @Binding var showingPasswordSheet: Bool
    @Binding var showingEmailSheet: Bool
    @Binding var showingEditProfile: Bool
    
    var body: some View {
        List {
            if let profile = viewModel.profile {
                ProfileHeaderSection(
                    profile: profile,
                    showingImagePicker: $showingImagePicker,
                    showingEditProfile: $showingEditProfile
                )
                
                if let userStats = viewModel.stats {
                    StatsSection(stats: userStats)
                }
                
                AccountSection(
                    showingPasswordSheet: $showingPasswordSheet,
                    showingEmailSheet: $showingEmailSheet,
                    showingSubscriptionSheet: $showingSubscriptionSheet
                )
                
                if let settings = viewModel.deviceSettings {
                    AppSettingsSection(settings: settings, viewModel: viewModel)
                }
                
                if let privacySettings = viewModel.privacySettings {
                    PrivacySection(settings: privacySettings, viewModel: viewModel)
                }
                
                DeleteAccountSection(showingDeleteConfirmation: $showingDeleteConfirmation)
            }
        }
        .navigationTitle("Profile")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .refreshable {
            Task {
                try? await viewModel.loadProfile()
            }
        }
        .task {
            if viewModel.profile == nil {
                try? await viewModel.loadProfile()
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingPasswordSheet) {
            ChangePasswordSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingEmailSheet) {
            ChangeEmailSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingSubscriptionSheet) {
            SubscriptionOptionsSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingImagePicker) {
            SharedImagePicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) { image in
            if let image = image {
                Task {
                    #if os(iOS)
                    if let imageData = image.jpegData(compressionQuality: 0.7) {
                        try? await viewModel.uploadProfileImage(imageData)
                    }
                    #else
                    if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil),
                       let imageData = NSBitmapImageRep(cgImage: cgImage).representation(using: .jpeg, properties: [:]) {
                        try? await viewModel.uploadProfileImage(imageData)
                    }
                    #endif
                    selectedImage = nil
                }
            }
        }
        .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    try? await viewModel.deleteAccount()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
    }
}

struct ProfileHeaderSection: View {
    let profile: UserProfile
    @Binding var showingImagePicker: Bool
    @Binding var showingEditProfile: Bool
    
    var body: some View {
        Section {
            VStack(alignment: .center, spacing: 16) {
                ProfileImageView(
                    imageURL: profile.profileImage,
                    image: nil,
                    size: 100
                )
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.2)))
                .onTapGesture {
                    showingImagePicker = true
                }
                
                Text("\(profile.firstName) \(profile.lastName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if let bio = profile.bio {
                    Text(bio)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button("Edit Profile") {
                    showingEditProfile = true
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}

struct StatsSection: View {
    let stats: UserStats
    
    var body: some View {
        Section("Activity") {
            StatsInfoRow(icon: "book.fill", title: "Courses Completed", value: stats.coursesCompleted)
            StatsInfoRow(icon: "checkmark.circle.fill", title: "Tests Completed", value: stats.testsCompleted)
            StatsInfoRow(icon: "message.fill", title: "Chat Sessions", value: stats.chatSessionsCount)
        }
    }
}

struct AccountSection: View {
    @Binding var showingPasswordSheet: Bool
    @Binding var showingEmailSheet: Bool
    @Binding var showingSubscriptionSheet: Bool
    
    var body: some View {
        Section("Account") {
            Button("Change Password") {
                showingPasswordSheet = true
            }
            
            Button("Change Email") {
                showingEmailSheet = true
            }
            
            Button("Subscription Options") {
                showingSubscriptionSheet = true
            }
        }
    }
}

struct AppSettingsSection: View {
    let settings: UserDevicePreferences
    let viewModel: ProfileViewModel
    
    var body: some View {
        Section("App Settings") {
            Toggle("Notifications", isOn: Binding(
                get: { settings.notificationsEnabled },
                set: { newValue in
                    Task {
                        var updatedSettings = settings
                        updatedSettings.notificationsEnabled = newValue
                        try? await viewModel.updateDeviceSettings(updatedSettings)
                    }
                }
            ))
            
            Picker("Theme", selection: Binding(
                get: { settings.theme },
                set: { newValue in
                    Task {
                        var updatedSettings = settings
                        updatedSettings.theme = newValue
                        try? await viewModel.updateDeviceSettings(updatedSettings)
                    }
                }
            )) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            
            Picker("Language", selection: Binding(
                get: { settings.language },
                set: { newValue in
                    Task {
                        var updatedSettings = settings
                        updatedSettings.language = newValue
                        try? await viewModel.updateDeviceSettings(updatedSettings)
                    }
                }
            )) {
                Text("English").tag("en")
                Text("Spanish").tag("es")
                Text("French").tag("fr")
            }
        }
    }
}

struct PrivacySection: View {
    let settings: UserPrivacySettings
    let viewModel: ProfileViewModel
    
    var body: some View {
        Section("Privacy") {
            Toggle("Show Profile", isOn: Binding(
                get: { settings.showProfile },
                set: { newValue in
                    Task {
                        try? await viewModel.updatePrivacySettings(
                            showProfile: newValue,
                            allowMessages: settings.allowMessages
                        )
                    }
                }
            ))
            
            Toggle("Allow Messages", isOn: Binding(
                get: { settings.allowMessages },
                set: { newValue in
                    Task {
                        try? await viewModel.updatePrivacySettings(
                            showProfile: settings.showProfile,
                            allowMessages: newValue
                        )
                    }
                }
            ))
        }
    }
}

struct DeleteAccountSection: View {
    @Binding var showingDeleteConfirmation: Bool
    
    var body: some View {
        Section {
            Button("Delete Account", role: .destructive) {
                showingDeleteConfirmation = true
            }
        }
    }
}

struct StatsInfoRow: View {
    let icon: String
    let title: String
    let value: Int
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
            
            Spacer()
            
            Text("\(value)")
                .foregroundColor(.secondary)
        }
    }
}

struct EditProfileSheet: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var bio = ""
    
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
                            try? await viewModel.updateProfile(
                                firstName: firstName,
                                lastName: lastName,
                                bio: bio
                            )
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

struct ChangePasswordSheet: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    SecureField("New Password", text: $newPassword)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                
                Section {
                    Button("Update Password") {
                        guard newPassword == confirmPassword else {
                            errorMessage = "Passwords do not match"
                            showingError = true
                            return
                        }
                        
                        Task {
                            do {
                                try await viewModel.updatePassword(to: newPassword)
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                                showingError = true
                            }
                        }
                    }
                }
            }
            .navigationTitle("Change Password")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
}

struct ChangeEmailSheet: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var newEmail = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    EmailFieldView(email: $newEmail)
                }
                
                Section {
                    Button("Update Email") {
                        Task {
                            do {
                                try await viewModel.updateEmail(to: newEmail)
                                try await viewModel.sendVerificationEmail()
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                                showingError = true
                            }
                        }
                    }
                }
            }
            .navigationTitle("Change Email")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
}

struct SubscriptionOptionsSheet: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button {
                        Task {
                            do {
                                let product = try await viewModel.getProduct(for: .monthly)
                                if let transaction = try await viewModel.purchase(product) {
                                    // Handle successful purchase
                                    dismiss()
                                }
                            } catch {
                                errorMessage = error.localizedDescription
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
                                let product = try await viewModel.getProduct(for: .yearly)
                                if let transaction = try await viewModel.purchase(product) {
                                    // Handle successful purchase
                                    dismiss()
                                }
                            } catch {
                                errorMessage = error.localizedDescription
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
            .navigationTitle("Subscription")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
} 