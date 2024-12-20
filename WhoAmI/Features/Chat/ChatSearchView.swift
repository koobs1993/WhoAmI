import SwiftUI
import Supabase

@MainActor
class ChatSearchViewModel: ObservableObject {
    @Published var sessions: [ChatSession] = []
    @Published var lastMessages: [UUID: String] = [:]
    @Published var isLoading = false
    @Published var error: Error?
    
    let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func fetchSessions(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: PostgrestResponse<[ChatSession], [String: AnyObject]> = try await supabase
                .from("chatsessions")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
            
            sessions = response.value
            
            // Fetch last message for each session
            for session in sessions {
                let messageResponse: PostgrestResponse<[ChatMessage], [String: AnyObject]> = try await supabase
                    .from("chat_messages")
                    .select()
                    .eq("session_id", value: session.id.uuidString)
                    .order("created_at", ascending: false)
                    .limit(1)
                    .execute()
                
                if let lastMessage = messageResponse.value.first {
                    lastMessages[session.id] = lastMessage.content
                }
            }
        } catch {
            self.error = error
        }
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct ChatSearchView: View {
    @StateObject private var viewModel: ChatSearchViewModel
    @EnvironmentObject private var authManager: AuthManager
    
    init(supabase: SupabaseClient) {
        _viewModel = StateObject(wrappedValue: ChatSearchViewModel(supabase: supabase))
    }
    
    var body: some View {
        contentView
            .navigationTitle("Chat History")
            .task {
                if let userId = authManager.currentUser?.id.uuidString {
                    await viewModel.fetchSessions(userId: userId)
                }
            }
            .refreshable {
                if let userId = authManager.currentUser?.id.uuidString {
                    await viewModel.fetchSessions(userId: userId)
                }
            }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ChatLoadingView()
        } else if let error = viewModel.error {
            ChatErrorView(error: error) {
                if let userId = authManager.currentUser?.id.uuidString {
                    Task {
                        await viewModel.fetchSessions(userId: userId)
                    }
                }
            }
        } else if viewModel.sessions.isEmpty {
            ChatEmptyView()
        } else {
            List {
                ForEach(viewModel.sessions) { session in
                    if let userId = authManager.currentUser?.id.uuidString {
                        NavigationLink {
                            ChatView(
                                chatService: ChatService(supabase: viewModel.supabase),
                                userId: userId
                            )
                        } label: {
                            ChatSessionRow(
                                session: session,
                                lastMessage: viewModel.lastMessages[session.id]
                            )
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
@available(macOS 13.0, iOS 16.0, *)
struct ChatSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatSearchView(supabase: Config.previewClient)
                .environmentObject(AuthManager(supabase: Config.previewClient))
        }
    }
}
#endif
