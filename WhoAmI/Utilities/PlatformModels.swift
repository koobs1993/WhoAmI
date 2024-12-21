import Foundation
import SwiftUI
import UIKit

// MARK: - Platform-specific extensions
extension View {
    func adaptivePadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        padding(edges, length ?? 12)
    }
    
    func adaptiveCornerRadius(_ radius: CGFloat? = nil) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius ?? 6))
    }
}

// MARK: - Platform-specific colors
extension Color {
    static var adaptiveBackground: Color {
        Color(UIColor.systemBackground)
    }
    
    static var adaptiveSecondaryBackground: Color {
        Color(UIColor.secondarySystemBackground)
    }
    
    static var adaptiveTertiaryBackground: Color {
        Color(UIColor.tertiarySystemBackground)
    }
    
    static var adaptiveGroupedBackground: Color {
        Color(UIColor.systemGroupedBackground)
    }
}

// MARK: - Platform-specific fonts
extension Font {
    static func adaptiveBody() -> Font {
        .body
    }
    
    static func adaptiveTitle() -> Font {
        .title3
    }
    
    static func adaptiveHeadline() -> Font {
        .headline
    }
    
    static func adaptiveSubheadline() -> Font {
        .subheadline
    }
    
    static func adaptiveCaption() -> Font {
        .caption
    }
}

// MARK: - Platform-specific image handling
struct PlatformImage {
    let image: UIImage
    
    init?(named name: String) {
        guard let uiImage = UIImage(named: name) else { return nil }
        self.image = uiImage
    }
    
    init?(systemName: String) {
        guard let uiImage = UIImage(systemName: systemName) else { return nil }
        self.image = uiImage
    }
    
    var swiftUIImage: Image {
        Image(uiImage: image)
    }
}

// MARK: - Platform-specific layout
struct AdaptiveLayout {
    static var horizontalPadding: CGFloat = 16
    static var verticalPadding: CGFloat = 16
    static var cornerRadius: CGFloat = 6
    static var minimumSpacing: CGFloat = 8
    static var standardSpacing: CGFloat = 12
}

// MARK: - Platform-specific gestures
extension View {
    func onAdaptiveTap(perform action: @escaping () -> Void) -> some View {
        onTapGesture(perform: action)
            .hoverEffect(.highlight)
    }
}

// MARK: - Platform-specific modifiers
struct AdaptiveModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension View {
    func adaptiveFrame() -> some View {
        modifier(AdaptiveModifier())
    }
}
