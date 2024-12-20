// Chat UI Components temporarily disabled
/*
import SwiftUI

struct ChatLoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading chat...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
    }
}

struct ChatEmptyView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundStyle(.blue.opacity(0.8))
            
            Text("Start Your Journey")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Begin a conversation with our AI assistant to explore your thoughts and feelings.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
    }
}

struct ChatErrorView: View {
    let error: Error
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.red)
            
            Text("Unable to Load Chat")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: retry) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
    }
}

struct ChatSessionRow: View {
    let session: ChatSession
    let lastMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.title ?? "New Chat")
                    .font(.headline)
                
                Spacer()
                
                if let createdAt = session.createdAt {
                    Text(createdAt.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if let lastMessage = lastMessage {
                Text(lastMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool
    
    private var backgroundColor: Color {
        if isCurrentUser {
            return .blue
        } else {
            #if os(iOS)
            return Color(uiColor: .systemGray6)
            #else
            return Color(nsColor: .controlBackgroundColor)
            #endif
        }
    }
    
    private var textColor: Color {
        isCurrentUser ? .white : .primary
    }
    
    private var alignment: HorizontalAlignment {
        isCurrentUser ? .trailing : .leading
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: 4) {
            HStack {
                if !isCurrentUser {
                    Image(systemName: "brain.head.profile")
                        .foregroundStyle(.blue)
                        .font(.system(size: 24))
                        .padding(.trailing, 4)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(backgroundColor)
                        .foregroundStyle(textColor)
                        .cornerRadius(20)
                }
                .frame(maxWidth: 280, alignment: isCurrentUser ? .trailing : .leading)
                
                if isCurrentUser {
                    Image(systemName: "person.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.system(size: 24))
                        .padding(.leading, 4)
                }
            }
            
            if let createdAt = message.createdAt {
                Text(createdAt.formatted(.relative(presentation: .numeric)))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        .padding(.horizontal)
    }
}

struct ChatInputView: View {
    @Binding var message: String
    @FocusState private var isFocused: Bool
    let isLoading: Bool
    let onSend: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                TextField("Type your message...", text: $message, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    #if os(iOS)
                    .background(Color(uiColor: .systemGray6))
                    #else
                    .background(Color(nsColor: .controlBackgroundColor))
                    #endif
                    .cornerRadius(20)
                    .focused($isFocused)
                    .disabled(isLoading)
                    .lineLimit(1...5)
                
                Button(action: {
                    onSend()
                    isFocused = false
                }) {
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "paperplane.fill")
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(width: 36, height: 36)
                    .background(message.isEmpty ? Color.blue.opacity(0.5) : Color.blue)
                    .clipShape(Circle())
                }
                .disabled(message.isEmpty || isLoading)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
    }
}
*/
