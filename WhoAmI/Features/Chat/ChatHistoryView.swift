import SwiftUI
import Supabase

class ChatHistoryViewModel: ObservableObject {
    @Published private(set) var sessions: [ChatSession] = []
    @Published var isLoading = false
    private var currentPage = 0
    private let pageSize = 20
    private let supabase: SupabaseClient
    private let authManager: AuthManager
    
    init(supabase: SupabaseClient, authManager: AuthManager) {
        self.supabase = supabase
        self.authManager = authManager
    }
    
    @MainActor
    func fetchSessions() async throws {
        let response: PostgrestResponse<[ChatSession]> = try await supabase.database
            .from("chat_sessions")
            .select()
            .execute()
        
        sessions = try response.value
        currentPage = 1
    }
    
    @MainActor
    func clearSessions() async throws {
        _ = try await supabase.database
            .from("chat_sessions")
            .delete()
            .execute()
    }
    
    func summarizeSession(sessionId: UUID) async throws -> String {
        let params = SummarizeParams(sessionId: sessionId.uuidString)
        let response: PostgrestResponse<String> = try await supabase.database
            .rpc(fn: "summarize_chat_session", params: params)
            .execute()
        
        return try response.value
    }
}

struct SummarizeParams: Encodable {
    let sessionId: String
    
    private enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
    }
}

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

struct ChatSessionListView: View {
    let sessions: [ChatSession]
    let rowContent: (ChatSession) -> ChatSessionRow

    var body: some View {
        List {
            ForEach(sessions) { session in
                rowContent(session)
            }
        }
    }
}

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

enum ChatError: Error {
    case invalidResponse
}
 