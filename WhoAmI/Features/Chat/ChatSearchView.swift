import SwiftUI
import Supabase

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
    func searchSessions() async {
        isLoading = true
        do {
            let response = try await supabase.database
                .from("chat_sessions")
                .select()
                .textSearch("title", query: searchText)
                .execute()
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let data = response.data {
                sessions = try decoder.decode([ChatSession].self, from: data)
            }
        } catch {
            print("Error searching chat sessions: \(error)")
        }
        isLoading = false
    }
    
    @MainActor
    func loadMore() async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            let nextPage = currentPage + 1
            let start = nextPage * pageSize
            let end = start + pageSize
            
            let response: [ChatSession] = try await supabase.database
                .from("chat_sessions")
                .select()
                .ilike(column: "title", pattern: "%\(searchText)%")
                .order("created_at", ascending: false)
                .range(from: start, to: end)
                .execute()
                .value
            
            sessions.append(contentsOf: response)
            currentPage = nextPage
        } catch {
            print("Error loading more chat sessions: \(error)")
        }
        
        isLoading = false
    }
}

struct ChatSearchView: View {
    @StateObject private var viewModel: ChatSearchViewModel
    @Environment(\.dismiss) private var dismiss
    
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
                                await viewModel.loadMore()
                            }
                        }
                    }
            }
        }
        .searchable(text: $viewModel.searchText)
        .onChange(of: viewModel.searchText) { _ in
            Task {
                await viewModel.searchSessions()
            }
        }
        .navigationTitle("Search Chats")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
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

extension ChatSession: Equatable {
    public static func == (lhs: ChatSession, rhs: ChatSession) -> Bool {
        lhs.id == rhs.id
    }
} 