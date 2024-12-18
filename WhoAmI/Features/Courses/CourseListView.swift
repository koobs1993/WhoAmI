import SwiftUI
import Supabase

struct CourseListView: View {
    @StateObject private var viewModel: CourseViewModel
    @EnvironmentObject private var authManager: AuthManager
    
    init(supabase: SupabaseClient) {
        // We'll use a placeholder viewModel that will be replaced in body
        _viewModel = StateObject(wrappedValue: CourseViewModel(supabase: supabase, userId: UUID()))
    }
    
    var body: some View {
        Group {
            if let userId = authManager.currentUser?.id {
                // Create a new viewModel with the actual userId
                let viewModel = CourseViewModel(supabase: authManager.supabase, userId: userId)
                courseList(viewModel: viewModel)
            } else {
                Text("Please sign in to view courses")
            }
        }
    }
    
    private func courseList(viewModel: CourseViewModel) -> some View {
        List {
            ForEach(viewModel.courses) { course in
                CourseCard(course: course)
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 8)
            }
        }
        .listStyle(.plain)
        .refreshable {
            try? await viewModel.fetchCourses()
        }
        .task {
            try? await viewModel.fetchCourses()
        }
    }
}

struct CourseCard: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageUrl = course.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
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
                Text(course.title)
                    .font(.headline)
                
                if let description = course.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Label("Level \(course.difficulty)", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Label(course.category, systemImage: "folder.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let duration = course.estimatedDuration {
                    Label("\(duration) min", systemImage: "clock")
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
        CourseListView(
            supabase: Config.supabaseClient
        )
        .environmentObject(AuthManager(supabase: Config.supabaseClient))
    }
}
