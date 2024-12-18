import SwiftUI
import Supabase

struct TestListView: View {
    @StateObject private var viewModel: TestListViewModel
    @EnvironmentObject private var authManager: AuthManager
    
    init(supabase: SupabaseClient) {
        _viewModel = StateObject(wrappedValue: TestListViewModel(supabase: supabase))
    }
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading tests...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("Error Loading Tests")
                        .font(.headline)
                    
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Try Again") {
                        Task {
                            await viewModel.retryFetch()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if viewModel.tests.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clipboard")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No Tests Available")
                        .font(.headline)
                    
                    Text("Check back later for new tests")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.tests) { test in
                        NavigationLink(
                            destination: TestDetailView(test: test)
                        ) {
                            TestCard(test: test)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Tests")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            await viewModel.fetchTests()
        }
    }
}

struct TestCard: View {
    let test: PsychTest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageUrl = test.imageUrl {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 120)
                .clipped()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(test.title)
                    .font(.headline)
                
                Text(test.shortDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Label("\(test.durationMinutes) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Label("\(test.questions.count) questions", systemImage: "list.bullet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .textBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    NavigationView {
        TestListView(supabase: Config.supabaseClient)
            .environmentObject(AuthManager(supabase: Config.supabaseClient))
    }
}
