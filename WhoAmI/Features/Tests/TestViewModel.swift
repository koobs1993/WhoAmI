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
        
        let cacheKey = "tests_\(userId)" as NSString
        if let cached = cache.object(forKey: cacheKey), !cached.isExpired {
            self.tests = cached.value
            updateFilteredTests()
            return
        }
        
        do {
            let response = try await supabase.database
                .from("psychtests")
                .select(columns: """
                    *,
                    testbenefits (
                        id,
                        title,
                        description
                    ),
                    testquestions!left (
                        id,
                        question_id,
                        test_id,
                        question_text,
                        sequence_order,
                        question_type,
                        is_required,
                        created_at,
                        updated_at,
                        questionoptions (*)
                    )
                """)
                .eq(column: "is_active", value: true)
                .order(column: "created_at")
                .execute()
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let data = try JSONSerialization.data(withJSONObject: response.underlyingResponse.data)
            self.tests = try decoder.decode([PsychTest].self, from: data)
            
            cache.setObject(CacheEntry(value: self.tests), forKey: cacheKey)
            updateFilteredTests()
        } catch {
            self.error = error
            throw error
        }
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
                return progress1.status.sortOrder < progress2.status.sortOrder
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
            "status": "abandoned",
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        try await supabase.database
            .from("usertests")
            .update(values: values)
            .match(query: [
                "user_id": userId.uuidString,
                "test_id": testId.uuidString,
                "status": TestStatus.inProgress.rawValue
            ])
            .execute()
    }
}

enum TestError: LocalizedError {
    case noActiveTest
    case invalidQuestion
    case invalidResponse
    case noResponses
    case completionFailed(String)
    case testAlreadyInProgress
    case testNotFound
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .noActiveTest:
            return "No active test session found"
        case .invalidQuestion:
            return "Invalid question"
        case .invalidResponse:
            return "Invalid response"
        case .noResponses:
            return "No responses recorded for this test"
        case .completionFailed(let reason):
            return "Failed to complete test: \(reason)"
        case .testAlreadyInProgress:
            return "You already have this test in progress"
        case .testNotFound:
            return "Test not found"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

@MainActor
class TestSessionViewModel: ObservableObject {
    @Published var questions: [TestQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var responses: [Int: String] = [:]
    @Published var isLoading = false
    @Published var error: Error?
    @Published var testResults: [String: Any]?
    @Published var test: PsychTest
    @Published var testProgress: TestProgress?
    @Published var isComplete = false
    
    private let supabase: SupabaseClient
    private let userId: UUID
    private let testId: UUID
    
    var currentQuestion: TestQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    init(supabase: SupabaseClient, userId: UUID, test: PsychTest) {
        self.supabase = supabase
        self.userId = userId
        self.testId = test.id
        self.test = test
    }
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }
    
    func moveToNextQuestion() {
        guard currentQuestionIndex < questions.count - 1 else {
            Task {
                do {
                    try await completeTest()
                    isComplete = true
                } catch {
                    self.error = error
                }
            }
            return
        }
        currentQuestionIndex += 1
        
        // Update progress in background
        Task {
            try? await updateTestProgress()
        }
    }
    
    func startTest() async throws {
        // Check if test is already in progress
        do {
            let response = try await supabase.database
                .from("usertests")
                .select(columns: "*")
                .eq(column: "user_id", value: userId.uuidString)
                .eq(column: "test_id", value: testId.uuidString)
                .eq(column: "status", value: TestStatus.inProgress.rawValue)
                .execute()
            
            let decoder = JSONDecoder()
            let data = try JSONSerialization.data(withJSONObject: response.underlyingResponse.data)
            let tests = try decoder.decode([UserTest].self, from: data)
            
            if !tests.isEmpty {
                throw TestError.testAlreadyInProgress
            }
            
            let values: [String: String] = [
                "user_id": userId.uuidString,
                "test_id": testId.uuidString,
                "start_time": ISO8601DateFormatter().string(from: Date()),
                "status": TestStatus.inProgress.rawValue,
                "created_at": ISO8601DateFormatter().string(from: Date()),
                "updated_at": ISO8601DateFormatter().string(from: Date())
            ]
            
            try await supabase.database
                .from("usertests")
                .insert(values: values)
                .execute()
            
            try await fetchQuestions()
        } catch let error as TestError {
            throw error
        } catch {
            throw TestError.networkError(error)
        }
    }
    
    func fetchQuestions() async throws {
        isLoading = true
        error = nil
        
        do {
            let response = try await supabase.database
                .from("testquestions")
                .select(columns: """
                    *,
                    questionoptions (
                        id,
                        question_id,
                        text,
                        value,
                        order,
                        created_at,
                        updated_at
                    )
                """)
                .eq(column: "test_id", value: testId.uuidString)
                .order(column: "sequence_order", ascending: true)
                .execute()
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let data = try JSONSerialization.data(withJSONObject: response.underlyingResponse.data)
            self.questions = try decoder.decode([TestQuestion].self, from: data)
            
            if questions.isEmpty {
                throw TestError.testNotFound
            }
        } catch let error as TestError {
            self.error = error
            throw error
        } catch {
            let wrappedError = TestError.networkError(error)
            self.error = wrappedError
            throw wrappedError
        }
    }
    
