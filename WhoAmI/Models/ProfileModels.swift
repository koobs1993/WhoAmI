import Foundation

// MARK: - Profile-specific models
struct Subscription: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let productId: String
    let status: String
    let purchaseDate: Date
    let expirationDate: Date?
    let transactionId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case productId = "product_id"
        case status
        case purchaseDate = "purchase_date"
        case expirationDate = "expiration_date"
        case transactionId = "transaction_id"
    }
}