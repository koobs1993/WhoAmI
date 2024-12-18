import SwiftUI
import Supabase

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentMessage = ""
    @Published var isLoading = false
    @Published var error: Error?
    
    private let chatService: ChatService
    private let sessionId: UUID
    private let userId: UUID
    
    init(chatService: ChatService, sessionId: UUID = UUID(), userId: UUID) {
        self.chatService = chatService
        self.sessionId = sessionId
        self.userId = userId
        print("ChatViewModel initialized")
        Task {
            await setupChat()
        }
    }
    
    private func setupChat() async {
        await fetchMessages()
        await setupRealtimeSubscription()
    }
    
    private func setupRealtimeSubscription() async {
        do {
            chatService.subscribe { [weak self] message in
                guard let self = self else { return }
                self.messages.append(message)
                // Sort messages by timestamp
                self.messages.sort { ($0.createdAt ?? Date()) < ($1.createdAt ?? Date()) }
            }
            
            try await chatService.connect()
            print("Realtime connection established")
        } catch {
            print("Error setting up realtime subscription: \(error)")
            self.error = error
        }
    }
    
    func sendMessage() async {
        guard !currentMessage.isEmpty else { return }
        let messageToSend = currentMessage
        currentMessage = ""
        isLoading = true
        
        do {
            try await chatService.sendMessage(messageToSend, sessionId: sessionId, userId: userId)
            print("Message sent successfully")
        } catch {
            print("Error sending message: \(error)")
            self.error = error
            // Restore the message if sending failed
            currentMessage = messageToSend
        }
        
        isLoading = false
    }
    
    private func fetchMessages() async {
        isLoading = true
        do {
            messages = try await chatService.fetchMessages(sessionId: sessionId)
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
        await setupChat()
    }
    
    deinit {
        chatService.disconnect()
        print("ChatViewModel deinitialized")
    }
}
