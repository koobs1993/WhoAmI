import Foundation

public protocol CacheProtocol {
    func get<T: Codable>(_ type: T.Type, forKey key: String) -> T?
    func set<T: Codable>(_ value: T, forKey key: String)
    func remove(forKey key: String)
    func clear()
}

extension BaseService {
    func setupCache(_ cache: CacheProtocol) {
        self.cache = cache
    }
    
    func setCachedValue<T: Codable>(_ value: T, in cache: CacheProtocol, forKey key: String) {
        cache.set(value, forKey: key)
    }
    
    func getCachedValue<T: Codable>(_ type: T.Type, from cache: CacheProtocol, forKey key: String) -> T? {
        return cache.get(type, forKey: key)
    }
}
