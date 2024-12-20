import Foundation
import Supabase

struct DashboardItem: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let title: String
    let description: String
    let type: ItemType
    let status: ItemStatus
    let metadata: [String: String]?
    let createdAt: Date
    let updatedAt: Date
    
    enum ItemType: String, Codable {
        case course
        case test
        case achievement
        case notification
    }
    
    enum ItemStatus: String, Codable {
        case active
        case completed
        case archived
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case description
        case type
        case status
        case metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

class DashboardService {
    private let supabase: SupabaseClient
    private let userId: UUID
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
    }
    
    func fetchItems() async throws -> [DashboardItem] {
        let response: PostgrestResponse<[DashboardItem]> = try await supabase
            .from("dashboard_items")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
        
        return response.value
    }
    
    func createItem(_ item: DashboardItem) async throws {
        try await supabase
            .from("dashboard_items")
            .insert(item)
            .execute()
    }
    
    func updateItem(_ item: DashboardItem) async throws {
        try await supabase
            .from("dashboard_items")
            .update(item)
            .eq("id", value: item.id.uuidString)
            .execute()
    }
    
    func deleteItem(_ itemId: UUID) async throws {
        try await supabase
            .from("dashboard_items")
            .delete()
            .eq("id", value: itemId.uuidString)
            .execute()
    }
}
