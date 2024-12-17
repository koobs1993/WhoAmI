import SwiftUI
import Supabase

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var courses: [UserCourse] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let supabase: SupabaseClient
    private let userId: UUID
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
    }
    
    func fetchDashboardData() async {
        isLoading = true
        do {
            let query = supabase.database
                .from("user_courses")
                .select(columns: "*, course:courses(*)")
                .eq(column: "user_id", value: userId)
            
            let response: PostgrestResponse<[UserCourse]> = try await query.execute()
            let courseData = response.value ?? []
            
            await MainActor.run {
                self.courses = courseData
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    func calculateCourseProgress(_ progress: CourseProgress?) -> Double {
        guard let progress = progress else { return 0.0 }
        return Double(progress.completedLessons) / Double(progress.totalLessons)
    }
}

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    
    init(supabase: SupabaseClient, userId: UUID) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(supabase: supabase, userId: userId))
    }
    
    private func loadUserCourses() async {
        do {
            let query = viewModel.supabase.database
                .from("user_courses")
                .select("*")
                .eq("user_id", value: viewModel.userId.uuidString)
            
            let response: PostgrestResponse<[UserCourse]> = try await query.execute()
            let courseData = response.value ?? []
            
            await MainActor.run {
                viewModel.userCourses = courseData
            }
        } catch {
            print("Error loading user courses: \(error)")
        }
    }
    
    private func calculateCourseProgress(_ progress: CourseProgress?) -> Double {
        guard let progress = progress else { return 0.0 }
        return progress.progressPercentage
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    // Courses Section
                    if !viewModel.courses.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Your Courses")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.courses) { userCourse in
                                        CourseView(
                                            course: userCourse.course,
                                            progress: viewModel.calculateCourseProgress(userCourse.progress)
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Dashboard")
        .task {
            await loadUserCourses()
        }
        .refreshable {
            await loadUserCourses()
        }
    }
}

struct CourseView: View {
    let course: Course
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            if let imageUrl = course.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Text(course.title)
                .font(.headline)
                .lineLimit(2)
            
            ProgressView(value: progress)
                .tint(.blue)
            
            Text("\(Int(progress * 100))% Complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 200)
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
} 