import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading) {
                Text(message.content)
                    .padding()
                    .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text(message.createdAt, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        MessageBubble(message: message, isCurrentUser: message.role == .user)
    }
}

struct TypingIndicatorView: View {
    let typingUsers: Set<String>
    
    var body: some View {
        HStack {
            ForEach(Array(typingUsers), id: \.self) { userName in
                Text(userName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if !typingUsers.isEmpty {
                Text("typing...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .animation(.easeInOut(duration: 0.5).repeatForever(), value: true)
            }
        }
        .padding(.horizontal)
    }
}

struct MessageInput: View {
    @Binding var text: String
    let onSend: () -> Void
    let onTyping: (Bool) -> Void
    
    var body: some View {
        HStack {
            TextField("Type a message...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: text) { oldValue, newValue in
                    onTyping(!newValue.isEmpty)
                }
            
            Button(action: {
                onSend()
                text = ""
                onTyping(false)
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.blue)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.2)),
            alignment: .top
        )
    }
}

struct ChatTypingIndicator: View {
    let userNames: [String]
    
    var body: some View {
        if !userNames.isEmpty {
            HStack {
                Text(typingText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    private var typingText: String {
        switch userNames.count {
        case 0:
            return ""
        case 1:
            return "\(userNames[0]) is typing..."
        case 2:
            return "\(userNames[0]) and \(userNames[1]) are typing..."
        default:
            return "Several people are typing..."
        }
    }
}

#Preview {
    VStack {
        MessageView(message: ChatMessage(
            id: UUID(),
            sessionId: UUID(),
            userId: nil,
            role: .assistant,
            content: "Hello! How can I help you today?",
            metadata: nil,
            createdAt: Date()
        ))
        
        TypingIndicatorView(typingUsers: ["John", "Jane"])
    }
    .padding()
}
  