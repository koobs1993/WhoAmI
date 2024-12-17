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
    
    func fetchTests() async {
        isLoading = true
        error = nil
        
        do {
            let response = try await supabase.database
                .from("tests")
                .select()
                .order("created_at", ascending: false)
                .execute()
            
            tests = try response.decode([PsychTest].self)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
} 