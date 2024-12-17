import SwiftUI
import Supabase

struct TestListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TestListViewModel
    @State private var showingTestDetails = false
    @State private var selectedTest: PsychTest?
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
        _viewModel = StateObject(wrappedValue: TestListViewModel(supabase: supabase))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.tests) { test in
                TestRowView(test: test)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedTest = test
                        showingTestDetails = true
                    }
            }
        }
        .navigationTitle("Tests")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
            }
            #else
            ToolbarItem(placement: .automatic) {
                Button("Done") { dismiss() }
            }
            #endif
        }
        .sheet(isPresented: $showingTestDetails) {
            if let test = selectedTest {
                TestDetailView(test: test, supabase: supabase)
            }
        }
        .task {
            await viewModel.fetchTests()
        }
    }
}

struct TestRowView: View {
    let test: PsychTest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(test.title)
                .font(.headline)
            
            Text(test.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label("\(test.estimatedDuration) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let status = test.status {
                    StatusBadge(status: status)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(statusColor.opacity(0.2))
            )
            .foregroundColor(statusColor)
    }
    
    private var statusColor: Color {
        switch status.lowercased() {
        case "active":
            return .green
        case "completed":
            return .blue
        case "archived":
            return .gray
        default:
            return .primary
        }
    }
} 