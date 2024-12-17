import Foundation
import Supabase

enum ServiceError: LocalizedError {
    case unauthorized
    case validationError(String)
    case databaseError(Error)
    case networkError(Error)
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "You are not authorized to perform this action"
        case .validationError(let message):
            return message
        case .databaseError(let error):
            return "Database error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .notFound:
            return "The requested resource was not found"
        }
    }
}

class BaseService {
    var supabase: SupabaseClient
    
    init(supabase: SupabaseClient = Config.supabaseClient) {
        self.supabase = supabase
    }
    
    // MARK: - User Validation
    
    func validateUser() async throws -> UUID {
        let session = try await supabase.auth.session
        return session.user.id
    }
    
    // MARK: - Database Operations
    
    func select<T: Decodable>(from table: String) async throws -> PostgrestFilterBuilder<T> {
        return supabase.database.from(table).select()
    }
    
    func selectOne<T: Decodable>(from table: String) async throws -> T? {
        let response: PostgrestResponse<[T]> = try await supabase.database
            .from(table)
            .select()
            .limit(1)
            .execute()
        
        return response.value.first
    }
    
    func insert<T: Encodable & Sendable>(into table: String, values: T) async throws {
        try await supabase.database
            .from(table)
            .insert(values)
            .execute()
    }
    
    func update<T: Encodable & Sendable>(table: String, set values: T, matches: [String: AnyPostgrestFilterValue]) async throws {
        try await supabase.database
            .from(table)
            .update(values)
            .match(matches)
            .execute()
    }
    
    func upsert<T: Encodable & Sendable>(into table: String, values: T) async throws {
        try await supabase.database
            .from(table)
            .upsert(values)
            .execute()
    }
    
    func delete(from table: String, matches: [String: AnyPostgrestFilterValue]) async throws {
        try await supabase.database
            .from(table)
            .delete()
            .match(matches)
            .execute()
    }
    
    // MARK: - Cache Management
    
    func setupCache<T>(_ cache: NSCache<NSString, CacheEntry<T>>) {
        cache.countLimit = 100 // Maximum number of cached items
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB limit
    }
    
    func getCachedValue<T>(from cache: NSCache<NSString, CacheEntry<T>>, forKey key: String, duration: TimeInterval) -> T? {
        guard let entry = cache.object(forKey: key as NSString) else { return nil }
        guard !entry.isExpired(duration: duration) else {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
        return entry.value
    }
    
    func setCachedValue<T>(_ value: T, in cache: NSCache<NSString, CacheEntry<T>>, forKey key: String) {
        let entry = CacheEntry(value: value)
        cache.setObject(entry, forKey: key as NSString)
    }
}

// MARK: - Cache Entry

class CacheEntry<T> {
    let value: T
    let timestamp: Date
    
    init(value: T, timestamp: Date = Date()) {
        self.value = value
        self.timestamp = timestamp
    }
    
    func isExpired(duration: TimeInterval) -> Bool {
        return Date().timeIntervalSince(timestamp) > duration
    }
} 