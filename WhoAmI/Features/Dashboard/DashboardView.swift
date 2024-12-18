import SwiftUI
import Supabase

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    let supabase: SupabaseClient
    let userId: UUID
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
    }
    
    @MainActor
    func loadCourses() async {
        isLoading = true
        error = nil
        
        do {
            let response: PostgrestResponse<[CourseData]> = try await supabase.database
                .from("user_courses")
                .select(columns: """
                    *,
                    course:courses (
                        id,
                        title,
                        description,
                        image_url,
                        duration,
                        difficulty,
                        prerequisites,
                        is_active,
                        created_at,
                        updated_at
                    )
                """)
                .eq(column: "user_id", value: userId.uuidString)
                .execute()
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let data = try JSONSerialization.data(withJSONObject: response.underlyingResponse.data)
            let userCourses = try decoder.decode([CourseData].self, from: data)
            courses = userCourses.map { courseData in
                Course(
                    id: courseData.course.id,
                    title: courseData.course.title,
                    description: courseData.course.description,
                    imageUrl: courseData.course.imageUrl,
                    estimatedDuration: courseData.course.duration,
                    lessons: [],
                    createdAt: courseData.course.createdAt,
                    updatedAt: courseData.course.updatedAt
                )
            }
        } catch {
            self.error = error
            print("Error loading courses: \(error)")
        }
        
        isLoading = false
    }
}

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    
    init(supabase: SupabaseClient, userId: UUID) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(supabase: supabase, userId: userId))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ForEach(viewModel.courses) { course in
                        CourseCard(course: course)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .task {
            await viewModel.loadCourses()
        }
    }
}

struct CourseCard: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(course.title)
                .font(.headline)
            
            Text(course.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if let duration = course.estimatedDuration {
                HStack {
                    Image(systemName: "clock")
                    Text("\(duration) minutes")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
} 