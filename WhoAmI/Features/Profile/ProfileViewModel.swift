import Foundation
import Supabase
import StoreKit

@MainActor
class ProfileViewModel: ObservableObject, @unchecked Sendable {
    private let supabase: SupabaseClient
    private var userId: UUID?
    
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var deviceSettings: UserDeviceSettings?
    @Published var privacySettings: UserPrivacySettings?
    @Published var stats: UserStats?
    @Published var isEditing = false
    @Published var profileImage: NSImage?
    @Published var profileImageUrl: String?
    
    // Form fields
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
        Task {
            await fetchCurrentUser()
        }
    }
    
    func fetchCurrentUser() async {
        isLoading = true
        do {
            let user = try await supabase.auth.session.user
            self.userId = user.id
            await fetchProfile()
            await fetchPrivacySettings()
            await fetchStats()
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func fetchProfile() async {
        guard let userId = userId else { return }
        do {
            let query = supabase.database
                .from("user_profiles")
                .select()
                .eq(column: "user_id", value: userId.uuidString)
                .single()
            
            self.profile = try await query.execute().value
        } catch {
            self.error = error
        }
    }
    
    func fetchPrivacySettings() async {
        guard let userId = userId else { return }
        do {
            let query = supabase.database
                .from("user_privacy_settings")
                .select()
                .eq(column: "user_id", value: userId.uuidString)
                .single()
            
            self.privacySettings = try await query.execute().value
        } catch {
            self.error = error
        }
    }
    
    func fetchStats() async {
        guard let userId = userId else { return }
        do {
            let query = supabase.database
                .from("user_stats")
                .select()
                .eq(column: "user_id", value: userId.uuidString)
                .single()
            
            self.stats = try await query.execute().value
        } catch {
            self.error = error
        }
    }
    
    func updateProfile(_ updatedProfile: UserProfile) async throws {
        guard let userId = userId else { throw ProfileError.userNotFound }
        
        try await supabase.database
            .from("user_profiles")
            .update(values: updatedProfile)
            .eq(column: "user_id", value: userId.uuidString)
            .execute()
        
        self.profile = updatedProfile
    }
    
    func updatePrivacySettings(_ settings: UserPrivacySettings) async throws {
        guard let userId = userId else { throw ProfileError.userNotFound }
        
        try await supabase.database
            .from("user_privacy_settings")
            .update(values: settings)
            .eq(column: "user_id", value: userId.uuidString)
            .execute()
        
        self.privacySettings = settings
    }
    
    func uploadProfileImage(_ imageData: Data) async throws {
        if userId == nil { throw ProfileError.userNotFound }
        
        let path = "\(UUID().uuidString).jpg"
        let file = File(
            name: path,
            data: imageData,
            fileName: path,
            contentType: "image/jpeg"
        )
        
        let bucket = supabase.storage.from(id: "avatars")
        
        // Upload file
        _ = try await bucket.upload(
            path: path,
            file: file,
            fileOptions: FileOptions(cacheControl: "3600")
        )
        
        // Get public URL
        let publicURL = try bucket.getPublicURL(path: path)
        
        // Update profile with new avatar URL
        if let profile = profile {
            let updatedProfile = UserProfile(
                id: profile.id,
                userId: profile.userId,
                firstName: profile.firstName,
                lastName: profile.lastName,
                email: profile.email,
                gender: profile.gender,
                role: profile.role,
                avatarUrl: publicURL.absoluteString,
                bio: profile.bio,
                phone: profile.phone,
                isActive: profile.isActive,
                emailConfirmedAt: profile.emailConfirmedAt,
                createdAt: profile.createdAt,
                updatedAt: Date()
            )
            try await updateProfile(updatedProfile)
        }
    }
    
    // MARK: - StoreKit Methods
    
    func handlePurchase(for duration: SubscriptionDuration) async throws -> StoreKit.Product {
        let product = try await fetchProduct(for: duration)
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateSubscription(transaction: transaction, product: product)
            await transaction.finish()
            return product
            
        case .userCancelled:
            throw StoreError.userCancelled
        case .pending:
            throw StoreError.verificationFailed
        @unknown default:
            throw StoreError.verificationFailed
        }
    }
    
    private func fetchProduct(for duration: SubscriptionDuration) async throws -> StoreKit.Product {
        let products = try await StoreKit.Product.products(for: [duration.productId])
        guard let product = products.first else {
            throw StoreError.productNotFound
        }
        return product
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    private func updateSubscription(transaction: StoreKit.Transaction, product: StoreKit.Product) async {
        guard let userId = userId else { return }
        
        let record = SubscriptionRecord(
            userId: userId,
            productId: product.id,
            originalTransactionId: UInt64(transaction.originalID),
            webOrderLineItemId: UInt64(transaction.webOrderLineItemID ?? "0"),
            purchaseDate: transaction.purchaseDate,
            expirationDate: transaction.expirationDate,
            status: "active"
        )
        
        do {
            try await supabase.database
                .from("subscriptions")
                .upsert(values: record)
                .execute()
        } catch {
            print("Failed to update subscription in database:", error)
        }
    }
    
    @MainActor
    func saveProfile() async throws {
        guard let userId = userId else { throw ProfileError.userNotFound }
        
        struct ProfileUpdate: Codable {
            let profileImageUrl: String?
            let updatedAt: String
            
            enum CodingKeys: String, CodingKey {
                case profileImageUrl = "profile_image_url"
                case updatedAt = "updated_at"
            }
        }
        
        let update = ProfileUpdate(
            profileImageUrl: profileImageUrl,
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
        
        try await supabase.database
            .from("user_profiles")
            .update(values: update)
            .eq(column: "user_id", value: userId.uuidString)
            .execute()
    }
    
    @MainActor
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            self.profile = nil
            self.deviceSettings = nil
            self.privacySettings = nil
            self.stats = nil
        } catch {
            self.error = error
        }
    }
}

// MARK: - Supporting Types

enum ProfileError: LocalizedError, Sendable {
    case userNotFound
    case invalidImageData
    case uploadFailed
    case updateFailed
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .invalidImageData:
            return "Invalid image data"
        case .uploadFailed:
            return "Failed to upload image"
        case .updateFailed:
            return "Failed to update profile"
        }
    }
}

struct SubscriptionRecord: Codable, Sendable {
    let userId: UUID
    let productId: String
    let originalTransactionId: UInt64?
    let webOrderLineItemId: UInt64?
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

enum ProfileStoreError: LocalizedError, Sendable {
    case verificationFailed
    case purchaseFailed
    case userCancelled
    case networkError
    case unknown
    case productNotFound
    case verification
    
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
        case .productNotFound:
            return "Product not found"
        case .verification:
            return "Transaction verification pending"
        }
    }
} 