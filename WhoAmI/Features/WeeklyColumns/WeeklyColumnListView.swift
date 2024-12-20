import SwiftUI

struct WeeklyColumnListView: View {
    @ObservedObject private var viewModel: WeeklyColumnViewModel
    
    init(service: WeeklyColumnServiceProtocol, userId: UUID) {
        viewModel = WeeklyColumnViewModel(service: service, userId: userId)
    }
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView("Loading columns...")
        } else if let error = viewModel.error {
            ErrorView(error: error) {
                Task {
                    await viewModel.fetchColumns()
                }
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.columns) { column in
                        NavigationLink(destination: WeeklyColumnDetailView(column: column)) {
                            WeeklyColumnRow(column: column, progress: viewModel.progress[column.id])
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .refreshable {
                await viewModel.fetchColumns()
            }
            .task {
                if viewModel.columns.isEmpty {
                    await viewModel.fetchColumns()
                }
            }
        }
    }
}

struct WeeklyColumnRow: View {
    let column: WeeklyColumn
    let progress: UserWeeklyProgress?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(column.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(column.shortDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if let date = column.createdAt {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let progress = progress {
                ProgressView(value: progress.completed ? 1.0 : 0.0, total: 1.0)
                    .tint(.blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.adaptiveBackground : Color.adaptiveSecondaryBackground)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}
