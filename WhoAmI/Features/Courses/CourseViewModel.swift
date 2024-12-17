import Foundation
import Supabase

@MainActor
class CourseViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var currentCourse: Course?
    @Published var error: Error?
    @Published var isLoading = false
    
    private let courseService: CourseService
    private let userId: UUID
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.courseService = CourseService(supabase: supabase)
        self.userId = userId
    }
    
    func fetchCourses() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            self.courses = try await courseService.fetchCourses()
        } catch {
            self.error = error
        }
    }
    
    func fetchCourseDetails(_ courseId: Int) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            self.currentCourse = try await courseService.fetchCourseDetails(courseId)
        } catch {
            self.error = error
        }
    }
    
    func startUserLesson(userCourseId: UUID, lessonId: UUID) async {
        do {
            let userCourseIdInt = Int(userCourseId.uuidString) ?? 0
            let lessonIdInt = Int(lessonId.uuidString) ?? 0
            try await courseService.startUserLesson(userCourseId: userCourseIdInt, lessonId: lessonIdInt)
            if let courseId = currentCourse?.id {
                await fetchCourseDetails(Int(courseId.uuidString) ?? 0)
            }
        } catch {
            self.error = error
        }
    }
    
    func completeUserLesson(userCourseId: UUID, lessonId: UUID) async {
        do {
            let userCourseIdInt = Int(userCourseId.uuidString) ?? 0
            let lessonIdInt = Int(lessonId.uuidString) ?? 0
            try await courseService.completeUserLesson(userCourseId: userCourseIdInt, lessonId: lessonIdInt)
            if let courseId = currentCourse?.id {
                await fetchCourseDetails(Int(courseId.uuidString) ?? 0)
            }
        } catch {
            self.error = error
        }
    }
    
    func saveLessonResponse(userLessonId: UUID, questionId: UUID, response: String) async {
        do {
            let userLessonIdInt = Int(userLessonId.uuidString) ?? 0
            let questionIdInt = Int(questionId.uuidString) ?? 0
            try await courseService.saveLessonResponse(userLessonId: userLessonIdInt, questionId: questionIdInt, response: response)
        } catch {
            self.error = error
        }
    }
    
    func calculateProgress(for course: Course) -> Double {
        guard let lessons = course.lessons else { return 0.0 }
        let completedCount = lessons.filter { $0.status == LessonStatus.completed }.count
        return Double(completedCount) / Double(lessons.count)
    }
} 