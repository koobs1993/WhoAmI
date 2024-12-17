import SwiftUI
import Supabase

struct WeeklyColumnListView: View {
    @StateObject private var viewModel: WeeklyColumnViewModel
    @EnvironmentObject private var authManager: AuthManager
    
    init(supabase: SupabaseClient) {
        _viewModel = StateObject(wrappedValue: WeeklyColumnViewModel(supabase: supabase))
    }
    
    var body: some View {
        NavigationView {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.columns.isEmpty {
                EmptyStateView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.columns) { column in
                            NavigationLink(destination: WeeklyColumnDetailView(supabase: viewModel.supabase, columnId: column.id)) {
                                WeeklyColumnRow(column: column, progress: viewModel.progress[column.id])
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Weekly Columns")
                .refreshable {
                    await viewModel.fetchColumns()
                }
            }
        }
        .task {
            await viewModel.fetchColumns()
        }
    }
}

struct WeeklyColumnRow: View {
    let column: WeeklyColumn
    let progress: UserWeeklyProgress?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(column.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(column.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text(column.publishedDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                ProgressBadge(progress: progress)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(radius: 5)
        )
    }
}

struct ProgressBadge: View {
    let progress: UserWeeklyProgress?
    
    var body: some View {
        if let progress = progress {
            if progress.isCompleted {
                Label("Completed", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if progress.inProgress {
                Label("In Progress", systemImage: "clock.fill")
                    .foregroundColor(.blue)
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No Columns Available")
                .font(.headline)
            Text("Check back later for new content")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
} 