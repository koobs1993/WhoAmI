import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum PlatformUtils {
    #if os(iOS)
    static var systemBackground: UIColor {
        .systemBackground
    }
    
    static func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    static func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    #elseif os(macOS)
    static var systemBackground: NSColor {
        .windowBackgroundColor
    }
    
    static func registerForRemoteNotifications() {
        NSApplication.shared.registerForRemoteNotifications()
    }
    
    static func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
    }
    #endif
    
    static func share(text: String) {
        #if os(iOS)
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
        #elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        #endif
    }
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