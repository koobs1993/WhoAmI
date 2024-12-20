import SwiftUI

struct LessonRow: View {
    let lesson: Lesson
    var onStatusChange: ((LessonStatus) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(lesson.title)
                    .font(.headline)
                
                Spacer()
                
                if let duration = lesson.duration {
                    Label("\(duration) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let description = lesson.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            if let status = lesson.status {
                HStack {
                    Spacer()
                    Menu {
                        ForEach(LessonStatus.allCases, id: \.self) { newStatus in
                            Button(action: {
                                onStatusChange?(newStatus)
                            }) {
                                Label(newStatus.displayName, systemImage: newStatus.iconName)
                            }
                        }
                    } label: {
                        Label(status.displayName, systemImage: status.iconName)
                            .font(.caption)
                            .foregroundColor(status.color)
                    }
                }
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .textBackgroundColor))
        #endif
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

extension LessonStatus {
    var displayName: String {
        switch self {
        case .notStarted: return "Not Started"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }
    
    var iconName: String {
        switch self {
        case .notStarted: return "circle"
        case .inProgress: return "clock"
        case .completed: return "checkmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .notStarted: return .secondary
        case .inProgress: return .blue
        case .completed: return .green
        }
    }
}

#Preview {
    LessonRow(
        lesson: Lesson(
            id: UUID(),
            courseId: UUID(),
            title: "Sample Lesson",
            description: "This is a sample lesson description that might be a bit longer to show how it wraps.",
            content: "Full lesson content here...",
            duration: 30,
            order: 1,
            status: .inProgress
        )
    )
    .padding()
}
