import Foundation

public protocol CacheProtocol {
    func get<T: Codable>(_ type: T.Type, forKey key: String) -> T?
    func set<T: Codable>(_ value: T, forKey key: String)
    func remove(forKey key: String)
    func clear()
}

public class CacheEntry<T: Codable>: Codable {
    public let value: T
    public let timestamp: Date
    public let expiresIn: TimeInterval
    
    public var isExpired: Bool {
        return Date().timeIntervalSince(timestamp) > expiresIn
    }
    
    enum CodingKeys: String, CodingKey {
        case value
        case timestamp
        case expiresIn
    }
    
    public init(value: T, expiresIn: TimeInterval = 3600) {
        self.value = value
        self.timestamp = Date()
        self.expiresIn = expiresIn
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(T.self, forKey: .value)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        expiresIn = try container.decode(TimeInterval.self, forKey: .expiresIn)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(expiresIn, forKey: .expiresIn)
    }
}

public class GenericCache: CacheProtocol {
    private var storage = [String: Data]()
    private let lock = NSLock()
    
    public init() {}
    
    public func get<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let data = storage[key] else { return nil }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let entry = try decoder.decode(CacheEntry<T>.self, from: data)
            guard !entry.isExpired else {
                storage.removeValue(forKey: key)
                return nil
            }
            return entry.value
        } catch {
            print("Cache decoding error: \(error)")
            return nil
        }
    }
    
    public func set<T: Codable>(_ value: T, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        
        let entry = CacheEntry(value: value)
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(entry)
            storage[key] = data
        } catch {
            print("Cache encoding error: \(error)")
        }
    }
    
    public func remove(forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        storage.removeValue(forKey: key)
    }
    
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        storage.removeAll()
    }
}
