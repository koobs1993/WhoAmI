import SwiftUI
import Supabase

@MainActor
class ChatViewModel: ObservableObject {
    private let chatService: ChatService
    private var channel: RealtimeChannel?
    
    @Published var messages: [ChatMessage] = []
    @Published var currentMessage = ""
    @Published var isLoading = false
    @Published var error: Error?
    
    init(chatService: ChatService) {
        self.chatService = chatService
        print("ChatViewModel initialized")
        Task {
            await setupChat()
        }
    }
    
    private func setupChat() async {
        await fetchMessages()
        await connectToRealtimeChannel()
    }
    
    private func connectToRealtimeChannel() async {
        do {
            // Ensure we have a valid session before subscribing
            let session = try await chatService.supabase.auth.session
            print("Setting up realtime channel with session: \(session.accessToken)")
            
            channel = chatService.subscribe("chat_messages") { [weak self] message in
                Task { @MainActor in
                    self?.messages.append(message)
                    // Sort messages by timestamp
                    self?.messages.sort { ($0.createdAt ?? Date()) < ($1.createdAt ?? Date()) }
                }
            }
            
            print("Successfully subscribed to chat channel")
        } catch {
            print("Failed to connect to realtime channel: \(error)")
            self.error = error
        }
    }
    
    func sendMessage(_ content: String) async {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        do {
            // Get the current user's ID from the session
            let session = try await chatService.supabase.auth.session
            let userId = session.user.id
            
            let message = ChatMessage(
                sessionId: UUID(),
                content: content,
                role: .user,
                createdAt: Date(),
                userId: userId
            )
            
            try await chatService.sendMessage(message)
            currentMessage = ""
            print("Message sent successfully")
        } catch {
            print("Error sending message: \(error)")
            self.error = error
        }
    }
    
    private func fetchMessages() async {
        isLoading = true
        do {
            messages = try await chatService.fetchMessages()
            messages.sort { ($0.createdAt ?? Date()) < ($1.createdAt ?? Date()) }
            print("Fetched \(messages.count) messages")
        } catch {
            print("Error fetching messages: \(error)")
            self.error = error
        }
        isLoading = false
    }
    
    func retryFetch() async {
        error = nil
        if let channel = channel {
            chatService.unsubscribe(channel)
        }
        channel = nil
        await setupChat()
    }
    
    deinit {
        if let channel = channel {
            chatService.unsubscribe(channel)
        }
        print("ChatViewModel deinitialized")
    }
}
