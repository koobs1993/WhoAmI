import Foundation
import Supabase

protocol WeeklyColumnServiceProtocol {
    func fetchColumns() async throws -> [WeeklyColumn]
    func fetchQuestions(for columnId: Int) async throws -> [WeeklyQuestion]
    func submitResponse(_ values: WeeklyResponse) async throws
    func saveProgress(userId: UUID, columnId: Int, lastQuestionId: Int, completed: Bool) async throws
    func fetchProgress(userId: UUID) async throws -> [UserWeeklyProgress]
}

class WeeklyColumnService: WeeklyColumnServiceProtocol {
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func fetchColumns() async throws -> [WeeklyColumn] {
        let response: PostgrestResponse<[WeeklyColumn]> = try await supabase.database
            .from("weeklycolumns")
            .select("*")
            .order("publish_date", ascending: false)
            .execute()
            
        return response.value
    }
    
    func fetchQuestions(for columnId: Int) async throws -> [WeeklyQuestion] {
        let response: PostgrestResponse<[WeeklyQuestion]> = try await supabase.database
            .from("weeklyquestions")
            .select("*")
            .eq("column_id", value: columnId)
            .execute()
            
        return response.value
    }
    
    func submitResponse(_ values: WeeklyResponse) async throws {
        try await supabase.database
            .from("weeklyresponses")
            .insert(values)
            .execute()
    }
    
    func saveProgress(userId: UUID, columnId: Int, lastQuestionId: Int, completed: Bool) async throws {
        let values = UserWeeklyProgress(
            id: 0,
            userId: userId,
            columnId: columnId,
            lastQuestionId: lastQuestionId,
            completed: completed
        )
        
        try await updateProgress(values)
    }
    
    func fetchProgress(userId: UUID) async throws -> [UserWeeklyProgress] {
        let response: PostgrestResponse<[UserWeeklyProgress]> = try await supabase.database
            .from("userweeklyprogress")
            .select("*")
            .eq("user_id", value: userId.uuidString)
            .execute()
            
        return response.value
    }
    
    func updateProgress(_ values: UserWeeklyProgress) async throws {
        try await supabase.database
            .from("userweeklyprogress")
            .upsert(values)
            .execute()
    }
} 