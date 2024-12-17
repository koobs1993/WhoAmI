import SwiftUI
import Supabase

class ChatHistoryViewModel: ObservableObject {
    @Published private(set) var sessions: [ChatSession] = []
    @Published var isLoading = false
    private var currentPage = 0
    private let pageSize = 20
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    @MainActor
    func loadSessions() async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            let response: [ChatSession] = try await supabase.database
                .from("chat_sessions")
                .select()
                .order("created_at", ascending: false)
                .range(from: 0, to: pageSize)
                .execute()
                .value
            
            sessions = response
            currentPage = 1
        } catch {
            print("Error loading chat sessions: \(error)")
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadMore() async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            let start = currentPage * pageSize
            let end = start + pageSize
            
            let response: [ChatSession] = try await supabase.database
                .from("chat_sessions")
                .select()
                .order("created_at", ascending: false)
                .range(from: start, to: end)
                .execute()
                .value
            
            sessions.append(contentsOf: response)
            currentPage += 1
        } catch {
            print("Error loading more chat sessions: \(error)")
        }
        
        isLoading = false
    }
    
    func deleteSessions() async {
        do {
            try await supabase.database
                .from("chat_sessions")
                .delete()
                .eq("user_id", value: userId)
                .execute()
            sessions = []
        }
    }
    
    func summarizeSession(session: ChatSession) async throws -> String {
        let params: [String: Encodable] = ["session_id": session.id]
        let response = try await supabase.database
            .rpc(fn: "summarize_chat_session", params: params)
            .execute()
            .data
        
        guard let summary = response as? [String: Any],
              let text = summary["summary"] as? String else {
            throw ChatError.invalidResponse
        }
        return text
    }
}

struct ChatHistoryView: View {
    @StateObject private var viewModel: ChatHistoryViewModel
    
    init(supabase: SupabaseClient) {
        _viewModel = StateObject(wrappedValue: ChatHistoryViewModel(supabase: supabase))
    }
    
    var body: some View {
        ChatSessionListView(sessions: viewModel.sessions) { session in
            // Session row content
            ChatSessionRow(session: session)
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
 