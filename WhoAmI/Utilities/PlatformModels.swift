import Foundation
import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - Platform-specific type aliases
extension View {
    func adaptivePadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        #if os(macOS)
        padding(edges, length ?? 16)
        #else
        padding(edges, length ?? 12)
        #endif
    }
    
    func adaptiveCornerRadius(_ radius: CGFloat? = nil) -> some View {
        #if os(macOS)
        clipShape(RoundedRectangle(cornerRadius: radius ?? 8))
        #else
        clipShape(RoundedRectangle(cornerRadius: radius ?? 6))
        #endif
    }
}

// MARK: - Platform-specific colors
extension Color {
    static var adaptiveBackground: Color {
        #if os(macOS)
        Color(NSColor.windowBackgroundColor)
        #else
        Color(UIColor.systemBackground)
        #endif
    }
    
    static var adaptiveSecondaryBackground: Color {
        #if os(macOS)
        Color(NSColor.controlBackgroundColor)
        #else
        Color(UIColor.secondarySystemBackground)
        #endif
    }
    
    static var adaptiveTertiaryBackground: Color {
        #if os(macOS)
        Color(NSColor.underPageBackgroundColor)
        #else
        Color(UIColor.tertiarySystemBackground)
        #endif
    }
    
    static var adaptiveGroupedBackground: Color {
        #if os(macOS)
        Color(NSColor.windowBackgroundColor)
        #else
        Color(UIColor.systemGroupedBackground)
        #endif
    }
}

// MARK: - Platform-specific fonts
extension Font {
    static func adaptiveBody() -> Font {
        #if os(macOS)
        .system(.body)
        #else
        .body
        #endif
    }
    
    static func adaptiveTitle() -> Font {
        #if os(macOS)
        .system(.title2)
        #else
        .title3
        #endif
    }
    
    static func adaptiveHeadline() -> Font {
        #if os(macOS)
        .system(.title3)
        #else
        .headline
        #endif
    }
    
    static func adaptiveSubheadline() -> Font {
        #if os(macOS)
        .system(.headline)
        #else
        .subheadline
        #endif
    }
    
    static func adaptiveCaption() -> Font {
        #if os(macOS)
        .system(.subheadline)
        #else
        .caption
        #endif
    }
}

// MARK: - Platform-specific image handling
struct PlatformImage {
    #if os(macOS)
    let image: NSImage
    #else
    let image: UIImage
    #endif
    
    init?(named name: String) {
        #if os(macOS)
        guard let nsImage = NSImage(named: name) else { return nil }
        self.image = nsImage
        #else
        guard let uiImage = UIImage(named: name) else { return nil }
        self.image = uiImage
        #endif
    }
    
    init?(systemName: String) {
        #if os(macOS)
        guard let nsImage = NSImage(systemSymbolName: systemName, accessibilityDescription: nil) else { return nil }
        self.image = nsImage
        #else
        guard let uiImage = UIImage(systemName: systemName) else { return nil }
        self.image = uiImage
        #endif
    }
    
    var swiftUIImage: Image {
        #if os(macOS)
        Image(nsImage: image)
        #else
        Image(uiImage: image)
        #endif
    }
}

// MARK: - Platform-specific layout
struct AdaptiveLayout {
    static var horizontalPadding: CGFloat {
        #if os(macOS)
        20
        #else
        16
        #endif
    }
    
    static var verticalPadding: CGFloat {
        #if os(macOS)
        20
        #else
        16
        #endif
    }
    
    static var cornerRadius: CGFloat {
        #if os(macOS)
        8
        #else
        6
        #endif
    }
    
    static var minimumSpacing: CGFloat {
        #if os(macOS)
        12
        #else
        8
        #endif
    }
    
    static var standardSpacing: CGFloat {
        #if os(macOS)
        16
        #else
        12
        #endif
    }
}

// MARK: - Platform-specific gestures
extension View {
    func onAdaptiveTap(perform action: @escaping () -> Void) -> some View {
        #if os(macOS)
        onTapGesture(perform: action)
        #else
        onTapGesture(perform: action)
            .hoverEffect(.highlight)
        #endif
    }
}

// MARK: - Platform-specific modifiers
struct AdaptiveModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            #if os(macOS)
            .frame(minWidth: 600, minHeight: 400)
            #else
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            #endif
    }
}

extension View {
    func adaptiveFrame() -> some View {
        modifier(AdaptiveModifier())
    }
}
