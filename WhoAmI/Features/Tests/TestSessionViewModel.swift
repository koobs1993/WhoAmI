import Foundation
import Supabase

@MainActor
class TestSessionViewModel: ObservableObject {
    private let supabase: SupabaseClient
    private let userId: UUID
    public let test: PsychTest
    
    @Published var questions: [PsychTest.TestQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var answers: [String: String] = [:]
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isComplete = false
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }
    
    var currentQuestion: PsychTest.TestQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    init(supabase: SupabaseClient, userId: UUID, test: PsychTest) {
        self.supabase = supabase
        self.userId = userId
        self.test = test
    }
    
    func startTest() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Load questions from test
            questions = test.questions
            
            // Create or update test progress
            try await supabase.database
                .from("testprogress")
                .upsert([
                    "id": UUID().uuidString,
                    "user_id": userId.uuidString,
                    "test_id": test.id.uuidString,
                    "status": TestStatus.inProgress.rawValue,
                    "current_question_index": "0",
                    "answers": "{}",
                    "score": nil,
                    "last_updated": ISO8601DateFormatter().string(from: Date())
                ])
                .execute()
        } catch {
            self.error = error
            throw error
        }
    }
    
    func submitAnswer(_ answer: String) {
        guard let question = currentQuestion else { return }
        answers[question.id.uuidString] = answer
        moveToNextQuestion()
    }
    
    private func moveToNextQuestion() {
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
        } else {
            isComplete = true
            Task {
                await saveProgress()
            }
        }
    }
    
    private func saveProgress() async {
        do {
            isLoading = true
            
            let answersJson = try JSONEncoder().encode(answers)
            let answersString = String(data: answersJson, encoding: .utf8) ?? "{}"
            
            try await supabase.database
                .from("testprogress")
                .upsert([
                    "id": UUID().uuidString,
                    "user_id": userId.uuidString,
                    "test_id": test.id.uuidString,
                    "status": (isComplete ? TestStatus.completed : .inProgress).rawValue,
                    "current_question_index": String(currentQuestionIndex),
                    "answers": answersString,
                    "score": nil,
                    "last_updated": ISO8601DateFormatter().string(from: Date())
                ])
                .execute()
            
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
}
