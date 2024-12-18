import Foundation
import Supabase

@MainActor
class DashboardService: BaseService, ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?
    @Published var weeklyColumns: [WeeklyColumn] = []
    @Published var dashboardItems: [DashboardItem] = []
    
    private let userId: UUID
    private let cache = NSCache<NSString, CacheEntry<[DashboardItem]>>()
    private let cacheDuration: TimeInterval = 300 // 5 minutes
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.userId = userId
        super.init(supabase: supabase)
        setupCache(cache)
    }
    
    func fetchDashboardItems() async throws -> [DashboardItem] {
        let response: PostgrestResponse<[DashboardItem]> = try await supabase.database
            .from("dashboard_items")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
        
        let items = response.value
        setCachedValue(items, in: cache, forKey: "dashboard_items")
        return items
    }
    
    func fetchWeeklyColumns() async throws -> [WeeklyColumn] {
        let response: PostgrestResponse<[WeeklyColumn]> = try await supabase.database
            .from("weekly_columns")
            .select()
            .order("publish_date", ascending: false)
            .limit(5)
            .execute()
        
        return response.value
    }
    
    func fetchRecentActivity() async throws -> [ActivityItem] {
        let response: PostgrestResponse<[ActivityItem]> = try await supabase.database
            .from("user_activity")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .limit(10)
            .execute()
        
        return response.value
    }
    
    func fetchStats() async throws -> UserStats {
        let response: PostgrestResponse<UserStats> = try await supabase.database
            .from("user_stats")
            .select()
            .eq("user_id", value: userId.uuidString)
            .single()
            .execute()
        
        return response.value
    }
    
    func fetchRecommendations() async throws -> [RecommendedItem] {
        let response: PostgrestResponse<[RecommendedItem]> = try await supabase.database
            .from("recommendations")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("is_active", value: true)
            .order("priority", ascending: false)
            .limit(10)
            .execute()
        
        return response.value
    }
    
    private func invalidateCache() {
        cache.removeObject(forKey: "dashboard_items" as NSString)
    }
}

// MARK: - Supporting Models
struct DashboardItem: Codable, Identifiable {
    let id: Int
    let userId: UUID
    let type: DashboardItemType
    let title: String
    let description: String?
    let imageUrl: String?
    let priority: Int
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "item_id"
        case userId = "user_id"
        case type = "item_type"
        case title
        case description
        case imageUrl = "image_url"
        case priority
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum DashboardItemType: String, Codable {
    case course
    case test
    case weeklyColumn = "weekly_column"
    case notification
}

struct ActivityItem: Codable, Identifiable {
    let id: Int
    let userId: UUID
    let activityType: String
    let description: String
    let metadata: [String: String]?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "activity_id"
        case userId = "user_id"
        case activityType = "activity_type"
        case description
        case metadata
        case createdAt = "created_at"
    }
}

struct RecommendedItem: Codable, Identifiable {
    let id: Int
    let userId: UUID
    let itemType: String
    let itemId: Int
    let reason: String
    let priority: Int
    let isActive: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "recommendation_id"
        case userId = "user_id"
        case itemType = "item_type"
        case itemId = "item_id"
        case reason
        case priority
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}
