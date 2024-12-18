import Foundation
import Supabase

@MainActor
class CourseViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var currentCourse: Course?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func loadCourses() async throws {
        let response: PostgrestResponse<[Course]> = try await supabase.database
            .from("courses")
            .select()
            .order(column: "created_at")
            .execute()
        
        courses = try response.value
    }
    
    func fetchCourses() async throws {
        let response = try await supabase.database
            .from("courses")
            .select()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let data = try JSONSerialization.data(withJSONObject: response.underlyingResponse.data)
        courses = try decoder.decode([Course].self, from: data)
    }
    
    func fetchUserCourses() async throws {
        let response = try await supabase.database
            .from("user_courses")
            .select(columns: """
                *,
                course:courses (
                    id,
                    title,
                    description,
                    image_url,
                    duration,
                    lessons,
                    created_at,
                    updated_at
                )
            """)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let data = try JSONSerialization.data(withJSONObject: response.underlyingResponse.data)
        let userCourses = try decoder.decode([UserCourseData].self, from: data)
        courses = userCourses.map { $0.course }
    }
    
    func fetchCourse(id: UUID) async throws -> Course {
        let response = try await supabase.database
            .from("courses")
            .select()
            .eq(column: "id", value: id.uuidString)
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let data = try JSONSerialization.data(withJSONObject: response.underlyingResponse.data)
        return try decoder.decode(Course.self, from: data)
    }
    
    func calculateProgress(for course: Course) -> Double {
        guard let lessons = course.lessons, !lessons.isEmpty else { return 0.0 }
        let completedCount = lessons.filter { $0.status == .completed }.count
        return Double(completedCount) / Double(lessons.count)
    }
}

struct UserCourseData: Codable {
    let id: UUID
    let userId: UUID
    let courseId: UUID
    let course: Course
    let progress: Double?
    let lastAccessedAt: Date?
    let createdAt: Date
    let updatedAt: Date
} 