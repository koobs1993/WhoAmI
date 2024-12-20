import SwiftUI
import Supabase

struct TestListView: View {
    @StateObject private var viewModel: TestListViewModel
    @State private var selectedCategory: TestCategory?
    @State private var searchText = ""
    private let userId: UUID
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.userId = userId
        _viewModel = StateObject(wrappedValue: TestListViewModel(supabase: supabase))
    }
    
    private func matchesCategory(_ test: PsychTest) -> Bool {
        guard let category = selectedCategory else { return true }
        return test.category == category
    }
    
    private func matchesSearch(_ test: PsychTest) -> Bool {
        guard !searchText.isEmpty else { return true }
        return test.title.localizedCaseInsensitiveContains(searchText) ||
               test.description.localizedCaseInsensitiveContains(searchText)
    }
    
    var filteredTests: [PsychTest] {
        viewModel.tests.filter { test in
            matchesCategory(test) && matchesSearch(test)
        }
    }
    
    var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Search tests...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            #if os(iOS)
            .background(Color(uiColor: .systemBackground))
            #else
            .background(Color(nsColor: .windowBackgroundColor))
            #endif
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All Categories",
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )
                    
                    ForEach(TestCategory.allCases, id: \.self) { category in
                        FilterChip(
                            title: category.displayName,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    var testGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            ForEach(filteredTests) { test in
                NavigationLink(destination: TestSessionView(
                    supabase: viewModel.supabase,
                    userId: userId,
                    test: test
                )) {
                    TestCard(test: test)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                searchAndFilterSection
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if filteredTests.isEmpty {
                    ContentUnavailableView(
                        "No Tests Found",
                        systemImage: "magnifyingglass",
                        description: Text("Try adjusting your filters or search term")
                    )
                    .padding()
                } else {
                    testGrid
                }
            }
        }
        .navigationTitle("Tests")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .refreshable {
            await viewModel.fetchTests()
        }
        .task {
            await viewModel.fetchTests()
        }
    }
}

struct TestCard: View {
    let test: PsychTest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                Spacer()
                
                Text("\(test.durationMinutes) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(test.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(test.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(test.category.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                    
                    Spacer()
                }
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
}

#Preview {
    NavigationView {
        TestListView(supabase: Config.supabaseClient, userId: UUID())
            .environmentObject(AuthManager(supabase: Config.supabaseClient))
    }
}
