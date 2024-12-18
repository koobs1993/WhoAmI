import Foundation
import SwiftUI

@MainActor
class WeeklyColumnViewModel: ObservableObject {
    @Published var columns: [WeeklyColumn] = []
    @Published var selectedColumn: WeeklyColumn?
    @Published var questions: [WeeklyQuestion] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var progress: [Int: UserWeeklyProgress] = [:]
    @Published var currentQuestionIndex = 0
    
    private let service: WeeklyColumnServiceProtocol
    private let userId: UUID
    
    init(service: WeeklyColumnServiceProtocol, userId: UUID) {
        self.service = service
        self.userId = userId
    }
    
    func fetchColumns() async {
        isLoading = true
        error = nil
        
        do {
            columns = try await service.fetchColumns()
            await fetchProgress()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    private func fetchProgress() async {
        do {
            let userProgress = try await service.fetchProgress(userId: userId)
            progress = Dictionary(uniqueKeysWithValues: userProgress.map { ($0.columnId, $0) })
        } catch {
            print("Error fetching progress: \(error)")
        }
    }
    
    func fetchQuestions(for columnId: Int) async throws {
        questions = try await service.fetchQuestions(for: columnId)
    }
    
    func submitResponse(_ response: String, for questionId: Int) async throws {
        try await service.saveResponse(userId: userId, questionId: questionId, response: response)
        
        if let columnId = questions[safe: currentQuestionIndex]?.columnId {
            try await updateProgress(columnId: columnId)
        }
    }
    
    private func updateProgress(columnId: Int) async throws {
        let isLastQuestion = currentQuestionIndex == questions.count - 1
        try await service.saveProgress(
            userId: userId,
            columnId: columnId,
            lastQuestionId: questions[currentQuestionIndex].id,
            completed: isLastQuestion
        )
        
        // Update local progress
        if isLastQuestion {
            progress[columnId]?.isCompleted = true
        }
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
} 