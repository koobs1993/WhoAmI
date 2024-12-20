// import SwiftUI
// import Supabase

/*
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentMessage = ""
    @Published var isLoading = false
    @Published var error: Error?
    
    private let chatService: ChatService
    private var sessionId: UUID?
    private let userId: UUID
    private var isFirstLoad = true
    
    init(chatService: ChatService, userId: UUID) {
        self.chatService = chatService
        self.userId = userId
        print("ChatViewModel initialized")
        Task {
            await setupChat()
        }
    }
    
    func setupChat() async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            // Create or fetch session
            if sessionId == nil {
                let session = try await chatService.createSession(userId: userId)
                sessionId = session.id
                print("Created new chat session: \(session.id)")
            }
            
            guard let sessionId = sessionId else {
                throw ChatError.sessionNotFound
            }
            
            await fetchMessages(sessionId: sessionId)
            
            if isFirstLoad {
                await setupRealtimeSubscription()
                isFirstLoad = false
            }
            
            error = nil
        } catch {
            print("Error setting up chat: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
    
    private func setupRealtimeSubscription() async {
        do {
            chatService.subscribe { [weak self] message in
                guard let self = self else { return }
                withAnimation(.spring(response: 0.3)) {
                    self.messages.append(message)
                    // Sort messages by timestamp
                    self.messages.sort { ($0.createdAt ?? Date()) < ($1.createdAt ?? Date()) }
                }
            }
            
            try await chatService.connect()
            print("Realtime connection established")
        } catch {
            print("Error setting up realtime subscription: \(error)")
            self.error = error
        }
    }
    
    func sendMessage() async {
        guard !currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let sessionId = sessionId else { return }
        
        let messageToSend = currentMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        currentMessage = ""
        isLoading = true
        
        do {
            try await chatService.sendMessage(messageToSend, sessionId: sessionId, userId: userId)
            print("Message sent successfully")
            error = nil
        } catch {
            print("Error sending message: \(error)")
            self.error = error
            // Restore the message if sending failed
            currentMessage = messageToSend
            
            // Show error briefly then clear it
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                withAnimation {
                    self?.error = nil
                }
            }
        }
        
        isLoading = false
    }
    
    private func fetchMessages(sessionId: UUID) async {
        do {
            let fetchedMessages = try await chatService.fetchMessages(sessionId: sessionId)
            withAnimation(.spring(response: 0.3)) {
                messages = fetchedMessages.sorted { ($0.createdAt ?? Date()) < ($1.createdAt ?? Date()) }
            }
            print("Fetched \(messages.count) messages")
            error = nil
        } catch {
            print("Error fetching messages: \(error)")
            self.error = error
        }
    }
    
    func clearChat() async {
        guard let sessionId = sessionId else { return }
        isLoading = true
        
        do {
            try await chatService.clearMessages(sessionId: sessionId)
            withAnimation(.spring(response: 0.3)) {
                messages = []
            }
            error = nil
        } catch {
            print("Error clearing chat: \(error)")
            self.error = error
            
            // Show error briefly then clear it
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                withAnimation {
                    self?.error = nil
                }
            }
        }
        
        isLoading = false
    }
    
    deinit {
        Task {
            await chatService.disconnect()
        }
        print("ChatViewModel deinitialized")
    }
}
*/
