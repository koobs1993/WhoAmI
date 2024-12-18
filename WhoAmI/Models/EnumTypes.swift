import Foundation

public enum Gender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    case other = "other"
    case preferNotToSay = "prefer_not_to_say"
}

public enum UserRole: String, Codable, CaseIterable {
    case student = "student"
    case professional = "professional"
    case researcher = "researcher"
    case other = "other"
}

public enum CourseStatus: String, Codable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case completed = "completed"
    case abandoned = "abandoned"
}

public enum ServiceError: Error {
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse
    case unauthorized
    case notFound
    case serverError
    case unknown
}
