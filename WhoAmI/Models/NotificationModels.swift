import Foundation
import SwiftUI

public struct UserNotification: Identifiable, Codable {
    public let id: UUID
    public let userId: UUID
    public let type: NotificationType
    public let title: String
    public let message: String
    public let metadata: [String: String]?
    public let read: Bool
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        type: NotificationType,
        title: String,
        message: String,
        metadata: [String: String]? = nil,
        read: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.message = message
        self.metadata = metadata
        self.read = read
        self.createdAt = createdAt
    }
}

public enum NotificationType: String, Codable {
    case system
    case course
    case message
    case achievement
    case warning
    case success
    case error
    case info
    case courseUpdate = "course_update"
    case testReminder = "test_reminder"
    
    public var icon: String {
        switch self {
        case .system:
            return "gear"
        case .course, .courseUpdate:
            return "book.fill"
        case .message:
            return "message.fill"
        case .achievement:
            return "star.fill"
        case .warning:
            return "exclamationmark.triangle"
        case .success:
            return "checkmark.circle"
        case .error:
            return "xmark.circle"
        case .info:
            return "info.circle"
        case .testReminder:
            return "bell.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .system:
            return .gray
        case .course, .courseUpdate:
            return .blue
        case .message:
            return .green
        case .achievement:
            return .yellow
        case .warning:
            return .orange
        case .success:
            return .green
        case .error:
            return .red
        case .info:
            return .blue
        case .testReminder:
            return .purple
        }
    }
}
