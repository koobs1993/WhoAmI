import Foundation
import StoreKit
import Supabase

enum AuthenticationError: Error {
    case notAuthenticated
}

struct PurchaseRecord: Codable {
    let transactionId: String
    let productId: String
    let userId: String
    let purchaseDate: Date
    let quantity: Int
    
    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case productId = "product_id"
        case userId = "user_id"
        case purchaseDate = "purchase_date"
        case quantity
    }
}

@MainActor
class StoreKitManager: BaseService, @unchecked Sendable {
    static let shared: StoreKitManager = {
        return StoreKitManager(supabase: Config.supabaseClient)
    }()
    
    private let cache = NSCache<NSString, CacheEntry<[SubscriptionStatus]>>()
    private let cacheDuration: TimeInterval = 300 // 5 minutes
    
    private override init(supabase: SupabaseClient) {
        super.init(supabase: supabase)
        Task { @MainActor in
            setupCache(cache)
            await listenForTransactions()
        }
    }
    
    private func listenForTransactions() async {
        for await transaction in Transaction.updates {
            do {
                try await handleTransaction(transaction)
            } catch {
                print("Failed to handle transaction: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleTransaction(_ verificationResult: VerificationResult<Transaction>) async throws {
        guard case .verified(let transaction) = verificationResult else {
            throw StoreError.verificationFailed
        }

        let session = try await supabase.auth.session
        let status: SubscriptionStatus = transaction.revocationDate == nil ? .active : .canceled
        
        struct SubscriptionRecord: Codable {
            let userId: String
            let productId: String
            let originalTransactionId: String
            let webOrderLineItemId: String?
            let purchaseDate: Date
            let expirationDate: Date?
            let status: String
            
            enum CodingKeys: String, CodingKey {
                case userId = "user_id"
                case productId = "product_id"
                case originalTransactionId = "original_transaction_id"
                case webOrderLineItemId = "web_order_line_item_id"
                case purchaseDate = "purchase_date"
                case expirationDate = "expiration_date"
                case status
            }
        }
        
        let record = SubscriptionRecord(
            userId: session.user.id.uuidString,
            productId: transaction.productID,
            originalTransactionId: String(transaction.originalID),
            webOrderLineItemId: transaction.webOrderLineItemID,
            purchaseDate: transaction.purchaseDate,
            expirationDate: transaction.expirationDate,
            status: status.rawValue
        )
        
        try await supabase.database
            .from("subscriptions")
            .upsert(values: record)
            .execute()
        
        let purchase = PurchaseRecord(
            transactionId: String(transaction.id),
            productId: transaction.productID,
            userId: session.user.id.uuidString,
            purchaseDate: transaction.purchaseDate,
            quantity: 1
        )
        
        try await supabase.database
            .from("purchases")
            .insert(values: purchase)
            .execute()
    }
    
    func recordPurchase(_ transaction: Transaction) async throws {
        guard let session = try? await supabase.auth.session else {
            throw AuthenticationError.notAuthenticated
        }
        
        let record = PurchaseRecord(
            transactionId: String(transaction.id),
            productId: transaction.productID,
            userId: session.user.id.uuidString,
            purchaseDate: transaction.purchaseDate,
            quantity: 1
        )
        
        try await supabase.database
            .from("purchases")
            .insert(values: record)
            .execute()
    }
}

enum StoreKitError: LocalizedError, Sendable {
    case verificationFailed
    case purchaseFailed
    case userCancelled
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "Transaction verification failed"
        case .purchaseFailed:
            return "Purchase failed"
        case .userCancelled:
            return "Purchase was cancelled"
        case .networkError:
            return "Network error occurred"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 