import SwiftUI
import Supabase

struct NotificationsView: View {
    @StateObject private var viewModel: NotificationsViewModel
    
    init(supabase: SupabaseClient) {
        _viewModel = StateObject(wrappedValue: NotificationsViewModel(supabase: supabase))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.notifications.isEmpty {
                    NotificationsEmptyStateView()
                } else {
                    List {
                        ForEach(viewModel.notifications) { notification in
                            NavigationLink(destination: NotificationDetailView(notification: notification, onAction: handleNotificationAction)) {
                                NotificationRow(notification: notification)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            .task {
                do {
                    try await viewModel.fetchNotifications()
                } catch {
                    print("Error loading notifications: \(error)")
                }
            }
        }
    }
    
    private func handleNotificationAction(_ action: NotificationAction) {
        Task {
            switch action.type {
            case .openTest:
                if let testId = action.metadata["testId"],
                   let url = URL(string: "whoami://test/\(testId)") {
                    #if os(iOS)
                    UIApplication.shared.open(url)
                    #else
                    NSWorkspace.shared.open(url)
                    #endif
                }
            case .openCourse:
                if let courseId = action.metadata["courseId"],
                   let url = URL(string: "whoami://course/\(courseId)") {
                    #if os(iOS)
                    UIApplication.shared.open(url)
                    #else
                    NSWorkspace.shared.open(url)
                    #endif
                }
            case .openChat:
                if let chatId = action.metadata["chatId"],
                   let url = URL(string: "whoami://chat/\(chatId)") {
                    #if os(iOS)
                    UIApplication.shared.open(url)
                    #else
                    NSWorkspace.shared.open(url)
                    #endif
                }
            case .openURL:
                if let urlString = action.metadata["url"],
                   let url = URL(string: urlString) {
                    #if os(iOS)
                    UIApplication.shared.open(url)
                    #else
                    NSWorkspace.shared.open(url)
                    #endif
                }
            }
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
    NotificationsView(supabase: Config.supabaseClient)
} 