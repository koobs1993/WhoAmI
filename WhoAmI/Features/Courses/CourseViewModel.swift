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
    let supabase: SupabaseClient
    let userId: UUID
    
    @Published var courses: [Course] = []
    @Published var enrolledCourses: [EnrolledCourseResponse] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    var categories: [String] {
        Array(Set(courses.map { $0.category })).sorted()
    }
    
    var difficulties: [String] {
        Array(Set(courses.map { $0.difficulty })).sorted()
    }
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
    }
    
    func fetchCourses() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Fetch all courses
        let coursesQuery = supabase
            .from("courses")
            .select("""
                course_id,
                title,
                description,
                image_url,
                difficulty,
                category,
                estimated_duration,
                lessons (
                    id,
                    course_id,
                    title,
                    description,
                    duration,
                    order,
                    content,
                    created_at,
                    updated_at
                ),
                created_at,
                updated_at
            """)
        
        let coursesResponse: PostgrestResponse<[Course]> = try await coursesQuery.execute()
        courses = coursesResponse.value
        
        // Fetch enrolled courses for the current user
        let enrolledQuery = supabase
            .from("user_courses")
            .select()
            .eq("user_id", value: userId.uuidString)
        
        let enrolledResponse: PostgrestResponse<[EnrolledCourseResponse]> = try await enrolledQuery.execute()
        enrolledCourses = enrolledResponse.value
    }
    
    func isEnrolled(in courseId: UUID) -> Bool {
        enrolledCourses.contains { $0.courseId == courseId }
    }
    
    func enroll(in courseId: UUID) async throws {
        let enrollment = EnrolledCourseResponse(
            courseId: courseId,
            userId: userId,
            enrolledAt: Date(),
            completedAt: nil
        )
        
        try await supabase
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
