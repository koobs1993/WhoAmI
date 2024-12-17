import SwiftUI
import Supabase

struct NotificationsView: View {
    @StateObject private var viewModel: NotificationsViewModel
    @State private var showingSettings = false
    
    init(supabase: SupabaseClient) {
        _viewModel = StateObject(wrappedValue: NotificationsViewModel(supabase: supabase))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.notifications.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(viewModel.notifications) { notification in
                            NavigationLink {
                                NotificationDetailView(notification: notification)
                            } label: {
                                NotificationRow(notification: notification)
                            }
                        }
                        .onDelete { indexSet in
                            Task {
                                if let index = indexSet.first {
                                    try? await viewModel.deleteNotification(viewModel.notifications[index])
                                }
                            }
                        }
                    }
                    .refreshable {
                        try? await viewModel.loadNotifications()
                    }
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.notifications.isEmpty {
                        Button {
                            Task {
                                try? await viewModel.markAllAsRead()
                            }
                        } label: {
                            Text("Mark All Read")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .task {
            try? await viewModel.loadNotifications()
        }
        .sheet(isPresented: $showingSettings) {
            NotificationSettingsView(viewModel: viewModel)
        }
    }
}

struct NotificationRow: View {
    let notification: UserNotification
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(notification.isRead ? Color.gray.opacity(0.3) : Color.blue)
                .frame(width: 12, height: 12)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Spacer()
                
                Text(notification.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Notifications")
                .font(.headline)
            
            Text("You're all caught up!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NotificationsView(supabase: Config.supabaseClient)
} 