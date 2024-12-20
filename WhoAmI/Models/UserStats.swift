import Foundation

struct UserStats: Codable, Equatable {
    let testsCompleted: Int
    let coursesCompleted: Int
    let achievementsEarned: Int
    
    enum CodingKeys: String, CodingKey {
        case testsCompleted = "tests_completed"
        case coursesCompleted = "courses_completed"
        case achievementsEarned = "achievements_earned"
    }
    
    init(testsCompleted: Int = 0, coursesCompleted: Int = 0, achievementsEarned: Int = 0) {
        self.testsCompleted = testsCompleted
        self.coursesCompleted = coursesCompleted
        self.achievementsEarned = achievementsEarned
    }
}

extension UserStats {
    static let empty = UserStats()
    
    #if DEBUG
    static let preview = UserStats(
        testsCompleted: 10,
        coursesCompleted: 5,
        achievementsEarned: 15
    )
    #endif
}
