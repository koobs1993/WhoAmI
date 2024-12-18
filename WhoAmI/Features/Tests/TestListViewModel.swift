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
        print("TestListViewModel initialized")
    }
    
    func fetchTests() async {
        isLoading = true
        error = nil
        
        do {
            print("Fetching tests...")
            let response: PostgrestResponse<[PsychTest]> = try await supabase.database
                .from("psychtests")
                .select("""
                    id,
                    title,
                    short_description,
                    category,
                    image_url,
                    duration_minutes,
                    is_active,
                    created_at,
                    updated_at,
                    testprogress (
                        status,
                        last_updated,
                        score
                    ),
                    questions (
                        id,
                        uuid,
                        text,
                        type,
                        required,
                        options
                    ),
                    benefits (
                        id,
                        title,
                        description
                    )
                """)
                .eq("is_active", value: true)
                .order("created_at", ascending: false)
                .execute()
            
            tests = response.value
            print("Fetched \(tests.count) tests")
            
            if tests.isEmpty {
                print("No tests found in the database")
            } else {
                tests.forEach { test in
                    print("Test: \(test.title)")
                    print("Questions: \(test.questions.count)")
                    if let progress = test.userProgress {
                        print("Progress status: \(progress.status)")
                    }
                }
            }
        } catch {
            print("Error fetching tests: \(error)")
            print("Error details: \(String(describing: error))")
            self.error = error
        }
        
        isLoading = false
    }
    
    func retryFetch() async {
        await fetchTests()
    }
}
