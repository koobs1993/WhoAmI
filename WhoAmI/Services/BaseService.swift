import Foundation
import Supabase

// MARK: - Cache Entry
class CacheEntry<T> {
    let value: T
    let timestamp: Date
    let duration: TimeInterval
    
    init(value: T, timestamp: Date = Date(), duration: TimeInterval = 300) {
        self.value = value
        self.timestamp = timestamp
        self.duration = duration
    }
    
    var isExpired: Bool {
        return Date().timeIntervalSince(timestamp) > duration
    }
}

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
    let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    // MARK: - Error Handling
    
    func handleError(_ error: Error) -> Error {
        // Add custom error handling logic here
        return error
    }
    
    // MARK: - User Validation
    
    func validateUser() async throws -> UUID {
        let session = try await supabase.auth.session
        return session.user.id
    }
    
    // MARK: - Database Operations
    
    func select<T: Decodable>(from table: String) async throws -> PostgrestResponse<[T]> {
        return try await supabase.database
            .from(table)
            .select()
            .execute()
    }
    
    func selectSingle<T: Decodable>(from table: String) async throws -> T? {
        let response: PostgrestResponse<[T]> = try await supabase.database
            .from(table)
            .select()
            .limit(count: 1)
            .execute()
        
        return try response.value.first
    }
    
    func insert<T: Encodable & Sendable>(table: String, values: T) async throws {
        try await supabase.database
            .from(table)
            .insert(values: values)
            .execute()
    }
    
    func update<T: Encodable>(table: String, values: T, matches: [String: URLQueryRepresentable]) async throws {
        try await supabase.database
            .from(table)
            .update(values: values)
            .match(query: matches)
            .execute()
    }
    
    func upsert<T: Encodable>(table: String, values: T) async throws {
        try await supabase.database
            .from(table)
            .upsert(values: values)
            .execute()
    }
    
    func delete(from table: String, matches: [String: URLQueryRepresentable]) async throws {
        try await supabase.database
            .from(table)
            .delete()
            .match(query: matches)
            .execute()
    }
    
    // MARK: - Cache Management
    
    func setupCache<T>(_ cache: NSCache<NSString, CacheEntry<T>>) {
        cache.countLimit = 100 // Maximum number of cached items
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB limit
    }
    
    func clearCache<T>(_ cache: NSCache<NSString, CacheEntry<T>>) {
        cache.removeAllObjects()
    }
    
    func getCachedValue<T: Decodable>(from cache: NSCache<NSString, CacheEntry<T>>, forKey key: String) -> T? {
        let cacheKey = key as NSString
        if let cached = cache.object(forKey: cacheKey), !cached.isExpired {
            return cached.value
        }
        return nil
    }
    
    func setCachedValue<T>(_ value: T, in cache: NSCache<NSString, CacheEntry<T>>, forKey key: String, duration: TimeInterval = 300) {
        let cacheKey = key as NSString
        cache.setObject(CacheEntry(value: value, duration: duration), forKey: cacheKey)
    }
} 