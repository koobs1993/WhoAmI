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
            let progress = TestProgress(
                userId: userId,
                testId: test.id,
                status: .inProgress,
                currentQuestionIndex: 0,
                answers: [:]
            )
            
            try await supabase.database.from("test_progress")
                .upsert([
                    "user_id": progress.userId.uuidString,
                    "test_id": progress.testId.uuidString,
                    "status": progress.status.rawValue,
                    "current_question_index": progress.currentQuestionIndex,
                    "answers": progress.answers,
                    "last_updated": ISO8601DateFormatter().string(from: progress.lastUpdated)
                ])
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
            let progress = TestProgress(
                userId: userId,
                testId: test.id,
                status: isComplete ? .completed : .inProgress,
                currentQuestionIndex: currentQuestionIndex,
                answers: answers
            )
            
            try await supabase.database.from("test_progress")
                .upsert([
                    "user_id": progress.userId.uuidString,
                    "test_id": progress.testId.uuidString,
                    "status": progress.status.rawValue,
                    "current_question_index": progress.currentQuestionIndex,
                    "answers": progress.answers,
                    "last_updated": ISO8601DateFormatter().string(from: progress.lastUpdated)
                ])
            
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
}
