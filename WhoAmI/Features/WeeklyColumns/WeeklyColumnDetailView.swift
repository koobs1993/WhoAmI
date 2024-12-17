import SwiftUI
import Supabase

struct WeeklyColumnDetailView: View {
    @StateObject private var viewModel: WeeklyColumnViewModel
    @State private var showingShareSheet = false
    
    init(supabase: SupabaseClient, columnId: Int) {
        let vm = WeeklyColumnViewModel(supabase: supabase)
        vm.selectedColumnId = columnId
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let column = viewModel.selectedColumn {
                    Text(column.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(column.content)
                        .font(.body)
                }
            }
            .padding()
        }
        .navigationBarItems(trailing: Button(action: {
            showingShareSheet = true
        }) {
            Image(systemName: "square.and.arrow.up")
        })
        .sheet(isPresented: $showingShareSheet) {
            if let column = viewModel.selectedColumn {
                if #available(iOS 16.0, *) {
                    ShareLink(item: "\(column.title)\n\n\(column.content)")
                } else {
                    // Fallback for older iOS versions
                    let activityVC = UIActivityViewController(
                        activityItems: ["\(column.title)\n\n\(column.content)"],
                        applicationActivities: nil
                    )
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController?.present(activityVC, animated: true)
                    }
                }
            }
        }
        .task {
            await viewModel.fetchSelectedColumn()
        }
    }
} 