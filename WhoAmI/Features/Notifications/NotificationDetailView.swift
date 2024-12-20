import SwiftUI

struct NotificationDetailView: View {
    let notification: UserNotification
    let onAction: (UserNotification) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: iconName)
                        .font(.largeTitle)
                        .foregroundStyle(iconColor)
                    
                    Spacer()
                    
                    Text(timeAgo)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Text(notification.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(notification.message)
                    .font(.body)
                
                if let metadata = notification.metadata {
                    Divider()
                    
                    ForEach(metadata.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            Text(key.capitalized)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Text(value)
                                .font(.subheadline)
                        }
                    }
                }
                
                Spacer()
                
                if notification.status == .unread {
                    Button {
                        onAction(notification)
                    } label: {
                        Text("Mark as Read")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var iconName: String {
        switch notification.type {
        case .system: return "bell.fill"
        case .course: return "book.fill"
        case .test: return "pencil.circle.fill"
        case .achievement: return "star.fill"
        case .message: return "message.fill"
        }
    }
    
    private var iconColor: Color {
        switch notification.type {
        case .system: return .gray
        case .course: return .blue
        case .test: return .purple
        case .achievement: return .yellow
        case .message: return .green
        }
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: notification.createdAt, relativeTo: Date())
    }
}

#Preview {
    NavigationStack {
        NotificationDetailView(
            notification: UserNotification(
                id: UUID(),
                userId: UUID(),
                title: "Course Update",
                message: "New content has been added to your course.",
                type: .course,
                status: .unread,
                metadata: ["course": "Swift Programming", "section": "SwiftUI Basics"],
                createdAt: Date(),
                updatedAt: Date()
            ),
            onAction: { _ in }
        )
    }
}
