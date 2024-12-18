import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Profile Stats View
struct ProfileStatsView: View {
    let stats: UserStats
    
    var body: some View {
        HStack(spacing: 20) {
            StatItem(title: "Tests", value: "\(stats.completedTests)", icon: "checklist")
            StatItem(title: "Courses", value: "\(stats.coursesCompleted)", icon: "book.fill")
            StatItem(title: "Streak", value: "\(stats.streak)", icon: "flame.fill")
        }
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .cornerRadius(12)
    }
}

private struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Settings Button
struct SettingsButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            #if os(iOS)
            .background(Color(uiColor: .systemBackground))
            #else
            .background(Color(nsColor: .windowBackgroundColor))
            #endif
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Profile Image View
struct ProfileImageView: View {
    let imageURL: String?
    let image: PlatformImage?
    let size: CGFloat
    
    var body: some View {
        Group {
            if let image = image {
                #if os(iOS)
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                #elseif os(macOS)
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                #endif
            } else if let urlString = imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Profile Header Section
struct ProfileHeaderSection: View {
    let profile: UserProfile
    @Binding var selectedImage: PlatformImage?
    @Binding var isImagePickerPresented: Bool
    let onEditProfile: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            ProfileImageView(
                imageURL: profile.avatarUrl,
                image: selectedImage,
                size: 100
            )
            .onTapGesture {
                isImagePickerPresented = true
            }
            
            Text("\(profile.firstName) \(profile.lastName)")
                .font(.title2)
                .bold()
            
            if let bio = profile.bio {
                Text(bio)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Edit Profile") {
                onEditProfile()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#if os(iOS)
// MARK: - Image Picker View
struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: PlatformImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? PlatformImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
#endif

#if os(macOS)
// MARK: - macOS Image Picker
struct ImagePickerWindow: View {
    @Binding var selectedImage: PlatformImage?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Button("Choose Image") {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.canChooseFiles = true
                panel.allowedContentTypes = [.image]
                
                if panel.runModal() == .OK {
                    if let url = panel.url {
                        if let image = NSImage(contentsOf: url) {
                            selectedImage = image
                            dismiss()
                        }
                    }
                }
            }
            .padding()
            
            Button("Cancel") {
                dismiss()
            }
            .padding()
        }
        .frame(width: 300, height: 150)
    }
}
#endif 