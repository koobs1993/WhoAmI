import Foundation
import Supabase
import SwiftUI

@MainActor
class TestViewModel: ObservableObject {
    @Published var tests: [PsychTest] = []
    @Published var filteredTests: [PsychTest] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedCategory: TestCategory?
    @Published var searchText = ""
    @Published var isComplete = false
    @Published var responses: [Int: String] = [:]
    
    private let supabase: SupabaseClient
    private let userId: UUID
    private let testId: UUID
    private let cache = NSCache<NSString, CacheEntry<[PsychTest]>>()
    private let cacheDuration: TimeInterval = 300 // 5 minutes
    
    init(supabase: SupabaseClient, userId: UUID, testId: UUID) {
        self.supabase = supabase
        self.userId = userId
        self.testId = testId
        setupCache()
    }
    
    private func setupCache() {
        cache.countLimit = 50
        cache.totalCostLimit = 10 * 1024 * 1024 // 10MB
    }
    
    func fetchTests() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let response: PostgrestResponse<[PsychTest]> = try await supabase.database
            .from("tests")
            .select()
            .eq("is_active", value: true)
            .execute()
        
        tests = response.value
    }
    
    func updateFilteredTests() {
        var filtered = tests
        
        // Apply category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category.rawValue == category.rawValue }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.shortDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort by status and date
        filtered.sort { test1, test2 in
            if let progress1 = test1.userProgress, let progress2 = test2.userProgress {
                if progress1.status == progress2.status {
                    return progress1.lastUpdated > progress2.lastUpdated
                }
                return progress1.status.rawValue < progress2.status.rawValue
            }
            return test1.createdAt > test2.createdAt
        }
        
        self.filteredTests = filtered
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    deinit {
        // If test is in progress and not complete, try to abandon it
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            if !self.isComplete && !self.responses.isEmpty {
                try? await self.abandonTest()
            }
        }
    }
    
    func abandonTest() async throws {
        // Mark test as abandoned in database
        let values: [String: String] = [
            "status": TestStatus.abandoned.rawValue,
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        try await supabase.database
            .from("usertests")
            .update(values)
            .match([
                "user_id": userId.uuidString,
                "test_id": testId.uuidString,
                "status": TestStatus.inProgress.rawValue
            ])
            .execute()
    }
}

// MARK: - Error Types
enum TestError: LocalizedError {
    case invalidResponse
    case networkError(Error)
    case databaseError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .databaseError(let error):
            return "Database error: \(error.localizedDescription)"
        }
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
}
