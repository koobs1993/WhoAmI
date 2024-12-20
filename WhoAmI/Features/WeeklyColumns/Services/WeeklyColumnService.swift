import Foundation
import Supabase

protocol WeeklyColumnServiceProtocol {
    func fetchColumns() async throws -> [WeeklyColumn]
    func fetchQuestions(columnId: UUID) async throws -> [WeeklyQuestion]
    func fetchProgress(userId: UUID) async throws -> [UserWeeklyProgress]
    func submitResponse(_ response: WeeklyResponse) async throws
    func saveProgress(userId: UUID, columnId: UUID, lastQuestionId: UUID, completed: Bool) async throws
}

class WeeklyColumnService: WeeklyColumnServiceProtocol {
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func fetchColumns() async throws -> [WeeklyColumn] {
        let response: PostgrestResponse<[WeeklyColumn]> = try await supabase
            .from("weekly_columns")
            .select()
            .order("created_at", ascending: false)
            .execute()
        
        return response.value
    }
    
    func fetchQuestions(columnId: UUID) async throws -> [WeeklyQuestion] {
        let response: PostgrestResponse<[WeeklyQuestion]> = try await supabase
            .from("weekly_questions")
            .select()
            .eq("column_id", value: columnId.uuidString)
            .order("order_num")
            .execute()
        
        return response.value
    }
    
    func fetchProgress(userId: UUID) async throws -> [UserWeeklyProgress] {
        let response: PostgrestResponse<[UserWeeklyProgress]> = try await supabase
            .from("user_weekly_progress")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
        
        return response.value
    }
    
    func submitResponse(_ response: WeeklyResponse) async throws {
        let _: PostgrestResponse<WeeklyResponse> = try await supabase
            .from("weekly_responses")
            .insert(response)
            .execute()
    }
    
    func saveProgress(userId: UUID, columnId: UUID, lastQuestionId: UUID, completed: Bool) async throws {
        let progress = UserWeeklyProgress(
            userId: userId,
            columnId: columnId,
            lastQuestionId: lastQuestionId,
            completed: completed
        )
        
        let _: PostgrestResponse<UserWeeklyProgress> = try await supabase
            .from("user_weekly_progress")
            .upsert(progress)
            .execute()
    }
}
