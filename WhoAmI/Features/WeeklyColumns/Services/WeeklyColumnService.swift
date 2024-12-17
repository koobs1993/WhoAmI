import Foundation
import Supabase

protocol WeeklyColumnServiceProtocol {
    func fetchColumns() async throws -> [WeeklyColumn]
    func fetchQuestions(for columnId: Int) async throws -> [WeeklyQuestion]
    func saveResponse(userId: UUID, questionId: Int, response: String) async throws
    func saveProgress(userId: UUID, columnId: Int, lastQuestionId: Int, completed: Bool) async throws
    func fetchResponses(userId: UUID, columnId: Int) async throws -> [Int: String]
}

class WeeklyColumnService: WeeklyColumnServiceProtocol {
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func fetchColumns() async throws -> [WeeklyColumn] {
        let query = supabase.database
            .from("weeklycolumns")
            .select(columns: """
                *,
                characterproblems:characterproblems(
                    characters(
                        *,
                        problems(*)
                    )
                ),
                userweeklyprogress(*)
            """)
            .eq(column: "is_active", value: true)
            .order(column: "sequence_number", ascending: true)
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
        let values: [String: Encodable] = [
            "user_id": userId.uuidString,
            "question_id": questionId,
            "response_text": response,
            "submitted_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        try await supabase.database
            .from("weeklyresponses")
            .upsert(values: values)
            .execute()
    }
    
    func saveProgress(userId: UUID, columnId: Int, lastQuestionId: Int, completed: Bool) async throws {
        var values: [String: Encodable] = [
            "user_id": userId.uuidString,
            "column_id": columnId,
            "last_question_id": lastQuestionId,
            "last_accessed": ISO8601DateFormatter().string(from: Date())
        ]
        
        if completed {
            values["completed_at"] = ISO8601DateFormatter().string(from: Date())
        }
        
        try await supabase.database
            .from("userweeklyprogress")
            .upsert(values: values)
            .execute()
    }
    
    func fetchResponses(userId: UUID, columnId: Int) async throws -> [Int: String] {
        let query = supabase.database
            .from("weeklyresponses")
            .select(columns: """
                response_text,
                question_id,
                weeklyquestions!inner(column_id)
            """)
            .eq(column: "user_id", value: userId.uuidString)
            .eq(column: "weeklyquestions.column_id", value: columnId)
        
        struct Response: Codable {
            let responseText: String
            let questionId: Int
            
            enum CodingKeys: String, CodingKey {
                case responseText = "response_text"
                case questionId = "question_id"
            }
        }
        
        let response: PostgrestResponse<[Response]> = try await query.execute()
        return Dictionary(uniqueKeysWithValues: response.value.map { ($0.questionId, $0.responseText) })
    }
} 