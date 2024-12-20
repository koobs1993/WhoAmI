import Foundation
import Supabase
import SwiftUI

@MainActor
class CourseDetailViewModel: ObservableObject {
    private let supabase: SupabaseClient
    private let userId: UUID
    
    @Published var course: Course
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isEnrolled = false
    @Published var enrolledCount = 0
    @Published var progress: Double = 0.0
    @Published var sections: [CourseSection] = []
    
    init(supabase: SupabaseClient, userId: UUID, course: Course) {
        self.supabase = supabase
        self.userId = userId
        self.course = course
        self.sections = course.sections ?? []
        
        Task {
            await checkEnrollmentStatus()
            await fetchEnrolledCount()
        }
    }
    
    func checkEnrollmentStatus() async {
        do {
            let response: PostgrestResponse<[EnrolledCourseResponse]> = try await supabase
                .from("user_courses")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("course_id", value: course.id.uuidString)
                .execute()
            
            isEnrolled = !response.value.isEmpty
        } catch {
            print("Error checking enrollment status: \(error)")
            self.error = error
        }
    }
    
    func fetchEnrolledCount() async {
        do {
            let response: PostgrestResponse<[EnrolledCourseResponse]> = try await supabase
                .from("user_courses")
                .select()
                .eq("course_id", value: course.id.uuidString)
                .execute()
            
            enrolledCount = response.value.count
        } catch {
            print("Error fetching enrolled count: \(error)")
            self.error = error
        }
    }
    
    func enroll() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let enrollment = EnrolledCourseResponse(
                courseId: course.id,
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
            
            isEnrolled = true
            enrolledCount += 1
        } catch {
            print("Error enrolling in course: \(error)")
            self.error = error
        }
    }
    
    func isCompleted(section: Int) -> Bool {
        // TODO: Implement section completion tracking
        return false
    }
    
    func fetchLessons() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: PostgrestResponse<[Lesson]> = try await supabase
                .from("lessons")
                .select("""
                    id,
                    course_id,
                    title,
                    description,
                    content,
                    duration,
                    order,
                    status,
                    created_at,
                    updated_at
                """)
                .eq("course_id", value: course.id.uuidString)
                .order("order")
                .execute()
            
            course.lessons = response.value
            objectWillChange.send()
        } catch {
            print("Error fetching lessons: \(error)")
            self.error = error
        }
    }
    
    func updateLessonStatus(lessonId: UUID, status: LessonStatus) async {
        do {
            try await supabase
                .from("lessons")
                .update([
                    "status": status.rawValue
                ])
                .eq("id", value: lessonId.uuidString)
                .execute()
            
            // Update local state
            if let index = course.lessons?.firstIndex(where: { $0.id == lessonId }) {
                course.lessons?[index].status = status
                objectWillChange.send()
            }
        } catch {
            print("Error updating lesson status: \(error)")
            self.error = error
        }
    }
    
    // Helper function to format errors for display
    func formattedError() -> String? {
        guard let error = error else { return nil }
        if let postgrestError = error as? PostgrestError {
            return "Database error: \(postgrestError.message)"
        }
        return error.localizedDescription
    }
}
