import Foundation
import Supabase
import SwiftUI

struct EnrolledCourseResponse: Codable {
    let courseId: UUID
    let userId: UUID
    let enrolledAt: Date
    let completedAt: Date?
}

@MainActor
class CourseViewModel: ObservableObject {
    private let supabase: SupabaseClient
    private let userId: UUID
    
    @Published var courses: [Course] = []
    @Published var enrolledCourses: [EnrolledCourseResponse] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
    }
    
    func fetchCourses() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let query = try await supabase.database
            .from("user_courses")
            .select()
            .eq("user_id", value: userId.uuidString)
        
        let response: PostgrestResponse<[EnrolledCourseResponse]> = try await query.execute()
        enrolledCourses = response.value
        
        // Fetch full course details
        if !enrolledCourses.isEmpty {
            let courseIds = enrolledCourses.map { $0.courseId.uuidString }
            let coursesQuery = try await supabase.database
                .from("courses")
                .select("""
                    id,
                    title,
                    description,
                    image_url,
                    difficulty,
                    category,
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
                .eq("id", value: courseIds[0]) // Temporary solution: fetch first course
                // TODO: Implement proper IN query when available
            
            let coursesResponse: PostgrestResponse<[Course]> = try await coursesQuery.execute()
            courses = coursesResponse.value
        }
    }
    
    func enroll(in courseId: UUID) async throws {
        let enrollment = EnrolledCourseResponse(
            courseId: courseId,
            userId: userId,
            enrolledAt: Date(),
            completedAt: nil
        )
        
        try await supabase.database
            .from("user_courses")
            .insert([
                "course_id": enrollment.courseId.uuidString,
                "user_id": enrollment.userId.uuidString,
                "enrolled_at": ISO8601DateFormatter().string(from: enrollment.enrolledAt),
                "completed_at": nil
            ])
            .execute()
        
        try await fetchCourses()
    }
}
