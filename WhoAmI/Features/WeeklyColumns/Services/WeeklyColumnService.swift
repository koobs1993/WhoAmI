import Foundation
import Supabase

protocol WeeklyColumnServiceProtocol {
    func fetchColumns() async throws -> [WeeklyColumn]
    func fetchQuestions(for columnId: Int) async throws -> [WeeklyQuestion]
    func saveResponse(userId: UUID, questionId: Int, response: String) async throws
    func saveProgress(userId: UUID, columnId: Int, lastQuestionId: Int, completed: Bool) async throws
    func fetchProgress(userId: UUID) async throws -> [UserWeeklyProgress]
}

class WeeklyColumnService: WeeklyColumnServiceProtocol {
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func fetchColumns() async throws -> [WeeklyColumn] {
        let query = supabase.database
            .from("weeklycolumns")
            .select(columns: "*")
            .order(column: "publish_date", ascending: false)
        
        let response: PostgrestResponse<[WeeklyColumn]> = try await query.execute()
        return response.value
    }
    
    func fetchQuestions(for columnId: Int) async throws -> [WeeklyQuestion] {
        let query = supabase.database
            .from("weeklyquestions")
            .select(columns: "*")
            .eq(column: "column_id", value: columnId)
            .order(column: "sequence_order", ascending: true)
        
        let response: PostgrestResponse<[WeeklyQuestion]> = try await query.execute()
        return response.value
    }
    
    func saveResponse(userId: UUID, questionId: Int, response: String) async throws {
        let values: [String: String] = [
            "user_id": userId.uuidString,
            "question_id": String(questionId),
            "response": response,
            "created_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        try await supabase.database
            .from("weeklyresponses")
            .insert(values: values)
            .execute()
    }
    
    func saveProgress(userId: UUID, columnId: Int, lastQuestionId: Int, completed: Bool) async throws {
        try await updateProgress(userId: userId, columnId: columnId, completed: completed, completedAt: completed ? Date() : nil)
    }
    
    func fetchProgress(userId: UUID) async throws -> [UserWeeklyProgress] {
        let query = supabase.database
            .from("userweeklyprogress")
            .select(columns: "*")
            .eq(column: "user_id", value: userId.uuidString)
        
        let response: PostgrestResponse<[UserWeeklyProgress]> = try await query.execute()
        return response.value
    }
    
    func updateProgress(userId: UUID, columnId: Int, completed: Bool, completedAt: Date? = nil, score: Int? = nil) async throws {
        let values: [String: String] = [
            "user_id": userId.uuidString,
            "column_id": String(columnId),
            "is_completed": String(completed),
            "completed_at": completedAt.map { ISO8601DateFormatter().string(from: $0) } ?? "",
            "score": score.map(String.init) ?? "",
            "is_active": "true",
            "created_at": ISO8601DateFormatter().string(from: Date()),
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        try await supabase.database
            .from("userweeklyprogress")
            .upsert(values: values)
            .execute()
    }
} 