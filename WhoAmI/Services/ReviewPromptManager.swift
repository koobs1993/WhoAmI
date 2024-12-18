import Foundation
import Supabase

@MainActor
class ReviewPromptManager: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?
    
    private let supabase: SupabaseClient
    private var userId: UUID
    private let cache: GenericCache
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
        // Initialize with a temporary UUID, will be updated when session is available
        self.userId = UUID()
        self.cache = GenericCache()
        
        // Update userId in the background
        Task {
            do {
                let session = try await supabase.auth.session
                self.userId = session.user.id
            } catch {
                print("Error getting user session: \(error)")
            }
        }
    }
    
    func submitReview(rating: Int, feedback: String?) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let data: [String: String] = [
            "user_id": userId.uuidString,
            "rating": String(rating),
            "feedback": feedback ?? "",
            "platform": "iOS",
            "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "created_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        try await supabase.database
            .from("app_reviews")
            .insert(data)
            .execute()
        
        // Cache the review submission to prevent repeated prompts
        cache.set(Date(), forKey: "last_review_date")
    }
    
    func shouldShowPrompt() -> Bool {
        // Check if user has reviewed recently
        if let lastReviewDate: Date = cache.get(Date.self, forKey: "last_review_date") {
            let daysSinceLastReview = Calendar.current.dateComponents([.day], from: lastReviewDate, to: Date()).day ?? 0
            if daysSinceLastReview < 90 { // Don't show prompt for 90 days after last review
                return false
            }
        }
        
        // Check if user has completed enough actions
        if let actionCount: Int = cache.get(Int.self, forKey: "user_action_count") {
            return actionCount >= 5 // Show prompt after 5 meaningful actions
        }
        
        return false
    }
    
    func recordAction() {
        let currentCount: Int = cache.get(Int.self, forKey: "user_action_count") ?? 0
        cache.set(currentCount + 1, forKey: "user_action_count")
    }
    
    func resetActionCount() {
        cache.set(0, forKey: "user_action_count")
    }
}
