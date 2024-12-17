import Foundation
import Supabase

enum CourseError: LocalizedError {
    case fetchFailed
    case notFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Failed to fetch course data"
        case .notFound:
            return "Course not found"
        case .invalidData:
            return "Invalid course data"
        }
    }
}

actor CourseService {
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func fetchCourses() async throws -> [Course] {
        let query = supabase.database
            .from("courses")
            .select("*")
        
        let response = try await query.execute()
        return try response.value
    }
    
    func fetchCourseDetails(_ courseId: Int) async throws -> Course {
        let query = supabase.database
            .from("courses")
            .select("*, lessons(*)")
            .eq("id", value: courseId)
            .single()
        
        let response = try await query.execute()
        return try response.value
    }
    
    func startUserLesson(userCourseId: Int, lessonId: Int) async throws {
        let query = supabase.database
            .from("user_lessons")
            .insert([
                "user_course_id": userCourseId,
                "lesson_id": lessonId,
                "status": "in_progress"
            ])
        
        _ = try await query.execute()
    }
    
    func completeUserLesson(userCourseId: Int, lessonId: Int) async throws {
        let query = supabase.database
            .from("user_lessons")
            .update([
                "status": "completed",
                "completion_date": Date()
            ])
            .eq("user_course_id", value: userCourseId)
            .eq("lesson_id", value: lessonId)
        
        _ = try await query.execute()
    }
    
    func saveLessonResponse(userLessonId: Int, questionId: Int, response: String) async throws {
        let query = supabase.database
            .from("user_responses")
            .insert([
                "user_lesson_id": userLessonId,
                "question_id": questionId,
                "response": response
            ])
        
        _ = try await query.execute()
    }
} 