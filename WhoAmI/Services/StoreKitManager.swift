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

struct ProductInfo: Codable {
    let id: String
    let price: Decimal
    let displayName: String
    let description: String
    
    init(from product: Product) {
        self.id = product.id
        self.price = product.price
        self.displayName = product.displayName
        self.description = product.description
    }
}

@MainActor
class StoreKitManager: BaseService {
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published var error: Error?
    
    private var updateListenerTask: Task<Void, Error>?
    private var productMap: [String: Product] = [:]
    
    override init(supabase: SupabaseClient) {
        super.init(supabase: supabase)
        setupCache(GenericCache())
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
        if let cached: [ProductInfo] = getCachedValue([ProductInfo].self, forKey: "subscription_info") {
            // Fetch fresh products but use cached info for faster display
            let products = try await Product.products(for: Set(cached.map { $0.id }))
            productMap = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })
            subscriptions = products.sorted { $0.price < $1.price }
            return
        }
        
        let products = try await Product.products(for: ["premium_monthly", "premium_yearly"])
        productMap = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })
        subscriptions = products.sorted { $0.price < $1.price }
        
        // Cache product info
        let productInfo = products.map { ProductInfo(from: $0) }
        setCachedValue(productInfo, forKey: "subscription_info")
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
        var purchased: [Product] = []
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            if let product = productMap[transaction.productID] {
                purchased.append(product)
            }
        }
        
        purchasedSubscriptions = purchased
        
        // Cache purchased product info
        let purchasedInfo = purchased.map { ProductInfo(from: $0) }
        setCachedValue(purchasedInfo, forKey: "purchased_subscription_info")
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
}
