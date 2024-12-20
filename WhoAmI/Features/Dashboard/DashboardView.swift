import SwiftUI
import Supabase

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    
    init(supabase: SupabaseClient, userId: UUID) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(supabase: supabase, userId: userId))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Welcome Back!")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Continue your journey of self-discovery")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Progress Section
                    ProgressSection(progress: viewModel.overallProgress)
                        .padding(.horizontal)
                    
                    // Enrolled Courses Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Courses")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        CourseListView(supabase: viewModel.supabase, userId: viewModel.userId)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .task {
                await viewModel.fetchProgress()
            }
        }
    }
}

#Preview {
    NavigationView {
        DashboardView(supabase: Config.supabaseClient, userId: UUID())
            .environmentObject(AuthManager(supabase: Config.supabaseClient))
    }
}
