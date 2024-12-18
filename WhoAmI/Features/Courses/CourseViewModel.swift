import Foundation
import Supabase
import SwiftUI

@MainActor
class CourseViewModel: ObservableObject {
    private let supabase: SupabaseClient
    private let userId: UUID
    
    @Published var courses: [Course] = []
    @Published var currentCourse: Course?
    @Published var isLoading = false
    @Published var error: Error?
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
        print("CourseViewModel initialized with userId: \(userId)")
    }
    
    func fetchCourses() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let response: PostgrestResponse<[Course]> = try await supabase.database
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
            .order("created_at")
            .execute()
        
        courses = response.value
    }
    
    func fetchEnrolledCourses() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            print("Fetching enrolled courses for user: \(userId)")
            let query = try await supabase.from("user_courses")
                .select("""
                    id,
                    user_id,
                    course_id,
                    progress,
                    started_at,
                    completed_at,
                    updated_at,
                    course:courses (
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
                            content,
                            created_at,
                            updated_at
                        ),
                        created_at,
                        updated_at
                    )
                """)
                .eq("user_id", value: userId)
            
            print("Executing query: \(String(describing: query))")
            
            let response: PostgrestResponse<[EnrolledCourseResponse]> = try await query.execute()
            print("Raw response: \(String(describing: response))")
            
            courses = response.value.map { $0.course }
            
            if courses.isEmpty {
                print("No enrolled courses found for user: \(userId)")
                // Fetch all available courses instead
                try await fetchCourses()
            } else {
                print("Found \(courses.count) enrolled courses")
                courses.forEach { course in
                    print("Enrolled course: \(course.title) (ID: \(course.id))")
                }
            }
        } catch {
            self.error = error
            print("Error fetching enrolled courses: \(error)")
            print("Error details: \(String(describing: error))")
            
            // Fallback to fetching all courses
            print("Falling back to fetching all courses...")
            try await fetchCourses()
        }
    }
    
    func enrollInCourse(_ course: Course) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            print("Enrolling user \(userId) in course \(course.id)")
            let enrollment = UserCourse(
                id: UUID(),
                userId: userId,
                courseId: course.id,
                progress: 0.0,
                startedAt: Date(),
                completedAt: nil,
                updatedAt: Date()
            )
            
            let values: [String: Any] = [
                "id": enrollment.id.uuidString,
                "user_id": enrollment.userId.uuidString,
                "course_id": enrollment.courseId,
                "progress": enrollment.progress,
                "started_at": ISO8601DateFormatter().string(from: enrollment.startedAt),
                "completed_at": NSNull(),
                "updated_at": ISO8601DateFormatter().string(from: enrollment.updatedAt)
            ]
            
            try await supabase.database.from("user_courses")
                .insert(values)
                .execute()
            
            print("Successfully enrolled in course")
            try await fetchEnrolledCourses()
        } catch {
            self.error = error
            print("Error enrolling in course: \(error)")
            print("Error details: \(String(describing: error))")
            throw error
        }
    }
    
    func unenrollFromCourse(_ course: Course) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            print("Unenrolling user \(userId) from course \(course.id)")
            try await supabase.database
                .from("user_courses")
                .delete()
                .eq("user_id", value: userId)
                .eq("course_id", value: course.id)
                .execute()
            
            print("Successfully unenrolled from course")
            try await fetchEnrolledCourses()
        } catch {
            self.error = error
            print("Error unenrolling from course: \(error)")
            print("Error details: \(String(describing: error))")
            throw error
        }
    }
}
