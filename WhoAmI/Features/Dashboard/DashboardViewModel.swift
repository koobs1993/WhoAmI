import SwiftUI
import Supabase

@MainActor
class DashboardViewModel: ObservableObject {
    private let supabase: SupabaseClient
    
    @Published var weeklyColumns: [WeeklyColumn] = []
    @Published var ongoingCourses: [Course] = []
    @Published var error: Error?
    @Published var isLoading = false
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func fetchData() async {
        isLoading = true
        error = nil
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchWeeklyColumns() }
            group.addTask { await self.fetchOngoingCourses() }
        }
        
        isLoading = false
    }
    
    private func fetchWeeklyColumns() async {
        do {
            print("Fetching latest weekly column")
            let response: PostgrestResponse<[WeeklyColumn]> = try await supabase.database
                .from("weekly_columns")
                .select()
                .order("created_at", ascending: false)
                .limit(5)
                .execute()
            
            self.weeklyColumns = response.value
            print("Fetched \(weeklyColumns.count) weekly columns")
        } catch {
            print("Error fetching weekly columns: \(error)")
            self.error = error
        }
    }
    
    private func fetchOngoingCourses() async {
        do {
            print("Fetching ongoing courses")
            let response: PostgrestResponse<[Course]> = try await supabase.database
                .from("user_courses")
                .select("""
                    courses (
                        id,
                        title,
                        description,
                        image_url,
                        estimated_duration,
                        created_at,
                        updated_at,
                        lessons (
                            id,
                            title,
                            description,
                            duration,
                            order,
                            status
                        )
                    )
                """)
                .limit(10)
                .execute()
            
            self.ongoingCourses = response.value
            print("Fetched \(ongoingCourses.count) ongoing courses")
        } catch {
            print("Error fetching ongoing courses: \(error)")
            self.error = error
        }
    }
    
    func retryFetch() async {
        await fetchData()
    }
}
