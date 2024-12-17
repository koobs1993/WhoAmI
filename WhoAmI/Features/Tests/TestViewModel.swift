import Foundation
import Supabase

enum TestCategory: String, CaseIterable {
    case personality = "Personality"
    case anxiety = "Anxiety"
    case depression = "Depression"
    case stress = "Stress"
    case relationships = "Relationships"
    case career = "Career"
    case other = "Other"
}

struct TestQuestion: Codable, Identifiable {
    let id: Int
    let questionId: Int
    let testId: Int
    let questionText: String
    let sequenceOrder: Int
    let options: [QuestionOption]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case questionId = "question_id"
        case testId = "test_id"
        case questionText = "question_text"
        case sequenceOrder = "sequence_order"
        case options = "questionoptions"
    }
}

struct QuestionOption: Codable {
    let id: Int
    let questionId: Int
    let optionText: String
    let scoreValue: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case questionId = "question_id"
        case optionText = "option_text"
        case scoreValue = "score_value"
    }
}

@MainActor
class TestViewModel: ObservableObject {
    @Published var tests: [PsychTest] = []
    @Published var filteredTests: [PsychTest] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedCategory: TestCategory?
    @Published var searchText = ""
    
    private let supabase: SupabaseClient
    private let userId: UUID
    private let cache = NSCache<NSString, CacheEntry>()
    private let cacheDuration: TimeInterval = 300 // 5 minutes
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
        setupCache()
    }
    
    private func setupCache() {
        cache.countLimit = 50
        cache.totalCostLimit = 10 * 1024 * 1024 // 10MB
    }
    
    func fetchTests() async {
        isLoading = true
        error = nil
        
        // Check cache first
        let cacheKey = "tests_\(userId)" as NSString
        if let cached = cache.object(forKey: cacheKey), !cached.isExpired {
            self.tests = cached.tests
            updateFilteredTests()
            isLoading = false
            return
        }
        
        do {
            // Fetch tests with benefits and user progress
            let response = try await supabase.database
                .from("psychtests")
                .select("""
                    *,
                    testbenefits (
                        benefit_id,
                        test_id,
                        icon_url,
                        benefit_text,
                        display_order,
                        created_at,
                        updated_at
                    ),
                    usertests!left (
                        user_test_id,
                        user_id,
                        test_id,
                        last_question_id,
                        start_time,
                        completion_time,
                        status,
                        test_results,
                        created_at,
                        updated_at
                    ),
                    testquestions!left (count)
                """)
                .eq("is_active", true)
                .eq("usertests.user_id", userId)
                .order("created_at")
                .execute()
            
            self.tests = try response.decode()
            
            // Cache the results
            cache.setObject(CacheEntry(tests: self.tests), forKey: cacheKey)
            
            updateFilteredTests()
            
        } catch {
            self.error = error
            print("Error fetching tests: \(error)")
        }
        
        isLoading = false
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
                ($0.description ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort by status and date
        filtered.sort { test1, test2 in
            if let progress1 = test1.userProgress, let progress2 = test2.userProgress {
                if progress1.status == progress2.status {
                    return progress1.updatedAt > progress2.updatedAt
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
    
    private let supabase: SupabaseClient
    private let userId: UUID
    private let testId: Int
    
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
    
    func startTest() async {
        isLoading = true
        error = nil
        
        do {
            // Create user test record
            try await supabase.database
                .from("usertests")
                .insert([
                    "user_id": userId,
                    "test_id": testId,
                    "start_time": Date(),
                    "status": TestStatus.inProgress.rawValue
                ])
                .execute()
            
            // Fetch questions
            await fetchQuestions()
            
        } catch {
            self.error = error
            print("Error starting test: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchQuestions() async {
        isLoading = true
        error = nil
        
        do {
            let response = try await supabase.database
                .from("testquestions")
                .select(columns: """
                    *,
                    questionoptions (*)
                """)
                .eq(column: "test_id", value: testId)
                .order(column: "sequence_order", ascending: true)
                .execute()
            
            self.questions = try response.decode()
            
        } catch {
            self.error = error
            print("Error fetching questions: \(error)")
        }
        
        isLoading = false
    }
    
    func submitResponse(_ response: String, forQuestion questionId: Int) async {
        responses[questionId] = response
        
        do {
            // Save response
            try await supabase.database
                .from("usertestresponses")
                .insert(values: [
                    "user_test_id": getCurrentUserTestId(),
                    "question_id": questionId,
                    "response_value": Int(response) ?? 0
                ])
                .execute()
            
            // Update last question
            try await supabase.database
                .from("usertests")
                .update(values: [
                    "last_question_id": questionId
                ])
                .eq(column: "user_id", value: userId)
                .eq(column: "test_id", value: testId)
                .execute()
            
            if !isLastQuestion {
                currentQuestionIndex += 1
            }
            
        } catch {
            self.error = error
            print("Error submitting response: \(error)")
        }
    }
    
    func submitTest() async {
        isLoading = true
        error = nil
        
        do {
            let results = calculateResults()
            
            // Update test status and results
            try await supabase.database
                .from("usertests")
                .update(values: [
                    "status": TestStatus.completed.rawValue,
                    "completion_time": ISO8601DateFormatter().string(from: Date()),
                    "test_results": results
                ])
                .eq(column: "user_id", value: userId)
                .eq(column: "test_id", value: testId)
                .execute()
            
            self.testResults = results
            
        } catch {
            self.error = error
            print("Error submitting test: \(error)")
        }
        
        isLoading = false
    }
    
    private func getCurrentUserTestId() async throws -> Int {
        let query = supabase.database
            .from("usertests")
            .select()
            .eq(column: "user_id", value: userId)
            .eq(column: "test_id", value: testId)
            .single()
            .execute()
        
        struct UserTest: Codable {
            let userTestId: Int
            
            enum CodingKeys: String, CodingKey {
                case userTestId = "user_test_id"
            }
        }
        
        let response: PostgrestResponse<UserTest> = try await query
        return response.value.userTestId
    }
    
    private func calculateResults() -> [String: Any] {
        var totalScore = 0
        var questionScores: [String: Int] = [:]
        
        for (questionId, response) in responses {
            if let question = questions.first(where: { $0.questionId == questionId }),
               let option = question.options?.first(where: { $0.optionText == response }) {
                totalScore += option.scoreValue
                questionScores[String(questionId)] = option.scoreValue
            }
        }
        
        return [
            "total_score": totalScore,
            "question_scores": questionScores,
            "completion_date": ISO8601DateFormatter().string(from: Date())
        ]
    }
} 