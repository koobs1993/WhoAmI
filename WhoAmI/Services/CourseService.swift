import Foundation
import Supabase

class CourseService {
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func fetchCourses() async throws -> [Course] {
        let response: [Course] = try await supabase.database
            .from("courses")
            .select()
            .order(column: "created_at")
            .execute()
            .value
        
        return response
    }
    
    func fetchCourse(id: Int) async throws -> Course {
        let response: Course = try await supabase.database
            .from("courses")
            .select()
            .eq(column: "id", value: id)
            .single()
            .execute()
            .value
        
        return response
    }
    
    func createUserLesson(values: [String: String]) async throws {
        try await supabase.database
            .from("user_lessons")
            .insert(values: values)
            .execute()
    }
    
    func updateUserLesson(userLessonId: Int, values: [String: String]) async throws {
        try await supabase.database
            .from("user_lessons")
            .update(values: values)
            .eq(column: "id", value: userLessonId)
            .execute()
    }
    
    func saveUserResponse(values: [String: String]) async throws {
        try await supabase.database
            .from("user_responses")
            .insert(values: values)
            .execute()
    }
} 