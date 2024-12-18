import SwiftUI
import Supabase

@MainActor
class ChatSearchViewModel: ObservableObject {
    @Published var sessions: [ChatSession] = []
    @Published var searchText = ""
    @Published var currentPage = 1
    let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func fetchSessions() async throws {
        let response: PostgrestResponse<[ChatSession]> = try await supabase.database
            .from("chat_sessions")
            .select()
            .order("created_at", ascending: false)
            .limit(20)
            .range(from: 0, to: 19)
            .execute()
        
        sessions = response.value
    }
    
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
        sessions.append(contentsOf: newSessions)
        currentPage += 1
    }
}

@available(macOS 13.0, *)
struct ChatSearchView: View {
    @StateObject private var viewModel: ChatSearchViewModel
    @EnvironmentObject private var authManager: AuthManager
    
    init(supabase: SupabaseClient) {
        _viewModel = StateObject(wrappedValue: ChatSearchViewModel(supabase: supabase))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.sessions) { session in
                NavigationLink {
                    ChatView(chatService: ChatService(
                        supabase: viewModel.supabase,
                        realtime: viewModel.supabase.realtime
                    ))
                } label: {
                    VStack(alignment: .leading) {
                        let title = session.title ?? "Untitled Chat"
                        Text(title)
                            .font(.headline)
                        
                        if let lastMessage = session.lastMessage {
                            Text(lastMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Text(session.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Chat History")
        .searchable(text: $viewModel.searchText)
        .task {
            do {
                try await viewModel.fetchSessions()
            } catch {
                print("Error fetching sessions: \(error)")
            }
        }
    }
}

// Fallback view for older macOS versions
struct ChatSearchViewFallback: View {
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Chat Feature Unavailable")
                .font(.headline)
            Text("This feature requires macOS 13.0 or later")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("Chat History")
    }
}

#if DEBUG
@available(macOS 13.0, *)
struct ChatSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatSearchView(supabase: Config.supabaseClient)
                .environmentObject(AuthManager(supabase: Config.supabaseClient))
        }
    }
}
#endif
