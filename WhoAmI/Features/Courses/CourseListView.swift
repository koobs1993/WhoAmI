import SwiftUI
import Supabase

struct CourseListView: View {
    @StateObject private var viewModel: CourseViewModel
    @State private var selectedCategory: String?
    @State private var selectedDifficulty: String?
    @State private var searchText = ""
    @State private var showFilters = false
    
    init(supabase: SupabaseClient, userId: UUID) {
        _viewModel = StateObject(wrappedValue: CourseViewModel(supabase: supabase, userId: userId))
    }
    
    private func matchesCategory(_ course: Course) -> Bool {
        guard let category = selectedCategory else { return true }
        return course.category == category
    }
    
    private func matchesDifficulty(_ course: Course) -> Bool {
        guard let difficulty = selectedDifficulty else { return true }
        return course.difficulty == difficulty
    }
    
    private func matchesSearch(_ course: Course) -> Bool {
        guard !searchText.isEmpty else { return true }
        return course.title.localizedCaseInsensitiveContains(searchText) ||
               (course.description?.localizedCaseInsensitiveContains(searchText) ?? false)
    }
    
    var filteredCourses: [Course] {
        viewModel.courses.filter { course in
            matchesCategory(course) &&
            matchesDifficulty(course) &&
            matchesSearch(course)
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                VStack(spacing: 12) {
                    SearchBar(text: $searchText)
                    CategoryFilterSection(
                        selectedCategory: $selectedCategory,
                        categories: viewModel.categories
                    )
                    DifficultyFilterSection(
                        selectedDifficulty: $selectedDifficulty,
                        difficulties: viewModel.difficulties
                    )
                }
                .padding(.vertical)
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if filteredCourses.isEmpty {
                    ContentUnavailableView(
                        "No Courses Found",
                        systemImage: "books.vertical",
                        description: Text("Try adjusting your filters or search term")
                    )
                    .padding()
                } else {
                    CourseGrid(
                        courses: filteredCourses,
                        supabase: viewModel.supabase,
                        userId: viewModel.userId
                    )
                }
            }
        }
        .navigationTitle("Courses")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .refreshable {
            try? await viewModel.fetchCourses()
        }
        .task {
            try? await viewModel.fetchCourses()
        }
    }
}

#Preview {
    NavigationView {
        CourseListView(supabase: Config.supabaseClient, userId: UUID())
            .environmentObject(AuthManager(supabase: Config.supabaseClient))
    }
}
