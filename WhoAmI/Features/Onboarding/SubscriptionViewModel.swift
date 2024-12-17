import Foundation
import StoreKit

enum SubscriptionError: Error {
    case verificationFailed
    case purchaseFailed
}

@MainActor
class SubscriptionViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var isLoading = false
    @Published var error: Error?
    
    private let productIdentifiers = [
        "com.whoami.subscription.monthly",
        "com.whoami.subscription.yearly"
    ]
    
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            products = try await Product.products(for: productIdentifiers)
        } catch {
            self.error = error
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            if let transaction = transaction {
                await updatePurchasedProducts(transaction)
            }
            return transaction
            
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T? {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    private func updatePurchasedProducts(_ transaction: Transaction) async {
        purchasedProductIDs.insert(transaction.productID)
    }
} 