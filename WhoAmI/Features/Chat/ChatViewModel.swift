import Foundation
import Supabase
import Realtime

@MainActor
class ChatViewModel: ObservableObject {
    let supabase: SupabaseClient
    private let chatService: ChatService
    private var messageSubscription: Channel?
    private var typingSubscription: Channel?
    
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isTyping = false
    
    private let userId: UUID
    private var currentSessionId: UUID?
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.chatService = ChatService(supabase: supabase)
        self.userId = userId
    }
    
    func loadMessages(sessionId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            messages = try await chatService.fetchMessages(sessionId: sessionId)
            currentSessionId = sessionId
            subscribeToMessages(sessionId: sessionId)
        } catch {
            self.error = error
        }
    }
    
    func sendMessage(_ content: String) async {
        guard let sessionId = currentSessionId else { return }
        
        let values: [String: Any] = [
            "session_id": sessionId.uuidString,
            "user_id": userId.uuidString,
            "role": MessageRole.user.rawValue,
            "content": content
        ]
        
        do {
            let message = try await chatService.sendMessage(values)
            messages.append(message)
        } catch {
            self.error = error
        }
    }
    
    private func subscribeToMessages(sessionId: UUID) {
        messageSubscription?.unsubscribe()
        messageSubscription = chatService.subscribeToMessages(sessionId: sessionId) { [weak self] message in
            Task { @MainActor in
                self?.messages.append(message)
            }
        }
    }
    
    func cleanup() {
        if let subscription = messageSubscription {
            chatService.unsubscribe(subscription)
        }
        if let subscription = typingSubscription {
            chatService.unsubscribe(subscription)
        }
        messageSubscription = nil
        typingSubscription = nil
    }
} 