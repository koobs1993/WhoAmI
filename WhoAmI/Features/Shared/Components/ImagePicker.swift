import SwiftUI
import PhotosUI
#if os(iOS)
import UIKit

struct SharedImagePicker: UIViewControllerRepresentable {
    @Binding var image: PlatformImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: SharedImagePicker
        
        init(_ parent: SharedImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: PlatformImage.self) {
                provider.loadObject(ofClass: PlatformImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? PlatformImage
                    }
                }
            }
        }
    }
}
#else
struct SharedImagePicker: View {
    @Binding var image: PlatformImage?
    
    var body: some View {
        Text("Image picker not available on macOS")
    }
}
#endif 