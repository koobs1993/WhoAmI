import Foundation

struct ReviewHistory: Codable {
    let timestamp: Date
    let action: String
}

@MainActor
class ReviewManager: ObservableObject {
    @Published private(set) var hasShownPrompt = false
    @Published private(set) var lastPromptDate: Date?
    
    private let minimumActionsBeforePrompt = 3
    private let daysBeforeReprompt = 60
    private let cache: GenericCache
    private let cacheDuration: TimeInterval = 3600 // 1 hour
    private var reviewCount: Int = 0
    
    init() {
        self.cache = GenericCache()
        loadHistory()
    }
    
    func recordAction(_ action: String) {
        reviewCount += 1
        
        let history = ReviewHistory(timestamp: Date(), action: action)
        var histories = getHistory()
        histories.append(history)
        
        cache.set(histories, forKey: "review_history")
        
        checkIfShouldPrompt()
    }
    
    func markPromptShown() {
        hasShownPrompt = true
        lastPromptDate = Date()
        cache.set(lastPromptDate, forKey: "last_prompt_date")
    }
    
    private func checkIfShouldPrompt() {
        guard !hasShownPrompt else { return }
        
        if let lastDate = lastPromptDate {
            let daysSinceLastPrompt = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            guard daysSinceLastPrompt >= daysBeforeReprompt else { return }
        }
        
        if reviewCount >= minimumActionsBeforePrompt {
            hasShownPrompt = true
        }
    }
    
    private func getHistory() -> [ReviewHistory] {
        return cache.get([ReviewHistory].self, forKey: "review_history") ?? []
    }
    
    private func loadHistory() {
        lastPromptDate = cache.get(Date.self, forKey: "last_prompt_date")
        hasShownPrompt = lastPromptDate != nil
        reviewCount = getHistory().count
    }
}
