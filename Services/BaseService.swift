class CacheEntry<T> {
    let value: T
    let timestamp: Date
    
    init(value: T) {
        self.value = value
        self.timestamp = Date()
    }
    
    func isExpired(duration: TimeInterval) -> Bool {
        return Date().timeIntervalSince(timestamp) > duration
    }
} 