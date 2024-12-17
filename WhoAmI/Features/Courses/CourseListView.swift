import SwiftUI

struct CourseListView: View {
    @StateObject var viewModel: CourseViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.isLoading {
                ProgressView()
            } else {
                List(viewModel.courses) { course in
                    NavigationLink(destination: CourseDetailView(course: course, viewModel: viewModel)) {
                        CourseRowView(course: course)
                    }
                }
                .navigationTitle("Courses")
                .task {
                    await viewModel.fetchCourses()
                }
            }
        }
    }
}

struct CourseRowView: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(course.title)
                .font(.headline)
            
            Text(course.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                if let imageUrl = course.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                    Text("\(course.estimatedDuration ?? 0) min")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct CourseEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Courses Available")
                .font(.headline)
            
            Text("Check back later for new courses")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    let viewModel = CourseViewModel(supabase: Config.supabaseClient, userId: UUID())
    return CourseListView(viewModel: viewModel)
        .environmentObject(AuthManager(supabase: Config.supabaseClient))
} 