import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum PlatformUtils {
    #if os(iOS)
    static var systemBackground: UIColor {
        UIColor.systemBackground
    }
    
    static var secondarySystemBackground: UIColor {
        UIColor.secondarySystemBackground
    }
    
    static var label: UIColor {
        UIColor.label
    }
    
    static var secondaryLabel: UIColor {
        UIColor.secondaryLabel
    }
    #elseif os(macOS)
    static var systemBackground: NSColor {
        NSColor.windowBackgroundColor
    }
    
    static var secondarySystemBackground: NSColor {
        NSColor.controlBackgroundColor
    }
    
    static var label: NSColor {
        NSColor.labelColor
    }
    
    static var secondaryLabel: NSColor {
        NSColor.secondaryLabelColor
    }
    #endif
}

// Protocol to handle window operations across platforms
protocol WindowProtocol {
    var isKeyWindow: Bool { get }
}

#if os(iOS)
extension UIWindow: WindowProtocol {}
#elseif os(macOS)
extension NSWindow: WindowProtocol {}
#endif 