import SwiftUI
import Supabase

@available(macOS 12.0, *)
class ChatHistoryViewModel: ObservableObject {
    @Published var sessions: [ChatSession] = []
    @Published var currentPage = 1
    @Published var isLoading = false
    
    private let supabase: SupabaseClient
    private let authManager: AuthManager
    
    init(supabase: SupabaseClient, authManager: AuthManager) {
        self.supabase = supabase
        self.authManager = authManager
    }
    
    @MainActor
    func fetchSessions() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let response: PostgrestResponse<[ChatSession]> = try await supabase.database
            .from("chat_sessions")
            .select()
            .order("created_at", ascending: false)
            .limit(20)
            .range(from: 0, to: 19)
            .execute()
        
        sessions = response.value
        currentPage = 1
    }
    
    @MainActor
    func loadMoreSessions() async throws {
        let nextPage = currentPage + 1
        let offset = (nextPage - 1) * 20
        
        let response: PostgrestResponse<[ChatSession]> = try await supabase.database
            .from("chat_sessions")
            .select()
            .order("created_at", ascending: false)
            .limit(20)
            .range(from: offset, to: offset + 19)
            .execute()
        
        let newSessions = response.value
        if !newSessions.isEmpty {
            currentPage = nextPage
            sessions.append(contentsOf: newSessions)
        }
    }
}

@available(macOS 12.0, *)
struct ChatHistoryView: View {
    @StateObject private var viewModel: ChatHistoryViewModel
    @State private var error: Error?
    @State private var showError = false
    
    init(supabase: SupabaseClient, authManager: AuthManager) {
        _viewModel = StateObject(wrappedValue: ChatHistoryViewModel(supabase: supabase, authManager: authManager))
    }
    
    var body: some View {
        ChatSessionListView(sessions: viewModel.sessions) { session in
            ChatSessionRow(session: session)
        }
        .task {
            do {
                try await viewModel.fetchSessions()
            } catch {
                self.error = error
                self.showError = true
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(error?.localizedDescription ?? "An unknown error occurred")
        }
    }
}

@available(macOS 12.0, *)
struct ChatSessionListView: View {
    let sessions: [ChatSession]
    let rowContent: (ChatSession) -> ChatSessionRow
    
    init(sessions: [ChatSession], @ViewBuilder rowContent: @escaping (ChatSession) -> ChatSessionRow) {
        self.sessions = sessions
        self.rowContent = rowContent
    }
    
    var body: some View {
        List(sessions) { session in
            rowContent(session)
        }
    }
}

@available(macOS 12.0, *)
struct ChatSessionRow: View {
    let session: ChatSession
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(session.title ?? "Untitled Chat")
                .font(.headline)
            Text(session.createdAt.formatted())
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#if DEBUG
@available(macOS 12.0, *)
struct ChatHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ChatHistoryView(supabase: Config.supabaseClient, authManager: AuthManager(supabase: Config.supabaseClient))
    }
}
#endif
 