    func submitResponse(_ response: String) async throws {
        guard let question = currentQuestion else {
            throw TestError.invalidQuestion
        }
        
        // Validate response based on question type
        try validateResponse(response, for: question)
        
        do {
            let userTestId = try await getCurrentUserTestId()
            
            let values: [String: String] = [
                "user_test_id": String(userTestId),
                "question_id": String(question.id),
                "response_value": response,
                "created_at": ISO8601DateFormatter().string(from: Date())
            ]
            
            try await supabase.database
                .from("userresponses")
                .insert(values: values)
                .execute()
            
            responses[question.id] = response
            
            // Update progress before moving to next question
            try await updateTestProgress()
            moveToNextQuestion()
        } catch {
            throw error is TestError ? error : TestError.networkError(error)
        }
    }
    
    private func validateResponse(_ response: String, for question: TestQuestion) throws {
        if question.isRequired && response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw TestError.invalidResponse
        }
        
        switch question.questionType {
        case .multipleChoice:
            guard let options = question.options,
                  options.contains(where: { $0.text == response }) else {
                throw TestError.invalidResponse
            }
        case .trueFalse:
            guard ["true", "false"].contains(response.lowercased()) else {
                throw TestError.invalidResponse
            }
        case .rating:
            guard let rating = Int(response), (1...5).contains(rating) else {
                throw TestError.invalidResponse
            }
        case .shortAnswer, .longAnswer:
            // Text responses are always valid if not empty
            break
        }
    }
    
    func completeTest() async throws {
        guard !responses.isEmpty else {
            throw TestError.noResponses
        }
        
        do {
            let results = calculateResults()
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let resultsJson = try encoder.encode(results)
            let resultsString = String(data: resultsJson, encoding: .utf8) ?? "{}"
            
            let values: [String: String] = [
                "status": TestStatus.completed.rawValue,
                "completion_time": ISO8601DateFormatter().string(from: Date()),
                "test_results": resultsString
            ]
            
            try await supabase.database
                .from("usertests")
                .update(values: values)
                .match(query: [
                    "user_id": userId.uuidString,
                    "test_id": testId.uuidString,
                    "status": TestStatus.inProgress.rawValue
                ])
                .execute()
            
            // Update local test results
            self.testResults = try JSONSerialization.jsonObject(with: resultsJson) as? [String: Any]
        } catch _ as EncodingError {
            throw TestError.completionFailed("Failed to encode test results")
        } catch {
            throw TestError.networkError(error)
        }
    }
    
    private func getCurrentUserTestId() async throws -> Int {
        do {
            let response = try await supabase.database
                .from("usertests")
                .select(columns: "id")
                .eq(column: "user_id", value: userId.uuidString)
                .eq(column: "test_id", value: testId.uuidString)
                .eq(column: "status", value: TestStatus.inProgress.rawValue)
                .single()
                .execute()
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let data = try JSONSerialization.data(withJSONObject: response.underlyingResponse.data)
            let result = try decoder.decode(UserTestId.self, from: data)
            return result.id
        } catch let error as PostgrestError where error.code == "PGRST116" {
            // No rows returned
            throw TestError.noActiveTest
        } catch {
            throw TestError.networkError(error)
        }
    }
    
    private struct UserTestId: Codable {
        let id: Int
    }
    
    private func calculateResults() -> TestResults {
        var totalScore = 0
        var questionScores: [String: Int] = [:]
        
        for (questionId, response) in responses {
            if let question = questions.first(where: { $0.questionId == questionId }),
               let option = question.options?.first(where: { $0.text == response }),
               let value = Int(option.value) {
                totalScore += value
                questionScores[String(questionId)] = value
            }
        }
        
        return TestResults(
            totalScore: totalScore,
            questionScores: questionScores,
            completionDate: Date()
        )
    }
    
    private func updateTestProgress() async throws {
        let values: [String: String] = [
            "progress": String(progress),
            "last_question_id": String(currentQuestion?.id ?? 0),
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        try await supabase.database
            .from("usertests")
            .update(values: values)
            .match(query: [
                "user_id": userId.uuidString,
                "test_id": testId.uuidString,
                "status": TestStatus.inProgress.rawValue
            ])
            .execute()
        
        testProgress = TestProgress(
            status: .inProgress,
            lastUpdated: Date(),
            score: nil
        )
    }
    
    func abandonTest() async throws {
        // Mark test as abandoned in database
        let values: [String: String] = [
            "status": "abandoned",
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        try await supabase.database
            .from("usertests")
            .update(values: values)
            .match(query: [
                "user_id": userId.uuidString,
                "test_id": testId.uuidString,
                "status": TestStatus.inProgress.rawValue
            ])
            .execute()
    }
    
    func retryQuestion() {
        if let currentQuestionId = currentQuestion?.id {
            responses.removeValue(forKey: currentQuestionId)
            error = nil
        }
    }
    
    func resetError() {
        error = nil
    }
    
    // Add convenience computed properties
    var canRetry: Bool {
        currentQuestion != nil && error != nil
    }
    
    var canProceed: Bool {
        if let currentQuestionId = currentQuestion?.id {
            return responses[currentQuestionId] != nil
        }
        return false
    }
    
    var progressPercentage: Double {
        Double(responses.count) / Double(questions.count)
    }
}

struct TestResults: Codable {
    let totalScore: Int
    let questionScores: [String: Int]
    let completionDate: Date
    
    enum CodingKeys: String, CodingKey {
        case totalScore = "total_score"
        case questionScores = "question_scores"
        case completionDate = "completion_date"
    }
}

private struct UserTest: Codable {
    let id: Int
    let userId: UUID
    let testId: UUID
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case testId = "test_id"
        case status
    }
} 