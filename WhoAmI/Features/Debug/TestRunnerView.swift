import SwiftUI

struct TestRunnerView: View {
    @State private var testResults: [TestResult] = []
    @State private var isRunning = false
    
    var body: some View {
        List {
            ForEach(testResults) { result in
                TestResultRow(result: result)
            }
        }
        .navigationTitle("Test Runner")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    testResults.removeAll()
                } label: {
                    Label("Clear", systemImage: "trash")
                }
                .disabled(isRunning || testResults.isEmpty)
            }
            
            ToolbarItem(placement: .automatic) {
                Button {
                    Task {
                        await runAllTests()
                    }
                } label: {
                    Label("Run All", systemImage: "play.fill")
                }
                .disabled(isRunning)
            }
        }
    }
    
    private func runAllTests() async {
        isRunning = true
        defer { isRunning = false }
        
        for type in TestType.allCases {
            do {
                try await runTest(type)
            } catch {
                recordFailure(for: type, error: error)
            }
        }
    }
    
    private func runTest(_ type: TestType) async throws {
        do {
            switch type {
            case .auth:
                try await TestHelper.shared.runAuthTests()
                recordSuccess(for: type)
            case .course:
                try await TestHelper.shared.runCourseTests()
                recordSuccess(for: type)
            case .test:
                try await TestHelper.shared.runPsychTestTests()
                recordSuccess(for: type)
            case .weeklyColumn:
                try await TestHelper.shared.runWeeklyColumnTests()
                recordSuccess(for: type)
            case .character:
                try await TestHelper.shared.runCharacterTests()
                recordSuccess(for: type)
            case .chat:
                try await TestHelper.shared.runChatTests()
                recordSuccess(for: type)
            case .profile:
                try await TestHelper.shared.runProfileTests()
                recordSuccess(for: type)
            case .notification:
                try await TestHelper.shared.runNotificationTests()
                recordSuccess(for: type)
            case .all:
                await runAllTests()
            }
        } catch {
            recordFailure(for: type, error: error)
            throw error
        }
    }
    
    private func recordSuccess(for type: TestType) {
        testResults.append(TestResult(type: type, status: TestResultStatus.success))
    }
    
    private func recordFailure(for type: TestType, error: Error) {
        testResults.append(TestResult(type: type, status: TestResultStatus.failure))
    }
}

struct TestResultRow: View {
    let result: TestResult
    
    var body: some View {
        HStack {
            Image(systemName: result.status.iconName)
                .foregroundColor(result.status.color)
            
            VStack(alignment: .leading) {
                Text(result.type.rawValue)
                    .font(.headline)
                
                if case .failure(let error) = result.status {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

enum TestType: String, CaseIterable {
    case auth = "Authentication"
    case course = "Course"
    case test = "Psych Test"
    case weeklyColumn = "Weekly Column"
    case character = "Character"
    case chat = "Chat"
    case profile = "Profile"
    case notification = "Notification"
    case all = "All Tests"
}

struct TestResult: Identifiable {
    let id = UUID()
    let type: TestType
    let status: TestResultStatus
}

class TestRunner: ObservableObject {
    @Published var testResults: [TestResult] = []
    
    private func recordSuccess(for type: TestType) {
        testResults.append(TestResult(type: type, status: TestResultStatus.success))
    }
    
    private func recordFailure(for type: TestType, error: Error) {
        testResults.append(TestResult(type: type, status: TestResultStatus.failure))
    }
}

struct TestResultView: View {
    let result: TestResult
    
    var body: some View {
        HStack {
            Image(systemName: result.status.iconName)
                .foregroundColor(result.status.color)
            
            VStack(alignment: .leading) {
                Text(result.name)
                    .font(.headline)
                if case .failure(let error) = result.status {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
    }
} 