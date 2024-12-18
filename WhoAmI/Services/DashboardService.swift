import Foundation
import Supabase

struct DashboardItemRequest: Codable {
    let title: String
    let description: String
    let type: String
    let status: String
    let metadata: String
    let updatedAt: String
    
    init(from item: DashboardItem) {
        self.title = item.title
        self.description = item.description
        self.type = item.type.rawValue
        self.status = item.status.rawValue
        self.metadata = item.metadata.flatMap { metadata in
            if let data = try? JSONEncoder().encode(metadata) {
                return String(data: data, encoding: .utf8) ?? "{}"
            }
            return "{}"
        } ?? "{}"
        self.updatedAt = ISO8601DateFormatter().string(from: Date())
    }
    
    var dictionary: [String: String] {
        [
            "title": title,
            "description": description,
            "type": type,
            "status": status,
            "metadata": metadata,
            "updated_at": updatedAt
        ]
    }
}

@MainActor
class DashboardService {
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func fetchItems() async throws -> [DashboardItem] {
        let response: PostgrestResponse<[DashboardItem]> = try await supabase.database
            .from("dashboard_items")
            .select()
            .order("created_at")
            .execute()
        
        return response.value
    }
    
    func createItem(_ item: DashboardItem) async throws {
        let request = DashboardItemRequest(from: item)
        
        try await supabase.database
            .from("dashboard_items")
            .insert(request.dictionary)
            .execute()
    }
    
    func updateItem(_ item: DashboardItem) async throws {
        let request = DashboardItemRequest(from: item)
        
        try await supabase.database
            .from("dashboard_items")
            .update(request.dictionary)
            .eq("id", value: item.id.uuidString)
            .execute()
    }
    
    func deleteItem(_ itemId: UUID) async throws {
        try await supabase.database
            .from("dashboard_items")
            .delete()
            .eq("id", value: itemId.uuidString)
            .execute()
    }
}
