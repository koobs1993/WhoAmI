import Foundation
import Supabase
import Realtime

@MainActor
class ChatViewModel: ObservableObject {
    private let supabase: SupabaseClient
    private let chatService: ChatService
    private let userId: UUID
    private var channel: Channel?
    
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var typingUsers: Set<String> = []
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.chatService = ChatService(supabase: supabase, realtime: supabase.realtime)
        self.userId = userId
    }
    
    func loadMessages(sessionId: UUID) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            messages = try await chatService.fetchMessages(sessionId: sessionId)
            subscribeToMessages(sessionId: sessionId)
        } catch {
            self.error = error
            throw error
        }
    }
    
    private func subscribeToMessages(sessionId: UUID) {
        let topic = "chat_messages:\(sessionId.uuidString)"
        channel = chatService.subscribe(topic) { [weak self] message in
            Task { @MainActor in
                self?.messages.append(message)
            }
        }
    }
    
    func sendMessage(_ content: String, sessionId: UUID) async throws {
        let message = ChatMessage(
            id: UUID(),
            sessionId: sessionId,
            userId: userId,
            role: .user,
            content: content,
            metadata: nil,
            createdAt: Date()
        )
        
        try await chatService.sendMessage(message)
    }
    
    func updateTypingStatus(isTyping: Bool, sessionId: UUID) async throws {
        if isTyping {
            typingUsers.insert(sessionId.uuidString)
        } else {
            typingUsers.remove(sessionId.uuidString)
        }
    }
    
    func cleanup() async {
        if let channel = channel {
            chatService.unsubscribe(channel)
        }
    }
    
    deinit {
        Task { @MainActor [weak self] in
            await self?.cleanup()
        }
    }
} 