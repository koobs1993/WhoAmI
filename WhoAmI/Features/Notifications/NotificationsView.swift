import SwiftUI

struct NotificationsView: View {
    @StateObject var viewModel: NotificationsViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.notifications) { notification in
                NotificationRow(notification: notification) { notification in
                    Task {
                        await viewModel.markAsRead(notification)
                    }
                }
            }
            .onDelete { indexSet in
                guard let index = indexSet.first else { return }
                let notification = viewModel.notifications[index]
                Task {
                    await viewModel.deleteNotification(notification)
                }
            }
        }
        .navigationTitle("Notifications")
        .toolbar {
            if !viewModel.notifications.isEmpty {
                Button("Clear All") {
                    Task {
                        await viewModel.clearAll()
                    }
                }
            }
        }
        .refreshable {
            await viewModel.fetchNotifications()
        }
        .task {
            await viewModel.fetchNotifications()
        }
    }
}

struct NotificationRow: View {
    let notification: UserNotification
    let onAction: (UserNotification) -> Void
    
    var body: some View {
        Button {
            if notification.status == .unread {
                onAction(notification)
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundStyle(iconColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundStyle(notification.status == .unread ? .primary : .secondary)
                    
                    Text(notification.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    
                    Text(timeAgo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if notification.status == .unread {
                    Circle()
                        .fill(.blue)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
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
        formatter.unitsStyle = .short
        return formatter.localizedString(for: notification.createdAt, relativeTo: Date())
    }
}

#Preview {
    NavigationStack {
        NotificationsView(viewModel: NotificationsViewModel(
            supabase: Config.supabaseClient,
            userId: UUID()
        ))
    }
}
