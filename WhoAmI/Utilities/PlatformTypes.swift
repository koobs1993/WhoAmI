import SwiftUI
import UIKit

public typealias PlatformColor = UIColor
public typealias PlatformFont = UIFont
public typealias PlatformViewController = UIViewController
public typealias PlatformViewRepresentable = UIViewRepresentable

extension Color {
    static var systemBackground: Color {
        Color(UIColor.systemBackground)
    }
    
    static var secondarySystemBackground: Color {
        Color(UIColor.secondarySystemBackground)
    }
    
    static var tertiarySystemBackground: Color {
        Color(UIColor.tertiarySystemBackground)
    }
    
    static var systemGroupedBackground: Color {
        Color(UIColor.systemGroupedBackground)
    }
    
    static var label: Color {
        Color(UIColor.label)
    }
    
    static var secondaryLabel: Color {
        Color(UIColor.secondaryLabel)
    }
}

extension View {
    @ViewBuilder
    func ifOS<Content: View>(_ os: OS, transform: (Self) -> Content) -> some View {
        if os == .iOS {
            transform(self)
        } else {
            self
        }
    }
}

/// Supported operating systems for the application.
/// Currently only supports iOS as this is an iOS-only application.
enum OS {
    /// iOS platform
    case iOS
}
