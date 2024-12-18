import SwiftUI

struct NotificationDetailView: View {
    let notification: UserNotification
    let onAction: (NotificationAction) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: notification.type.icon)
                    .font(.title2)
                    .foregroundColor(notification.type.color)
                
                Text(notification.title)
                    .font(.headline)
            }
            
            Text(notification.message)
                .font(.body)
                .foregroundColor(.secondary)
            
            let actions = NotificationAction.actions(for: notification.type, metadata: notification.metadata)
            if !actions.isEmpty {
                HStack {
                    ForEach(actions) { action in
                        Button(action: {
                            onAction(action)
                        }) {
                            Text(action.title)
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            HStack {
                Text(notification.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if notification.read {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// Preview provider
struct NotificationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationDetailView(
            notification: UserNotification(
                id: UUID(),
                userId: UUID(),
                type: .courseUpdate,
                title: "New Course Available",
                message: "Check out our new course on SwiftUI!",
                metadata: ["course_id": UUID().uuidString],
                read: false,
                createdAt: Date()
            ),
            onAction: { _ in }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 