import Foundation
import Supabase

@MainActor
class WeeklyColumnViewModel: ObservableObject {
    @Published var columns: [WeeklyColumn] = []
    @Published var progress: [UUID: UserWeeklyProgress] = [:]
    @Published var questions: [WeeklyQuestion] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let service: WeeklyColumnServiceProtocol
    private let userId: UUID
    
    init(service: WeeklyColumnServiceProtocol, userId: UUID) {
        self.service = service
        self.userId = userId
        Task {
            await fetchColumns()
        }
    }
    
    func fetchColumns() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let columns = try await service.fetchColumns()
            self.columns = columns
            await fetchProgress()
        } catch {
            self.error = error
        }
    }
    
    private func fetchProgress() async {
        do {
            let userProgress = try await service.fetchProgress(userId: userId)
            let progressDict = Dictionary(
                uniqueKeysWithValues: userProgress.map { ($0.columnId, $0) }
            )
            self.progress = progressDict
        } catch {
            self.error = error
        }
    }
    
    func fetchQuestions(for columnId: UUID) async {
        do {
            questions = try await service.fetchQuestions(columnId: columnId)
        } catch {
            self.error = error
        }
    }
    
    func submitResponse(_ response: String, for questionId: UUID) async throws {
        let weeklyResponse = WeeklyResponse(
            userId: userId,
            questionId: questionId,
            response: response
        )
        
        try await service.submitResponse(weeklyResponse)
        
        // Update progress
        if let currentQuestionIndex = questions.firstIndex(where: { $0.id == questionId }),
           let columnId = questions.first?.columnId {
            try await service.saveProgress(
                userId: userId,
                columnId: columnId,
                lastQuestionId: questionId,
                completed: currentQuestionIndex == questions.count - 1
            )
            
            // Update local progress
            let updatedProgress = UserWeeklyProgress(
                userId: userId,
                columnId: columnId,
                lastQuestionId: questionId,
                completed: currentQuestionIndex == questions.count - 1
            )
            progress[columnId] = updatedProgress
        }
    }
    
    func getProgress(for columnId: UUID) -> UserWeeklyProgress? {
        progress[columnId]
    }
}
