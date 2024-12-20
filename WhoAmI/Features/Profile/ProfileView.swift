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
    @State private var showingEditProfile = false
    @State private var showingPrivacySettings = false
    
    init(supabase: SupabaseClient, userId: UUID) {
        _viewModel = ObservedObject(wrappedValue: ProfileViewModel(supabase: supabase, userId: userId))
    }
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.profile == nil {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading profile...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 100)
            } else if let error = viewModel.error {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundStyle(.red)
                    
                    Text("Unable to Load Profile")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button {
                        Task {
                            try? await viewModel.fetchProfile()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Try Again")
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
            } else if let profile = viewModel.profile {
                VStack(spacing: 0) {
                    // Profile Header
                    ProfileHeader(
                        profile: profile,
                        stats: viewModel.stats,
                        onEditTap: { showingEditProfile = true }
                    )
                    
                    Divider()
                        .padding(.vertical)
                    
                    // Settings
                    VStack(spacing: 24) {
                        // Account Settings
                        SettingsSection(title: "Account") {
                            SettingsRow(
                                title: "Email",
                                subtitle: profile.email,
                                icon: "envelope.fill"
                            )
                            
                            SettingsRow(
                                title: "Password",
                                subtitle: "Change your password",
                                icon: "lock.fill",
                                showDisclosure: true
                            ) {
                                // TODO: Implement password change
                            }
                        }
                        
                        // Privacy Settings
                        SettingsSection(title: "Privacy") {
                            SettingsRow(
                                title: "Privacy Settings",
                                subtitle: "Manage your privacy preferences",
                                icon: "hand.raised.fill",
                                showDisclosure: true
                            ) {
                                showingPrivacySettings = true
                            }
                            
                            SettingsRow(
                                title: "Data & Storage",
                                subtitle: "Manage your data and storage",
                                icon: "internaldrive.fill",
                                showDisclosure: true
                            ) {
                                // TODO: Implement data management
                            }
                        }
                        
                        // Notifications
                        SettingsSection(title: "Notifications") {
                            SettingsRow(
                                title: "Push Notifications",
                                subtitle: "Manage your notifications",
                                icon: "bell.fill",
                                showDisclosure: true
                            ) {
                                // TODO: Implement notifications settings
                            }
                            
                            SettingsRow(
                                title: "Email Notifications",
                                subtitle: "Manage email preferences",
                                icon: "envelope.badge.fill",
                                showDisclosure: true
                            ) {
                                // TODO: Implement email settings
                            }
                        }
                        
                        // Support
                        SettingsSection(title: "Support") {
                            SettingsRow(
                                title: "Help Center",
                                subtitle: "Get help with WhoAmI",
                                icon: "questionmark.circle.fill",
                                showDisclosure: true
                            ) {
                                // TODO: Implement help center
                            }
                            
                            SettingsRow(
                                title: "Contact Support",
                                subtitle: "Get in touch with our team",
                                icon: "message.fill",
                                showDisclosure: true
                            ) {
                                // TODO: Implement contact support
                            }
                        }
                        
                        // Sign Out
                        Button(role: .destructive) {
                            Task {
                                do {
                                    try await viewModel.signOut()
                                } catch {
                                    // Handle error if needed
                                    print("Sign out error: \(error)")
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundStyle(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            NavigationView {
                EditProfileView(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $showingPrivacySettings) {
            NavigationView {
                PrivacySettingsView(viewModel: viewModel)
            }
        }
        .navigationTitle("Profile")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .task {
            if viewModel.profile == nil {
                try? await viewModel.fetchProfile()
            }
        }
        .refreshable {
            try? await viewModel.fetchProfile()
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.leading, 8)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color.adaptiveBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 5)
        }
    }
}

struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    var showDisclosure: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.blue)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if showDisclosure {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}
