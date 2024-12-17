import SwiftUI

struct NotificationDetailView: View {
    let notification: UserNotification
    let onAction: (NotificationAction) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                // Header
                HStack {
                    Image(systemName: notification.type.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(notification.type.color)
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading) {
                        Text(notification.title)
                            .font(.headline)
                        Text(notification.createdAt, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                
                // Content
                Text(notification.message)
                    .padding()
                
                // Actions
                if let metadata = notification.metadata {
                    ForEach(NotificationAction.actions(for: notification.type, metadata: metadata)) { action in
                        Button(action: { onAction(action) }) {
                            HStack {
                                Image(systemName: action.icon)
                                Text(action.title)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationAction: Identifiable {
    let id = UUID()
    let type: ActionType
    let title: String
    let icon: String
    let metadata: [String: String]
    
    enum ActionType {
        case openURL
        case openCourse
        case openTest
        case openChat
    }
    
    static func actions(for type: NotificationType, metadata: [String: String]) -> [NotificationAction] {
        switch type {
        case .courseUpdate:
            return [NotificationAction(type: .openCourse, title: "View Course", icon: "book", metadata: metadata)]
        case .testReminder:
            return [NotificationAction(type: .openTest, title: "Start Test", icon: "pencil", metadata: metadata)]
        case .message:
            return [NotificationAction(type: .openChat, title: "View Message", icon: "message", metadata: metadata)]
        case .achievement:
            return [NotificationAction(type: .openURL, title: "View Achievement", icon: "trophy", metadata: metadata)]
        case .system:
            if let urlString = metadata["url"] {
                return [NotificationAction(type: .openURL, title: "Learn More", icon: "arrow.right", metadata: metadata)]
            }
            return []
        }
    }
}

#Preview {
    NavigationView {
        NotificationDetailView(
            notification: UserNotification(
                id: UUID(),
                userId: UUID(),
                type: .courseUpdate,
                title: "Course Update",
                message: "New content available in your course",
                metadata: ["course_id": UUID().uuidString],
                isRead: false,
                createdAt: Date()
            )
        ) { action in
            print("Action: \(action)")
        }
    }
} 