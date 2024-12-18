import SwiftUI
import Supabase

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @EnvironmentObject private var authManager: AuthManager
    
    init(supabase: SupabaseClient) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(supabase: supabase))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Weekly Column Section
                if !viewModel.weeklyColumns.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Weekly Insights")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(viewModel.weeklyColumns) { column in
                                    WeeklyColumnCard(column: column)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Ongoing Courses Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Ongoing Courses")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if viewModel.ongoingCourses.isEmpty {
                        Text("No active courses")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.ongoingCourses) { course in
                            NavigationLink(
                                destination: CourseDetailView(
                                    supabase: authManager.supabase,
                                    userId: authManager.currentUser?.id ?? UUID(),
                                    course: course
                                )
                            ) {
                                CourseProgressCard(course: course)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Dashboard")
        .task {
            await viewModel.fetchData()
        }
    }
}

struct WeeklyColumnCard: View {
    let column: WeeklyColumn
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(column.title)
                .font(.headline)
            
            Text(column.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            Text(column.createdAt?.formatted(.relative(presentation: .named)) ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 280)
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .textBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct CourseProgressCard: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(course.title)
                .font(.headline)
            
            if let description = course.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Label("Level \(course.difficulty)", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label(course.category, systemImage: "folder.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let duration = course.estimatedDuration {
                Label("\(duration) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar could be added here when we have progress data
            // ProgressView(value: progress)
            //     .progressViewStyle(.linear)
        }
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .textBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    NavigationView {
        DashboardView(supabase: Config.supabaseClient)
            .environmentObject(AuthManager(supabase: Config.supabaseClient))
    }
}
