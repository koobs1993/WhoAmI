import SwiftUI
import UIKit

enum PlatformUtils {
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
}

// Protocol to handle window operations
protocol WindowProtocol {
    var isKeyWindow: Bool { get }
}

extension UIWindow: WindowProtocol {}
