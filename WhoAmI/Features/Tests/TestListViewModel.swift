import Foundation
import Supabase

@MainActor
class TestListViewModel: ObservableObject {
    @Published var tests: [PsychTest] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func fetchTests() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let response: PostgrestResponse<[PsychTest]> = try await supabase.database
            .from("tests")
            .select()
            .order(column: "created_at", ascending: false)
            .execute()
        
        tests = try response.value
    }
} 