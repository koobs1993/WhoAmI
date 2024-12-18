import SwiftUI
import Supabase

@MainActor
class ChatSearchViewModel: ObservableObject {
    @Published var sessions: [ChatSession] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func fetchSessions(userId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: PostgrestResponse<[ChatSession]> = try await supabase.database
                .from("chatsessions")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("created_at", ascending: false)
                .execute()
            
            sessions = response.value
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
        List {
            ForEach(viewModel.sessions) { session in
                if let userId = authManager.currentUser?.id {
                    NavigationLink {
                        ChatView(
                            chatService: ChatService(supabase: viewModel.supabase),
                            sessionId: session.id,
                            userId: userId
                        )
                    } label: {
                        ChatSessionRow(session: session)
                    }
                }
            }
        }
        .navigationTitle("Chat History")
        .task {
            if let userId = authManager.currentUser?.id {
                await viewModel.fetchSessions(userId: userId)
            }
        }
        .refreshable {
            if let userId = authManager.currentUser?.id {
                await viewModel.fetchSessions(userId: userId)
            }
        }
    }
}

#Preview {
    if #available(iOS 16.0, macOS 13.0, *) {
        NavigationView {
            ChatSearchView(supabase: Config.supabaseClient)
                .environmentObject(AuthManager(supabase: Config.supabaseClient))
        }
    } else {
        Text("Preview not available")
    }
}
