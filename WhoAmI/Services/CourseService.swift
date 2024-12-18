import Foundation
import Supabase

// Request models to ensure type safety and Encodable conformance
struct UserLessonRequest: Encodable {
    let userId: UUID
    let lessonId: Int
    let status: WhoAmI.LessonStatus
    let completedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case lessonId = "lesson_id"
        case status
        case completedAt = "completed_at"
    }
}

struct UserResponseRequest: Encodable {
    let userId: UUID
    let questionId: Int
    let response: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case questionId = "question_id"
        case response
    }
}

class CourseService {
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func fetchCourses() async throws -> [Course] {
        let response: PostgrestResponse<[Course]> = try await supabase
            .from("courses")
            .select("""
                id,
                title,
                description,
                image_url,
                estimated_duration,
                lessons (
                    id,
                    title,
                    description,
                    duration,
                    order,
                    content
                ),
                created_at,
                updated_at
            """)
            .order("created_at")
            .execute()
        
        return response.value
    }
    
    func fetchCourse(id: Int) async throws -> Course? {
        let response: PostgrestResponse<Course> = try await supabase
            .from("courses")
            .select("""
                id,
                title,
                description,
                image_url,
                estimated_duration,
                lessons (
                    id,
                    title,
                    description,
                    duration,
                    order,
                    content
                ),
                created_at,
                updated_at
            """)
            .eq("id", value: String(id))
            .single()
            .execute()
        
        return response.value
    }
    
    func saveUserLesson(_ request: UserLessonRequest) async throws {
        try await supabase
            .from("user_lessons")
            .insert([
                "user_id": request.userId.uuidString,
                "lesson_id": String(request.lessonId),
                "status": request.status.rawValue,
                "completed_at": request.completedAt.map { ISO8601DateFormatter().string(from: $0) }
            ])
            .execute()
    }
    
    func updateUserLesson(userLessonId: Int, request: UserLessonRequest) async throws {
        try await supabase
            .from("user_lessons")
            .update([
                "user_id": request.userId.uuidString,
                "lesson_id": String(request.lessonId),
                "status": request.status.rawValue,
                "completed_at": request.completedAt.map { ISO8601DateFormatter().string(from: $0) }
            ])
            .eq("id", value: String(userLessonId))
            .execute()
    }
    
    func saveUserResponse(_ request: UserResponseRequest) async throws {
        try await supabase
            .from("user_responses")
            .insert([
                "user_id": request.userId.uuidString,
                "question_id": String(request.questionId),
                "response": request.response
            ])
            .execute()
    }
}
