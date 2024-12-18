import SwiftUI
import Supabase

struct CourseListView: View {
    @StateObject private var viewModel: CourseViewModel
    
    init(supabase: SupabaseClient) {
        _viewModel = StateObject(wrappedValue: CourseViewModel(supabase: supabase))
    }
    
    var body: some View {
        List(viewModel.courses) { course in
            CourseRow(course: course)
        }
        .navigationTitle("Courses")
        .task {
            try? await viewModel.loadCourses()
        }
    }
}

struct CourseRow: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(course.title)
                .font(.headline)
            Text(course.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
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

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = CourseViewModel(supabase: Config.supabaseClient)
        CourseListView(supabase: Config.supabaseClient)
            .environmentObject(AuthManager(supabase: Config.supabaseClient))
            .environmentObject(viewModel)
    }
}

#Preview {
    let viewModel = CourseViewModel(supabase: Config.supabaseClient)
    CourseListView(supabase: Config.supabaseClient)
        .environmentObject(AuthManager(supabase: Config.supabaseClient))
} 