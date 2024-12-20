import SwiftUI

#Preview {
    NavigationStack {
        CourseCard(course: Course.preview)
            .padding()
            .frame(width: 300, height: 200)
    }
    .preferredColorScheme(.light)
}
