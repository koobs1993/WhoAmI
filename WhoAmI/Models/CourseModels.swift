import Foundation

public struct Course: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let imageUrl: String?
    public let difficulty: String
    public let category: String
    public let estimatedDuration: Int?
    public let createdAt: Date
    public let updatedAt: Date
    public var lessons: [Lesson]?
    public var sections: [CourseSection]?
    public var metadata: [String: AnyCodable]?
    
    private enum CodingKeys: String, CodingKey {
        case id = "course_id"
        case title
        case description
        case imageUrl = "image_url"
        case difficulty
        case category
        case estimatedDuration = "estimated_duration"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lessons
        case sections
        case metadata
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        imageUrl: String? = nil,
        difficulty: String,
        category: String,
        estimatedDuration: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lessons: [Lesson]? = nil,
        sections: [CourseSection]? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.difficulty = difficulty
        self.category = category
        self.estimatedDuration = estimatedDuration
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lessons = lessons
        self.sections = sections
        self.metadata = metadata?.mapValues { AnyCodable($0) }
    }
    
    public static var preview: Course {
        Course(
            id: UUID(),
            title: "Understanding Yourself",
            description: "Learn about personality types and self-discovery",
            imageUrl: "https://example.com/course-image.jpg",
            difficulty: "intermediate",
            category: "Psychology",
            estimatedDuration: 120,
            lessons: [
                Lesson(
                    courseId: UUID(),
                    title: "Introduction to Personality Types",
                    description: "Learn about different personality frameworks",
                    content: "Lesson content here...",
                    duration: 30,
                    order: 1
                ),
                Lesson(
                    courseId: UUID(),
                    title: "Self-Discovery Exercises",
                    description: "Practical exercises for self-understanding",
                    content: "Lesson content here...",
                    duration: 45,
                    order: 2
                )
            ],
            sections: [
                CourseSection(
                    title: "Fundamentals",
                    description: "Core concepts of personality psychology",
                    order: 1
                ),
                CourseSection(
                    title: "Advanced Topics",
                    description: "Deep dive into personality analysis",
                    order: 2
                )
            ]
        )
    }
}

public struct CourseSection: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let order: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id = "section_id"
        case title
        case description
        case order
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        order: Int,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.order = order
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum LessonStatus: String, Codable, CaseIterable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case completed = "completed"
}

public struct Lesson: Identifiable, Codable {
    public let id: UUID
    public let courseId: UUID
    public let title: String
    public let description: String?
    public let content: String
    public let duration: Int?
    public let order: Int
    public var status: LessonStatus?
    public let createdAt: Date
    public let updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case courseId = "course_id"
        case title
        case description
        case content
        case duration
        case order
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(
        id: UUID = UUID(),
        courseId: UUID,
        title: String,
        description: String? = nil,
        content: String,
        duration: Int? = nil,
        order: Int,
        status: LessonStatus? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.courseId = courseId
        self.title = title
        self.description = description
        self.content = content
        self.duration = duration
        self.order = order
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum CourseDifficulty: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced
    
    public var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
}

// Helper type to handle Any in Codable
public struct AnyCodable: Codable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded")
            throw EncodingError.invalidValue(value, context)
        }
    }
}

// Extension to help with type casting
extension AnyCodable {
    public var stringValue: String? {
        value as? String
    }
    
    public var intValue: Int? {
        value as? Int
    }
    
    public var doubleValue: Double? {
        value as? Double
    }
    
    public var boolValue: Bool? {
        value as? Bool
    }
    
    public var arrayValue: [Any]? {
        value as? [Any]
    }
    
    public var stringArrayValue: [String]? {
        arrayValue as? [String]
    }
    
    public var dictionaryValue: [String: Any]? {
        value as? [String: Any]
    }
}
