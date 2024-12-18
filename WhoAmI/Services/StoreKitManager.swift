import Foundation
import StoreKit
import Supabase

enum StoreError: Error {
    case verificationFailed
    case purchaseFailed
    case subscriptionNotFound
    case invalidProduct
    case networkError
    case databaseError
}

class SubscriptionCache: CacheProtocol {
    private var cache = [String: Any]()
    private let lock = NSLock()
    
    public func get<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        lock.lock()
        defer { lock.unlock() }
        return cache[key] as? T
    }
    
    public func set<T: Codable>(_ value: T, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        cache[key] = value
    }
    
    public func remove(forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        cache.removeValue(forKey: key)
    }
    
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAll()
    }
}

@MainActor
class StoreKitManager: BaseService {
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published var error: Error?
    
    private let cache = SubscriptionCache()
    private var updateListenerTask: Task<Void, Error>?
    
    override init(supabase: SupabaseClient) {
        super.init(supabase: supabase)
        setupCache(cache)
        Task {
            await listenForTransactions()
        }
    }
    
    private func listenForTransactions() async {
        for await result in Transaction.updates {
            do {
                try await handleTransaction(result)
            } catch {
                self.error = error
            }
        }
    }
    
    private func handleTransaction(_ verificationResult: VerificationResult<Transaction>) async throws {
        guard case .verified(let transaction) = verificationResult else {
            throw StoreError.verificationFailed
        }
        
        // Handle transaction
        if transaction.revocationDate == nil {
            // Transaction is valid
            await transaction.finish()
            await refreshPurchasedSubscriptions()
        } else {
            // Subscription was refunded or revoked
            await refreshPurchasedSubscriptions()
        }
    }
    
    func fetchSubscriptions() async throws {
        let products = try await Product.products(for: ["premium_monthly", "premium_yearly"])
        subscriptions = products.sorted { $0.price < $1.price }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else {
                throw StoreError.verificationFailed
            }
            await transaction.finish()
            await refreshPurchasedSubscriptions()
            
        case .userCancelled:
            throw StoreError.purchaseFailed
            
        case .pending:
            break
            
        @unknown default:
            throw StoreError.purchaseFailed
        }
    }
    
    func refreshPurchasedSubscriptions() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                purchasedSubscriptions.append(subscription)
            }
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
}
