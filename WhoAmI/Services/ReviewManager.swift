import Foundation
import StoreKit
import Supabase
#if os(iOS)
import UIKit
#endif

struct ReviewHistory: Codable, Sendable {
    let id: UUID
    let userId: UUID
    let reviewedAt: Date
    let appVersion: String
    let osVersion: String
    let deviceModel: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case reviewedAt = "reviewed_at"
        case appVersion = "app_version"
        case osVersion = "os_version"
        case deviceModel = "device_model"
    }
}

@MainActor
class ReviewPromptManager: ObservableObject, @unchecked Sendable {
    static let shared = ReviewPromptManager(supabase: Config.supabaseClient)
    
    private let supabase: SupabaseClient
    private let minimumActionsBeforePrompt = 3
    private let daysBeforeReprompt = 60
    private let cache = NSCache<NSString, CacheEntry<[ReviewHistory]>>()
    private let cacheDuration: TimeInterval = 3600 // 1 hour
    private var reviewCount: Int = 0
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
        setupCache()
    }
    
    private func setupCache() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    func incrementCount() {
        reviewCount += 1
        checkAndPromptForReview()
    }
    
    private func checkAndPromptForReview() {
        guard reviewCount >= minimumActionsBeforePrompt else { return }
        
        Task {
            do {
                let history = try await fetchReviewHistory()
                let lastReview = history.last
                
                let calendar = Calendar.current
                if let lastReviewDate = lastReview?.reviewedAt {
                    let daysSinceLastReview = calendar.dateComponents([.day], from: lastReviewDate, to: Date()).day ?? 0
                    guard daysSinceLastReview >= daysBeforeReprompt else { return }
                }
                
                await requestReview()
                try await saveReviewHistory()
                reviewCount = 0
            } catch {
                print("Failed to check review history:", error)
            }
        }
    }
    
    func fetchReviewHistory() async throws -> [ReviewHistory] {
        if let cached = cache.object(forKey: "review_history" as NSString)?.value {
            return cached
        }
        
        let response: PostgrestResponse<[ReviewHistory]> = try await supabase.database
            .from("review_history")
            .select()
            .order("reviewed_at", ascending: false)
            .execute()
        
        cache.setObject(CacheEntry(value: response.value), forKey: "review_history" as NSString)
        return response.value
    }
    
    public func saveReviewHistory() async throws {
        guard let session = try? await supabase.auth.session else { return }
        
        let record = ReviewHistory(
            id: UUID(),
            userId: session.user.id,
            reviewedAt: Date(),
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            deviceModel: "macOS Device"
        )
        
        try await supabase.database
            .from("review_history")
            .insert(record)
            .execute()
        
        cache.removeAllObjects()
    }
    
    private func requestReview() async {
        #if os(iOS)
        guard let windowScene = await UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        await SKStoreReviewController.requestReview(in: windowScene)
        #else
        if NSApplication.shared.windows.first != nil {
            SKStoreReviewController.requestReview()
        }
        #endif
    }
} 