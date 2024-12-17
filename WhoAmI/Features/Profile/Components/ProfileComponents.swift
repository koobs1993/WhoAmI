import SwiftUI
import AppKit
import SDWebImageSwiftUI

// MARK: - Profile Image View
struct ProfileImageView: View {
    let imageURL: URL?
    let image: PlatformImage?
    let size: CGFloat
    
    init(imageURL: URL? = nil, image: PlatformImage? = nil, size: CGFloat = 100) {
        self.imageURL = imageURL
        self.image = image
        self.size = size
    }
    
    var body: some View {
        Group {
            if let image = image {
                #if os(iOS)
                Image(uiImage: image)
                    .resizable()
                #elseif os(macOS)
                Image(nsImage: image)
                    .resizable()
                #endif
            } else if let url = imageURL {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
            }
        }
        .aspectRatio(contentMode: .fill)
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Image Picker
struct ImagePicker: View {
    @Binding var selectedImage: PlatformImage?
    let onImagePicked: (PlatformImage) -> Void
    
    var body: some View {
        #if os(iOS)
        PhotosPicker(selection: $selectedImage,
                    matching: .images,
                    photoLibrary: .shared()) {
            Label("Choose Photo", systemImage: "photo")
        }
        .onChange(of: selectedImage) { newValue in
            if let image = newValue {
                onImagePicked(image)
            }
        }
        #elseif os(macOS)
        Button {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            panel.canChooseFiles = true
            panel.allowedContentTypes = [.image]
            
            if panel.runModal() == .OK,
               let url = panel.url,
               let image = PlatformImage(contentsOf: url) {
                selectedImage = image
                onImagePicked(image)
            }
        } label: {
            Label("Choose Photo", systemImage: "photo")
        }
        #endif
    }
}

struct ProfileImagePicker: View {
    @State private var selectedImage: PlatformImage?
    let onImagePicked: (PlatformImage) -> Void
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                ProfileImageView(image: image)
            } else {
                ProfileImageView()
            }
            
            ImagePicker(selectedImage: $selectedImage, onImagePicked: onImagePicked)
        }
    }
}

// MARK: - Settings Section
struct SettingsSection: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: icon)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Subscription Card
struct SubscriptionCard: View {
    let title: String
    let price: String
    let features: [String]
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            Text(price)
                .font(.title2)
                .bold()
            
            ForEach(features, id: \.self) { feature in
                Label(feature, systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            
            Button(action: action) {
                Text(isSelected ? "Current Plan" : "Select Plan")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSelected ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isSelected)
        }
        .padding()
        .background(Color(PlatformUtils.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Helper Extensions
extension Bundle {
    var appVersionString: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
} 