import SwiftUI

#if os(macOS)
import AppKit
public typealias PlatformColor = NSColor
public typealias PlatformFont = NSFont
public typealias PlatformViewController = NSViewController
public typealias PlatformViewRepresentable = NSViewRepresentable
#else
import UIKit
public typealias PlatformColor = UIColor
public typealias PlatformFont = UIFont
public typealias PlatformViewController = UIViewController
public typealias PlatformViewRepresentable = UIViewRepresentable
#endif

extension Color {
    static var systemBackground: Color {
        #if os(macOS)
        Color(NSColor.windowBackgroundColor)
        #else
        Color(UIColor.systemBackground)
        #endif
    }
    
    static var secondarySystemBackground: Color {
        #if os(macOS)
        Color(NSColor.controlBackgroundColor)
        #else
        Color(UIColor.secondarySystemBackground)
        #endif
    }
    
    static var tertiarySystemBackground: Color {
        #if os(macOS)
        Color(NSColor.underPageBackgroundColor)
        #else
        Color(UIColor.tertiarySystemBackground)
        #endif
    }
    
    static var systemGroupedBackground: Color {
        #if os(macOS)
        Color(NSColor.windowBackgroundColor)
        #else
        Color(UIColor.systemGroupedBackground)
        #endif
    }
    
    static var label: Color {
        #if os(macOS)
        Color(NSColor.labelColor)
        #else
        Color(UIColor.label)
        #endif
    }
    
    static var secondaryLabel: Color {
        #if os(macOS)
        Color(NSColor.secondaryLabelColor)
        #else
        Color(UIColor.secondaryLabel)
        #endif
    }
}

extension View {
    @ViewBuilder
    func ifOS<Content: View>(_ os: OS, transform: (Self) -> Content) -> some View {
        #if os(macOS)
        if os == .macOS {
            transform(self)
        } else {
            self
        }
        #else
        if os == .iOS {
            transform(self)
        } else {
            self
        }
        #endif
    }
}

enum OS {
    case iOS
    case macOS
} 