import SwiftUI
import Supabase

struct CourseDetailView: View {
    @StateObject private var viewModel: CourseViewModel
    let course: Course
    
    init(supabase: SupabaseClient, userId: UUID, course: Course) {
        _viewModel = StateObject(wrappedValue: CourseViewModel(supabase: supabase, userId: userId))
        self.course = course
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let imageUrl = course.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 200)
                    .clipped()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(course.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let description = course.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    if let duration = course.estimatedDuration {
                        Label("\(duration) minutes", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Difficulty: \(course.difficulty)", systemImage: "star.fill")
                        Spacer()
                        Label(course.category, systemImage: "folder.fill")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding()
                
                if let lessons = course.lessons {
                    ForEach(lessons.sorted { $0.order < $1.order }) { lesson in
                        LessonRow(lesson: lesson)
                    }
                }
            }
        }
        .navigationTitle("Course Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationView {
        CourseDetailView(
            supabase: Config.supabaseClient,
            userId: UUID(),
            course: Course(
                id: 1,
                title: "Sample Course",
                description: "This is a sample course description",
                imageUrl: nil,
                difficulty: 1,
                category: "Programming",
                estimatedDuration: 60,
                createdAt: Date(),
                updatedAt: Date(),
                lessons: []
            )
        )
    }
}
