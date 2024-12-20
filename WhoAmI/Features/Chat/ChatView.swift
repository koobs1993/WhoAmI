import SwiftUI
import Supabase

@available(macOS 13.0, iOS 16.0, *)
struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var showScrollToBottom = false
    @State private var isAtBottom = true
    
    init(chatService: ChatService, userId: String) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(
            chatService: chatService,
            userId: userId
        ))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.isLoading && viewModel.messages.isEmpty {
                    ChatLoadingView()
                } else if let error = viewModel.error {
                    ChatErrorView(error: error) {
                        Task {
                            await viewModel.setupChat()
                        }
                    }
                } else if viewModel.messages.isEmpty {
                    ChatEmptyView()
                } else {
                    VStack(spacing: 0) {
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.messages) { message in
                                        ChatBubble(
                                            message: message,
                                            isCurrentUser: message.userId == authManager.currentUser?.id.uuidString
                                        )
                                        .id(message.id)
                                        .transition(.opacity)
                                    }
                                }
                                .padding(.vertical)
                            }
                            .scrollIndicators(.hidden)
                            .onChange(of: viewModel.messages.count) { oldValue, newValue in
                                if isAtBottom {
                                    withAnimation(.spring(response: 0.3)) {
                                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                                    }
                                }
                            }
                            .simultaneousGesture(
                                DragGesture().onChanged { value in
                                    let threshold: CGFloat = 50
                                    isAtBottom = value.translation.height < threshold
                                    showScrollToBottom = !isAtBottom
                                }
                            )
                            
                            if showScrollToBottom {
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                                        showScrollToBottom = false
                                        isAtBottom = true
                                    }
                                } label: {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                        .frame(width: 36, height: 36)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        
                        if viewModel.isLoading {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("AI is typing...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
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
                }
            }
        }
        .navigationTitle("Chat")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.clearChat()
                        }
                    } label: {
                        Label("Clear Chat", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        #else
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Menu {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.clearChat()
                        }
                    } label: {
                        Label("Clear Chat", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        #endif
    }
}

#if DEBUG
@available(macOS 13.0, iOS 16.0, *)
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView(
                chatService: ChatService(supabase: Config.previewClient),
                userId: UUID().uuidString
            )
            .environmentObject(AuthManager(supabase: Config.previewClient))
        }
    }
}
#endif
