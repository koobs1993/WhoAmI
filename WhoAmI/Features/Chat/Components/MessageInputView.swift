 // Chat UI Components temporarily disabled
/*
import SwiftUI

struct MessageInputView: View {
    @Binding var message: String
    let onSend: () -> Void
    
    var body: some View {
        HStack {
            TextField("Type a message...", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: {
                if !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    onSend()
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.blue)
            }
            .padding(.trailing)
            .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor))
        .shadow(radius: 2)
    }
}
*/
