import SwiftUI
import Supabase

@available(macOS 13.0, iOS 16.0, *)
struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    init(chatService: ChatService, sessionId: UUID = UUID(), userId: UUID) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(
            chatService: chatService,
            sessionId: sessionId,
            userId: userId
        ))
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ChatLoadingView()
            } else if let error = viewModel.error {
                ChatErrorView(error: error) {
                    Task {
                        await viewModel.retryFetch()
                    }
                }
            } else if viewModel.messages.isEmpty {
                ChatEmptyView()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                ChatBubble(
                                    message: message,
                                    isCurrentUser: message.userId == authManager.currentUser?.id
                                )
                                .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            ChatInputView(
                message: $viewModel.currentMessage,
                isLoading: viewModel.isLoading
            ) {
                Task {
                    await viewModel.sendMessage()
                }
            }
        }
        .navigationTitle("Chat")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    if #available(iOS 16.0, macOS 13.0, *) {
        NavigationView {
            ChatView(
                chatService: ChatService(supabase: Config.supabaseClient),
                userId: UUID()
            )
            .environmentObject(AuthManager(supabase: Config.supabaseClient))
        }
    } else {
        Text("Preview not available")
    }
}
