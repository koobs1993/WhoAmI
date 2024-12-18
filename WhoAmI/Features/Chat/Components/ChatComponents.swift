import SwiftUI
import Supabase

struct ChatInputView: View {
    @Binding var message: String
    let isLoading: Bool
    let onSend: () -> Void
    
    var body: some View {
        HStack {
            TextField("Type a message...", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(isLoading)
            
            Button(action: onSend) {
                if isLoading {
                    ProgressView()
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "paperplane.fill")
                }
            }
            .disabled(message.isEmpty || isLoading)
        }
        .padding()
        .background(Color(.windowBackgroundColor))
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding()
                    .background(isCurrentUser ? Color.blue : Color(.windowBackgroundColor))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                if let date = message.createdAt {
                    Text(date, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if !isCurrentUser { Spacer() }
        }
    }
}

struct ChatEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "message")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text("No messages yet")
                .font(.headline)
            
            Text("Start a conversation to get help and insights")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ChatLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading messages...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ChatErrorView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text("Error loading messages")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct ChatSessionRow: View {
    let session: ChatSession
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(session.title ?? "Untitled Chat")
                .font(.headline)
            if let date = session.createdAt {
                Text(date.formatted())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
