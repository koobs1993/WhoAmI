import Foundation

public struct WeeklyColumn: Codable, Identifiable {
    public let id: UUID
    public let title: String
    public let summary: String
    public let content: String
    public let authorId: UUID?
    public let featuredImageUrl: String?
    public let subtitle: String?
    public let author: String?
    public let shortDescription: String
    public let createdAt: Date?
    public let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case summary
        case content
        case authorId = "author_id"
        case featuredImageUrl = "featured_image_url"
        case subtitle
        case author
        case shortDescription = "short_description"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        id = UUID(uuidString: idString) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decode(String.self, forKey: .summary)
        content = try container.decode(String.self, forKey: .content)
        authorId = try container.decodeIfPresent(UUID.self, forKey: .authorId)
        featuredImageUrl = try container.decodeIfPresent(String.self, forKey: .featuredImageUrl)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        author = try container.decodeIfPresent(String.self, forKey: .author)
        shortDescription = try container.decodeIfPresent(String.self, forKey: .shortDescription) ?? summary
        
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt),
           let date = ISO8601DateFormatter().date(from: createdAtString) {
            createdAt = date
        } else {
            createdAt = nil
        }
        
        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt),
           let date = ISO8601DateFormatter().date(from: updatedAtString) {
            updatedAt = date
        } else {
            updatedAt = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(summary, forKey: .summary)
        try container.encode(content, forKey: .content)
        try container.encodeIfPresent(authorId, forKey: .authorId)
        try container.encodeIfPresent(featuredImageUrl, forKey: .featuredImageUrl)
        try container.encodeIfPresent(subtitle, forKey: .subtitle)
        try container.encodeIfPresent(author, forKey: .author)
        try container.encode(shortDescription, forKey: .shortDescription)
        
        let formatter = ISO8601DateFormatter()
        if let createdAt = createdAt {
            try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        }
        if let updatedAt = updatedAt {
            try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        }
    }
}

public struct WeeklyQuestion: Codable, Identifiable {
    public let id: UUID
    public let columnId: UUID
    public let questionText: String
    public let order: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: UUID = UUID(), columnId: UUID, questionText: String, order: Int, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.columnId = columnId
        self.questionText = questionText
        self.order = order
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case columnId = "column_id"
        case questionText = "question_text"
        case order
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct WeeklyResponse: Codable, Identifiable {
    public let id: UUID
    public let userId: UUID
    public let questionId: UUID
    public let response: String
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: UUID = UUID(), userId: UUID, questionId: UUID, response: String, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.questionId = questionId
        self.response = response
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case questionId = "question_id"
        case response
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct UserWeeklyProgress: Codable, Identifiable {
    public let id: UUID
    public let userId: UUID
    public let columnId: UUID
    public let lastQuestionId: UUID
    public let completed: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: UUID = UUID(), userId: UUID, columnId: UUID, lastQuestionId: UUID, completed: Bool, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.columnId = columnId
        self.lastQuestionId = lastQuestionId
        self.completed = completed
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case columnId = "column_id"
        case lastQuestionId = "last_question_id"
        case completed
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
