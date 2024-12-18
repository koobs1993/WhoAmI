import SwiftUI
import Supabase

struct NotificationsView: View {
    @StateObject private var viewModel: NotificationsViewModel
    
    init(supabase: SupabaseClient, userId: UUID) {
        _viewModel = StateObject(wrappedValue: NotificationsViewModel(supabase: supabase, userId: userId))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.notifications.isEmpty {
                    NotificationsEmptyStateView()
                } else {
                    List {
                        ForEach(viewModel.notifications) { notification in
                            NavigationLink(destination: NotificationDetailView(
                                notification: UserNotification(
                                    id: notification.id,
                                    userId: notification.userId,
                                    type: notificationType(from: notification.type),
                                    title: notification.title,
                                    message: notification.message,
                                    read: notification.read,
                                    createdAt: notification.createdAt
                                ),
                                onAction: { userNotification in
                                    Task {
                                        await viewModel.markAsRead(notification)
                                    }
                                }
                            )) {
                                NotificationRow(notification: UserNotification(
                                    id: notification.id,
                                    userId: notification.userId,
                                    type: notificationType(from: notification.type),
                                    title: notification.title,
                                    message: notification.message,
                                    read: notification.read,
                                    createdAt: notification.createdAt
                                ))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    NavigationLink(destination: NotificationSettingsView(viewModel: viewModel)) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .task {
            await viewModel.fetchNotifications()
        }
    }
    
    private func notificationType(from type: String) -> WhoAmI.NotificationType {
        switch type.lowercased() {
        case "warning":
            return .warning
        case "success":
            return .success
        case "error":
            return .error
        case "course_update":
            return .courseUpdate
        case "test_reminder":
            return .testReminder
        case "message":
            return .message
        case "achievement":
            return .achievement
        case "system":
            return .system
        default:
            return .info
        }
    }
}

struct NotificationsEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Notifications")
                .font(.headline)
            
            Text("You don't have any notifications yet.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct NotificationRow: View {
    let notification: UserNotification
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: notification.type.icon)
                    .foregroundColor(notification.type.color)
                Text(notification.title)
                    .font(.headline)
                Spacer()
                if !notification.read {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
            }
            
            Text(notification.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Text(notification.createdAt, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NotificationsView(supabase: Config.supabaseClient, userId: UUID())
}
