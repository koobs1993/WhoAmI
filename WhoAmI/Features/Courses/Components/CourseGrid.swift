import SwiftUI
import Supabase

struct CourseGrid: View {
    let courses: [Course]
    let supabase: SupabaseClient
    let userId: UUID
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            ForEach(courses) { course in
                NavigationLink(destination: CourseDetailView(
                    supabase: supabase,
                    userId: userId,
                    course: course
                )) {
                    CourseCard(course: course)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    CourseGrid(
        courses: [Course.preview, Course.preview],
        supabase: Config.supabaseClient,
        userId: UUID()
    )
}
