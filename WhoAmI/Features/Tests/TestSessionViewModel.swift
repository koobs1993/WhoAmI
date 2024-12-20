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
    @Published var selectedAnswerIndex: Int?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isComplete = false
    @Published var timeRemaining: TimeInterval = 3600 // 1 hour default
    private var timer: Timer?
    
    var currentScore: Int {
        // Calculate score based on correct answers
        var score = 0
        for (questionId, answer) in answers {
            if let question = questions.first(where: { $0.id.uuidString == questionId }),
               let answerIndex = Int(answer),
               let options = question.options,
               answerIndex < options.count,
               question.correctAnswer == answerIndex {
                score += 1
            }
        }
        return score
    }
    
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
    
    func selectAnswer(_ index: Int) {
        selectedAnswerIndex = index
        guard let question = currentQuestion else { return }
        answers[question.id.uuidString] = String(index)
    }
    
    func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            selectedAnswerIndex = Int(answers[questions[currentQuestionIndex].id.uuidString] ?? "")
        }
    }
    
    func nextQuestion() {
        moveToNextQuestion()
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resumeTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.completeTest()
            }
        }
    }
    
    func completeTest() {
        isComplete = true
        pauseTimer()
        Task {
            await saveProgress()
        }
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
