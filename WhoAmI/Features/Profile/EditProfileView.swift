import SwiftUI
import Supabase

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var bio: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer()
                        ProfileAvatar(profile: viewModel.profile ?? UserProfile(id: UUID(), firstName: "", lastName: "", email: "", createdAt: Date(), updatedAt: Date()))
                            .onTapGesture {
                                showingImagePicker = true
                            }
                        Spacer()
                    }
                    .listRowBackground(Color.adaptiveBackground)
                    
                    TextField("First Name", text: $firstName)
                        .font(.adaptiveBody())
                    
                    TextField("Last Name", text: $lastName)
                        .font(.adaptiveBody())
                    
                    TextField("Bio", text: $bio)
                        .font(.adaptiveBody())
                }
            }
            .navigationTitle("Edit Profile")
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
                            await saveProfile()
                        }
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
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
    
    private func saveProfile() async {
        guard let profile = viewModel.profile else { return }
        
        var updatedProfile = profile
        updatedProfile.firstName = firstName
        updatedProfile.lastName = lastName
        updatedProfile.bio = bio.isEmpty ? nil : bio
        
        if let image = selectedImage {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                do {
                    let path = "\(profile.id.uuidString).jpg"
                    let avatarUrl = try await viewModel.uploadProfileImage(imageData: imageData, path: path)
                    updatedProfile.avatarUrl = avatarUrl
                } catch {
                    showingError = true
                    errorMessage = error.localizedDescription
                    return
                }
            }
        }
        
        do {
            try await viewModel.updateProfile(updatedProfile)
            dismiss()
        } catch {
            showingError = true
            errorMessage = error.localizedDescription
        }
    }
}

#if DEBUG
struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(
            viewModel: ProfileViewModel(
                supabase: Config.previewClient,
                userId: UUID()
            )
        )
    }
}
#endif
