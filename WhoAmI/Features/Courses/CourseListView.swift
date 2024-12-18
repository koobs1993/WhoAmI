import SwiftUI
import Supabase

struct CourseListView: View {
    @StateObject private var viewModel: CourseViewModel
    @EnvironmentObject private var authManager: AuthManager
    
    init(supabase: SupabaseClient, userId: UUID) {
        _viewModel = StateObject(wrappedValue: CourseViewModel(supabase: supabase, userId: userId))
    }
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading courses...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("Error Loading Courses")
                        .font(.headline)
                    
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Try Again") {
                        Task {
                            await loadCourses()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if viewModel.courses.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "book")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No Courses Available")
                        .font(.headline)
                    
                    Text("Check back later for new courses")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.courses) { course in
                        NavigationLink(
                            destination: CourseDetailView(
                                supabase: authManager.supabase,
                                userId: authManager.currentUser?.id ?? UUID(),
                                course: course
                            )
                        ) {
                            CourseCard(course: course)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Courses")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            await loadCourses()
        }
    }
    
    private func loadCourses() async {
        do {
            try await viewModel.fetchEnrolledCourses()
        } catch {
            print("Error fetching courses: \(error)")
            viewModel.error = error
        }
    }
}

struct CourseCard: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageUrl = course.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 120)
                .clipped()
            }
            
            VStack(alignment: .leading, spacing: 4) {
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
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
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
        CourseListView(
            supabase: Config.supabaseClient,
            userId: UUID()
        )
        .environmentObject(AuthManager(supabase: Config.supabaseClient))
    }
}
