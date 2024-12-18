import SwiftUI
import Supabase

extension ChatSession: Equatable {
    public static func == (lhs: ChatSession, rhs: ChatSession) -> Bool {
        lhs.id == rhs.id
    }
}

class ChatSearchViewModel: ObservableObject {
    @Published private(set) var sessions: [ChatSession] = []
    @Published var isLoading = false
    @Published var searchText = ""
    private var currentPage = 0
    private let pageSize = 20
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    @MainActor
    func searchSessions() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let response: PostgrestResponse<[ChatSession]> = try await supabase.database
            .from("chat_sessions")
            .select()
            .textSearch(column: "title", query: searchText)
            .execute()
        
        sessions = try response.value
    }
    
    @MainActor
    func loadMore() async throws {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        let nextPage = currentPage + 1
        let start = nextPage * pageSize
        let end = start + pageSize
        
        let response: PostgrestResponse<[ChatSession]> = try await supabase.database
            .from("chat_sessions")
            .select()
            .ilike(column: "title", value: "%\(searchText)%")
            .order(column: "created_at", ascending: false)
            .range(from: start, to: end)
            .execute()
        
        let newSessions = try response.value
        sessions.append(contentsOf: newSessions)
        currentPage = nextPage
    }
}

struct ChatSearchView: View {
    @StateObject private var viewModel: ChatSearchViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var error: Error?
    @State private var showError = false
    
    init(supabase: SupabaseClient) {
        _viewModel = StateObject(wrappedValue: ChatSearchViewModel(supabase: supabase))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.sessions) { session in
                ChatSessionCard(session: session)
                    .onAppear {
                        if session.id == viewModel.sessions.last?.id {
                            Task {
                                try? await viewModel.loadMore()
                            }
                        }
                    }
            }
        }
        .searchable(text: $viewModel.searchText)
        .onChange(of: viewModel.searchText) { _, newValue in
            Task {
                do {
                    try await viewModel.searchSessions()
                } catch {
                    self.error = error
                    self.showError = true
                }
            }
        }
        .navigationTitle("Search Chats")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: {
                #if os(macOS)
                return .automatic
                #else
                return .navigationBarTrailing
                #endif
            }()) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(error?.localizedDescription ?? "An unknown error occurred")
        }
    }
}

struct ChatSessionCard: View {
    let session: ChatSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.title ?? "Untitled Chat")
                .font(.headline)
            
            Text(session.createdAt, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
} 