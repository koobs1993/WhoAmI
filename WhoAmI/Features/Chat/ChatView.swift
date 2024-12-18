import SwiftUI
import Supabase

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    let channelId: UUID
    @State private var message = ""
    
    init(supabase: SupabaseClient, channelId: UUID, userId: UUID) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(supabase: supabase, userId: userId))
        self.channelId = channelId
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                MessageScrollView(viewModel: viewModel)
                    .onChange(of: viewModel.typingUsers.isEmpty) { isEmpty in
                        if !isEmpty {
                            withAnimation {
                                proxy.scrollTo("typing", anchor: .bottom)
                            }
                        }
                    }
                
                if !viewModel.typingUsers.isEmpty {
                    TypingIndicatorView(typingUsers: viewModel.typingUsers)
                        .id("typingIndicator")
                }
            }
        }
        
        MessageInputView(viewModel: viewModel, channelId: channelId)
    }
}

private struct ChatContentView: View {
    @ObservedObject var viewModel: ChatViewModel
    let channelId: UUID
    
    var body: some View {
        VStack {
            MessagesView(viewModel: viewModel)
            MessageInputView(viewModel: viewModel, channelId: channelId)
        }
    }
}

private struct MessagesView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        MessageScrollView(viewModel: viewModel)
    }
}

private struct MessageScrollView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                MessageList(viewModel: viewModel)
                    .onChange(of: viewModel.messages.count) { _, _ in
                        scrollToLastMessage(proxy: proxy)
                    }
                    .onChange(of: viewModel.typingUsers.isEmpty) { _, _ in
                        scrollToTypingIndicator(proxy: proxy)
                    }
            }
        }
    }
    
    private func scrollToLastMessage(proxy: ScrollViewProxy) {
        if let lastMessage = viewModel.messages.last {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    private func scrollToTypingIndicator(proxy: ScrollViewProxy) {
        if !viewModel.typingUsers.isEmpty {
            withAnimation {
                proxy.scrollTo("typingIndicator", anchor: .bottom)
            }
        }
    }
}

private struct MessageList: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.messages) { message in
                MessageView(message: message)
                    .id(message.id)
            }
            
            if !viewModel.typingUsers.isEmpty {
                TypingIndicatorView(typingUsers: viewModel.typingUsers)
                    .id("typingIndicator")
            }
        }
        .padding(.vertical)
    }
}

private struct MessageInputView: View {
    @ObservedObject var viewModel: ChatViewModel
    let channelId: UUID
    @State private var messageText = ""
    
    var body: some View {
        MessageInput(
            text: $messageText,
            onSend: {
                Task {
                    try? await viewModel.sendMessage(messageText, sessionId: channelId)
                    messageText = ""
                }
            },
            onTyping: { isTyping in
                Task {
                    try? await viewModel.updateTypingStatus(isTyping: isTyping, sessionId: channelId)
                }
            }
        )
    }
}

private struct ChatMessageInput: View {
    @Binding var text: String
    let onSend: () -> Void
    let onTyping: (Bool) -> Void
    
    var body: some View {
        HStack {
            TextField("Type a message...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: text) { _, newValue in
                    onTyping(!newValue.isEmpty)
                }
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(text.isEmpty ? .gray : .blue)
            }
            .disabled(text.isEmpty)
        }
        .padding()
    }
} 