import SwiftUI

struct LessonRow: View {
    let lesson: Lesson
    
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
                
                if let status = lesson.status {
                    Image(systemName: statusIcon(for: status))
                        .foregroundColor(statusColor(for: status))
                }
            }
            
            if let description = lesson.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .textBackgroundColor))
        #endif
        .cornerRadius(8)
        .shadow(radius: 2)
    }
    
    private func statusIcon(for status: LessonStatus) -> String {
        switch status {
        case .notStarted:
            return "circle"
        case .inProgress:
            return "circle.lefthalf.filled"
        case .completed:
            return "checkmark.circle.fill"
        }
    }
    
    private func statusColor(for status: LessonStatus) -> Color {
        switch status {
        case .notStarted:
            return .secondary
        case .inProgress:
            return .orange
        case .completed:
            return .green
        }
    }
}

#Preview {
    LessonRow(
        lesson: Lesson(
            id: 1,
            courseId: 1,
            title: "Sample Lesson",
            description: "This is a sample lesson description that might be a bit longer to show how it wraps.",
            content: "",
            duration: 30,
            order: 1,
            status: .inProgress,
            createdAt: Date(),
            updatedAt: Date()
        )
    )
    .padding()
}
