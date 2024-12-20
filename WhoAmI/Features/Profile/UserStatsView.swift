import SwiftUI

struct UserStatsView: View {
    let stats: UserStats
    
    var body: some View {
        VStack(spacing: AdaptiveLayout.standardSpacing) {
            // Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AdaptiveLayout.standardSpacing) {
                StatCard(
                    title: "Tests",
                    value: "\(stats.testsCompleted)",
                    icon: "checkmark.circle.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Courses",
                    value: "\(stats.coursesCompleted)",
                    icon: "book.closed.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Achievements",
                    value: "\(stats.achievementsEarned)",
                    icon: "star.fill",
                    color: .orange
                )
            }
        }
        .adaptivePadding()
    }
}

#Preview {
    UserStatsView(stats: UserStats(
        testsCompleted: 42,
        coursesCompleted: 12,
        achievementsEarned: 7
    ))
}
