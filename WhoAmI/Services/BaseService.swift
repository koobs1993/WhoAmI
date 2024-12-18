import Foundation
import Supabase

public class BaseService {
    let supabase: SupabaseClient
    var cache: CacheProtocol?
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func setupCache(_ cache: CacheProtocol) {
        self.cache = cache
    }
    
    func getCachedValue<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        return cache?.get(type, forKey: key)
    }
    
    func setCachedValue<T: Codable>(_ value: T, forKey key: String) {
        cache?.set(value, forKey: key)
    }
    
    func removeCachedValue(forKey key: String) {
        cache?.remove(forKey: key)
    }
    
    func clearCache() {
        cache?.clear()
    }
    
    // Helper for database operations
    func toJsonString<T: Encodable>(_ value: T) -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(value) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func fromJsonString<T: Decodable>(_ string: String, as type: T.Type) -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let data = string.data(using: .utf8) {
            return try? decoder.decode(type, from: data)
        }
        return nil
    }
}
