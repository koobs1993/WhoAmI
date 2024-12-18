import SwiftUI

struct NotificationDetailView: View {
    let notification: UserNotification
    let onAction: (UserNotification) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: notification.type.icon)
                        .foregroundColor(notification.type.color)
                        .font(.title)
                    
                    Text(notification.title)
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Text(notification.message)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text(notification.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !notification.read {
                    Button(action: {
                        onAction(notification)
                    }) {
                        Text("Mark as Read")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                }
            }
            .padding()
        }
        .navigationTitle("Notification Details")
    }
}

struct NotificationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NotificationDetailView(
                notification: UserNotification(
                    id: UUID(),
                    userId: UUID(),
                    type: .system,
                    title: "New Course Available",
                    message: "Check out our new course on SwiftUI!",
                    read: false,
                    createdAt: Date()
                ),
                onAction: { _ in }
            )
        }
    }
}
