import SwiftUI
import Supabase

@MainActor
class DashboardViewModel: ObservableObject {
    let supabase: SupabaseClient
    let userId: UUID
    @Published var overallProgress: Double = 0.0
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
    }
    
    func fetchProgress() async {
        do {
            // Fetch enrolled courses
            let response: PostgrestResponse<[EnrolledCourseResponse]> = try await supabase
                .from("user_courses")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
            
            let enrolledCourses = response.value
            
            // Calculate overall progress
            if !enrolledCourses.isEmpty {
                let completedCourses = enrolledCourses.filter { $0.completedAt != nil }
                overallProgress = Double(completedCourses.count) / Double(enrolledCourses.count)
            }
        } catch {
            print("Error fetching progress: \(error)")
        }
    }
}
