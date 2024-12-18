import SwiftUI

struct CourseDetailView: View {
    @ObservedObject var viewModel: CourseViewModel
    
    var body: some View {
        ScrollView {
            content
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            courseHeader
            lessonsList
        }
        .padding()
    }
    
    private var courseHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let course = viewModel.currentCourse {
                Text(course.title)
                    .font(.title)
                    .bold()
                
                Text(course.description)
                    .foregroundColor(.secondary)
                
                if let duration = course.estimatedDuration {
                    HStack {
                        Image(systemName: "clock")
                        Text("\(duration) minutes")
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var lessonsList: some View {
        VStack(alignment: .leading, spacing: 15) {
            if let course = viewModel.currentCourse,
               let lessons = course.lessons {
                Text("Lessons")
                    .font(.headline)
                
                ForEach(lessons) { lesson in
                    LessonRow(lesson: lesson, viewModel: viewModel)
                }
            }
        }
    }
}

struct LessonRow: View {
    let lesson: Lesson
    @ObservedObject var viewModel: CourseViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(lesson.title)
                    .font(.subheadline)
                    .bold()
                
                Spacer()
                
                if lesson.status == .completed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(lesson.content)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

#Preview {
    CourseDetailView(viewModel: CourseViewModel(
        supabase: Config.supabaseClient
    ))
} 