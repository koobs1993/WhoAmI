import Foundation
import Supabase

struct UserLessonRequest: Codable {
    let userId: String
    let lessonId: Int
    let courseId: Int
    let status: String
    let progress: Double
    let completedAt: String?
    let updatedAt: String
    
    init(userId: UUID, lessonId: Int, courseId: Int, status: LessonStatus, progress: Double, completedAt: Date?) {
        self.userId = userId.uuidString
        self.lessonId = lessonId
        self.courseId = courseId
        self.status = status.rawValue
        self.progress = progress
        self.completedAt = completedAt.map { ISO8601DateFormatter().string(from: $0) }
        self.updatedAt = ISO8601DateFormatter().string(from: Date())
    }
    
    var dictionary: [String: String] {
        var dict = [
            "user_id": userId,
            "lesson_id": String(lessonId),
            "course_id": String(courseId),
            "status": status,
            "progress": String(progress),
            "updated_at": updatedAt
        ]
        if let completedAt = completedAt {
            dict["completed_at"] = completedAt
        }
        return dict
    }
}

struct UserResponseRequest: Codable {
    let userId: String
    let lessonId: Int
    let courseId: Int
    let questionId: Int
    let response: String
    let isCorrect: Bool
    let points: Int
    let createdAt: String
    
    init(userId: UUID, lessonId: Int, courseId: Int, questionId: Int, response: String, isCorrect: Bool, points: Int) {
        self.userId = userId.uuidString
        self.lessonId = lessonId
        self.courseId = courseId
        self.questionId = questionId
        self.response = response
        self.isCorrect = isCorrect
        self.points = points
        self.createdAt = ISO8601DateFormatter().string(from: Date())
    }
    
    var dictionary: [String: String] {
        [
            "user_id": userId,
            "lesson_id": String(lessonId),
            "course_id": String(courseId),
            "question_id": String(questionId),
            "response": response,
            "is_correct": String(isCorrect),
            "points": String(points),
            "created_at": createdAt
        ]
    }
}

@MainActor
class CourseService: BaseService {
    private let userId: UUID
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.userId = userId
        super.init(supabase: supabase)
        setupCache(GenericCache())
    }
    
    func fetchCourses() async throws -> [Course] {
        if let cached: [Course] = getCachedValue([Course].self, forKey: "courses") {
            return cached
        }
        
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
        
        let courses = response.value
        setCachedValue(courses, forKey: "courses")
        return courses
    }
    
    func fetchCourse(id: Int) async throws -> Course? {
        if let cached: Course = getCachedValue(Course.self, forKey: "course_\(id)") {
            return cached
        }
        
        let response: PostgrestResponse<Course> = try await supabase.database
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
            .eq("id", value: id)
            .single()
            .execute()
        
        let course = response.value
        setCachedValue(course, forKey: "course_\(id)")
        return course
    }
    
    func saveUserLesson(_ request: UserLessonRequest) async throws {
        try await supabase.database
            .from("user_lessons")
            .insert(request.dictionary)
            .execute()
        
        // Invalidate related caches
        removeCachedValue(forKey: "course_\(request.courseId)")
        removeCachedValue(forKey: "courses")
    }
    
    func updateUserLesson(userLessonId: Int, request: UserLessonRequest) async throws {
        try await supabase.database
            .from("user_lessons")
            .update(request.dictionary)
            .eq("id", value: userLessonId)
            .execute()
        
        // Invalidate related caches
        removeCachedValue(forKey: "course_\(request.courseId)")
        removeCachedValue(forKey: "courses")
    }
    
    func saveUserResponse(_ request: UserResponseRequest) async throws {
        try await supabase.database
            .from("user_responses")
            .insert(request.dictionary)
            .execute()
    }
}
