import StoreKit
import Supabase
import Foundation

@MainActor
class StoreKitManager: BaseService {
    static let shared = StoreKitManager()
    private let cache = NSCache<NSString, CacheEntry<[SubscriptionStatus]>>()
    private let cacheDuration: TimeInterval = 300 // 5 minutes
    
    override private init() {
        super.init()
        setupCache(cache)
        // Start listening for transactions
        Task {
            await observeTransactions()
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateSubscriptionStatus(transaction: transaction)
            await transaction.finish()
            return transaction
            
        case .userCancelled:
            return nil
            
        case .pending:
            throw StoreError.pending
            
        @unknown default:
            throw StoreError.unknown
        }
    }
    
    private func observeTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                await updateSubscriptionStatus(transaction: transaction)
                await transaction.finish()
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
    }
    
    private func updateSubscriptionStatus(transaction: Transaction) async {
        do {
            let status: SubscriptionStatus = transaction.revocationDate == nil ? .active : .canceled
            
            try await upsert(into: "subscriptions", values: [
                "user_id": supabase.auth.session?.user.id ?? "",
                "product_id": transaction.productID,
                "status": status.rawValue,
                "original_transaction_id": transaction.originalID,
                "purchase_date": transaction.purchaseDate,
                "expires_date": transaction.expirationDate,
                "is_trial_period": false,
                "is_in_intro_offer_period": false
            ])
            
            // Update UserDefaults
            UserDefaults.standard.set(status == .active, forKey: "isSubscribed")
            
            // Invalidate cache
            invalidateCache()
            
        } catch {
            print("Error updating subscription status: \(error)")
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verification
        case .verified(let safe):
            return safe
        }
    }
    
    func restorePurchases() async throws {
        try await AppStore.sync()
    }
    
    func recordPurchase(_ transaction: Transaction) async throws {
        try await insert(into: "purchases", values: [
            "transaction_id": transaction.id,
            "product_id": transaction.productID,
            "user_id": supabase.auth.session?.user.id ?? "",
            "purchase_date": transaction.purchaseDate,
            "quantity": transaction.quantity
        ])
    }
    
    private func invalidateCache() {
        cache.removeObject(forKey: "subscription_status" as NSString)
    }
}

enum StoreError: LocalizedError {
    case pending
    case verification
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .pending:
            return "Purchase is pending"
        case .verification:
            return "Purchase verification failed"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 