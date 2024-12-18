import SwiftUI

// Move this to the top level of the file
extension ChatSession: Equatable {
    public static func == (lhs: ChatSession, rhs: ChatSession) -> Bool {
        lhs.id == rhs.id
    }
}

struct ChatSearchView: View {
    // ... view implementation
} 