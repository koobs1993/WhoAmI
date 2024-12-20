import SwiftUI

struct ProfileHeader: View {
    let profile: UserProfile
    let stats: UserStats?
    let onEditTap: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Avatar and Edit Button
            HStack {
                Spacer()
                ZStack(alignment: .bottomTrailing) {
                    ProfileAvatar(profile: profile)
                        .frame(width: 100, height: 100)
                    
                    Button(action: onEditTap) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.blue)
                            .background(Color.adaptiveBackground)
                            .clipShape(Circle())
                    }
                    .offset(x: 8, y: 8)
                }
                Spacer()
            }
            
            // Name and Bio
            VStack(spacing: 8) {
                Text("\(profile.firstName) \(profile.lastName)")
                    .font(.adaptiveTitle())
                    .fontWeight(.semibold)
                
                if let bio = profile.bio {
                    Text(bio)
                        .font(.adaptiveBody())
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            // Stats
            if let stats = stats {
                HStack(spacing: 32) {
                    StatItem(value: stats.testsCompleted, label: "Tests")
                    StatItem(value: stats.coursesCompleted, label: "Courses")
                    StatItem(value: stats.achievementsEarned, label: "Achievements")
                }
                .padding(.top, 8)
            }
        }
        .padding()
    }
}

private struct StatItem: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.adaptiveTitle())
                .fontWeight(.semibold)
            
            Text(label)
                .font(.adaptiveCaption())
                .foregroundStyle(.secondary)
        }
    }
}

#if DEBUG
struct ProfileHeader_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHeader(
            profile: UserProfile(
                id: UUID(),
                firstName: "John",
                lastName: "Doe",
                email: "john@example.com",
                bio: "iOS Developer",
                createdAt: Date(),
                updatedAt: Date()
            ),
            stats: UserStats(
                testsCompleted: 10,
                coursesCompleted: 5,
                achievementsEarned: 15
            ),
            onEditTap: {}
        )
        .previewLayout(.sizeThatFits)
    }
}
#endif
