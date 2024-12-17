import Foundation
import Supabase
import StoreKit
import SwiftUI
import AppKit

@MainActor
class ReviewPromptManager: BaseService, ObservableObject {
    @Published var shouldShowPrompt = false
    
    private let userDefaults = UserDefaults.standard
    private let minimumActionsBeforePrompt = 3
    private let daysBeforeReprompt = 60
    private let cache = NSCache<NSString, CacheEntry<[ReviewHistory]>>()
    private let cacheDuration: TimeInterval = 3600 // 1 hour
    
    private enum UserDefaultsKeys {
        static let lastReviewPromptDate = "lastReviewPromptDate"
        static let hasSubmittedReview = "hasSubmittedReview"
        static let actionCount = "userActionCount"
    }
    
    override init(supabase: SupabaseClient = Config.supabaseClient) {
        super.init(supabase: supabase)
        setupCache(cache)
    }
    
    func incrementActionCount() {
        let currentCount = userDefaults.integer(forKey: UserDefaultsKeys.actionCount)
        userDefaults.set(currentCount + 1, forKey: UserDefaultsKeys.actionCount)
        checkIfShouldPrompt()
    }
    
    private func checkIfShouldPrompt() {
        // Don't show if user has already reviewed
        guard !userDefaults.bool(forKey: UserDefaultsKeys.hasSubmittedReview) else { return }
        
        let actionCount = userDefaults.integer(forKey: UserDefaultsKeys.actionCount)
        guard actionCount >= minimumActionsBeforePrompt else { return }
        
        if let lastPromptDate = userDefaults.object(forKey: UserDefaultsKeys.lastReviewPromptDate) as? Date {
            let daysSinceLastPrompt = Calendar.current.dateComponents([.day], from: lastPromptDate, to: Date()).day ?? 0
            shouldShowPrompt = daysSinceLastPrompt >= daysBeforeReprompt
        } else {
            shouldShowPrompt = true
        }
    }
    
    func recordReviewSubmission() async throws {
        guard let userId = supabase.auth.session?.user.id else {
            throw AuthError.notAuthenticated
        }
        
        let updateData: [String: Any] = [
            "last_review_date": Date(),
            "review_count": reviewCount + 1
        ]
        
        try await supabase
            .from("user_profiles")
            .update(updateData)
            .eq("user_id", value: userId)
            .execute()
        
        reviewCount += 1
    }
    
    func fetchReviewHistory() async throws -> [ReviewHistory] {
        if let history = getCachedValue(from: cache, forKey: "review_history", duration: cacheDuration) {
            return history
        }
        
        do {
            let query = select(from: "review_history")
                .order("reviewed_at", ascending: false)
            
            let result = try await query.execute()
            let history: [ReviewHistory] = try result.value
            
            setCachedValue(history, in: cache, forKey: "review_history")
            return history
        } catch {
            throw handleError(error)
        }
    }
    
    // MARK: - Helper Methods
    
    func requestReview() {
        Task {
            do {
                try await recordReviewSubmission()
            } catch {
                print("Failed to record review submission: \(error.localizedDescription)")
            }
        }
    }
    
    // Helper method to reset review status (for testing)
    func resetReviewStatus() {
        userDefaults.removeObject(forKey: UserDefaultsKeys.lastReviewPromptDate)
        userDefaults.removeObject(forKey: UserDefaultsKeys.hasSubmittedReview)
        userDefaults.removeObject(forKey: UserDefaultsKeys.actionCount)
        invalidateCache()
    }
    
    // MARK: - Cache Management
    
    private func invalidateCache() {
        cache.removeObject(forKey: "review_history" as NSString)
    }
}

// MARK: - Models

struct ReviewHistory: Codable, Identifiable {
    let id: Int
    let userId: UUID
    let reviewedAt: Date
    let platform: String
    let appVersion: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "review_id"
        case userId = "user_id"
        case reviewedAt = "reviewed_at"
        case platform
        case appVersion = "app_version"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 