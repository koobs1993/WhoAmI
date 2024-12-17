import Foundation
import Supabase
import StoreKit
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    private let supabase: SupabaseClient
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var deviceSettings: UserDevicePreferences?
    @Published var privacySettings: UserPrivacySettings?
    @Published var stats: UserStats?
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func loadProfile() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: PostgrestResponse<[String: Any]> = try await supabase.database
                .from("users")
                .select(columns: """
                    *,
                    privacy_settings (*),
                    userdevicesettings (*)
                """)
                .eq(column: "id", value: try await supabase.auth.session.user.id.uuidString)
                .single()
                .execute()
            
            if let data = response.data {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                profile = try decoder.decode(UserProfile.self, from: jsonData)
            }
            
            try await loadDeviceSettings()
            try await loadPrivacySettings()
            try await loadStats()
        } catch {
            self.error = error
            throw error
        }
    }
    
    func updateProfile(firstName: String, lastName: String, bio: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let userId = try await supabase.auth.session.user.id.uuidString
        try await supabase.database
            .from("users")
            .update(values: [
                "first_name": firstName,
                "last_name": lastName,
                "bio": bio
            ] as [String: Any])
            .eq(column: "id", value: userId)
            .execute()
        
        try await loadProfile()
    }
    
    func deleteAccount() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let userId = try await supabase.auth.session.user.id.uuidString
        
        // Update user data to anonymized version
        try await supabase.database
            .from("users")
            .update(values: [
                "email": "deleted_\(UUID().uuidString)",
                "first_name": "Deleted",
                "last_name": "User",
                "profile_image": nil,
                "bio": nil
            ] as [String: Any])
            .eq(column: "id", value: userId)
            .execute()
        
        try await supabase.auth.signOut()
    }
    
    func sendVerificationEmail() async throws {
        guard let email = profile?.email else { return }
        try await supabase.auth.resetPasswordForEmail(email)
    }
    
    func updatePassword(to newPassword: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await supabase.auth.update(user: .init(password: newPassword))
    }
    
    func updateEmail(to newEmail: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await supabase.auth.update(user: .init(email: newEmail))
        try await loadProfile()
    }
    
    func uploadProfileImage(_ imageData: Data) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let path = "\(UUID().uuidString).jpg"
        
        let file = File(
            name: path,
            data: imageData,
            fileName: path,
            contentType: "image/jpeg"
        )
        
        // Get storage bucket
        let bucket = try await supabase.storage.from(id: "avatars")
        
        // Upload file
        try await bucket.upload(
            path: path,
            file: file,
            fileOptions: FileOptions(cacheControl: "3600")
        )
        
        // Get public URL
        let publicURL = try await bucket.getPublicURL(path: path)
        
        let userId = try await supabase.auth.session.user.id.uuidString
        try await supabase.database
            .from("users")
            .update(values: [
                "profile_image": publicURL.absoluteString
            ] as [String: Any])
            .eq(column: "id", value: userId)
            .execute()
        
        try await loadProfile()
    }
    
    func updateDeviceSettings(_ settings: UserDevicePreferences) async throws {
        let userId = try await supabase.auth.session.user.id.uuidString
        try await supabase.database
            .from("userdevicesettings")
            .upsert(values: [
                "user_id": userId,
                "notifications_enabled": settings.notificationsEnabled,
                "theme": settings.theme,
                "language": settings.language,
                "course_updates_enabled": settings.courseUpdatesEnabled,
                "test_reminders_enabled": settings.testRemindersEnabled,
                "weekly_summaries_enabled": settings.weeklySummariesEnabled,
                "analytics_enabled": settings.analyticsEnabled,
                "tracking_authorized": settings.trackingAuthorized,
                "dark_mode_enabled": settings.darkModeEnabled,
                "haptics_enabled": settings.hapticsEnabled
            ] as [String: Any])
            .execute()
        
        try await loadDeviceSettings()
    }
    
    func updatePrivacySettings(showProfile: Bool, allowMessages: Bool) async throws {
        let userId = try await supabase.auth.session.user.id.uuidString
        try await supabase.database
            .from("privacy_settings")
            .upsert(values: [
                "user_id": userId,
                "show_profile": showProfile,
                "allow_messages": allowMessages
            ] as [String: Any])
            .execute()
        
        try await loadPrivacySettings()
    }
    
    private func loadDeviceSettings() async throws {
        let userId = try await supabase.auth.session.user.id.uuidString
        let response: PostgrestResponse<[String: Any]> = try await supabase.database
            .from("userdevicesettings")
            .select()
            .eq(column: "user_id", value: userId)
            .single()
            .execute()
        
        if let data = response.data {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            deviceSettings = try decoder.decode(UserDevicePreferences.self, from: jsonData)
        }
    }
    
    private func loadPrivacySettings() async throws {
        let userId = try await supabase.auth.session.user.id.uuidString
        let response: PostgrestResponse<[String: Any]> = try await supabase.database
            .from("privacy_settings")
            .select()
            .eq(column: "user_id", value: userId)
            .single()
            .execute()
        
        if let data = response.data {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            privacySettings = try decoder.decode(UserPrivacySettings.self, from: jsonData)
        }
    }
    
    private func loadStats() async throws {
        let userId = try await supabase.auth.session.user.id.uuidString
        
        // Fetch user courses
        let coursesResponse: PostgrestResponse<[[String: Any]]> = try await supabase.database
            .from("usercourses")
            .select()
            .eq(column: "user_id", value: userId)
            .execute()
        
        let coursesCount = coursesResponse.data?.count ?? 0
        
        // Fetch user tests
        let testsResponse: PostgrestResponse<[[String: Any]]> = try await supabase.database
            .from("usertests")
            .select()
            .eq(column: "user_id", value: userId)
            .execute()
        
        let testsCount = testsResponse.data?.count ?? 0
        
        // Fetch chat sessions
        let chatsResponse: PostgrestResponse<[[String: Any]]> = try await supabase.database
            .from("chatsessions")
            .select()
            .eq(column: "user_id", value: userId)
            .execute()
        
        let chatsCount = chatsResponse.data?.count ?? 0
        
        stats = UserStats(
            userId: UUID(uuidString: userId),
            coursesCompleted: coursesCount,
            testsCompleted: testsCount,
            chatSessionsCount: chatsCount,
            weeklyColumnsRead: 0,
            totalTimeSpent: 0,
            lastActive: Date()
        )
    }
    
    func purchase(_ product: StoreKit.Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase(options: [])
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            // Update subscription in database
            if let transaction = transaction {
                let userId = try await supabase.auth.session.user.id.uuidString
                let dateFormatter = ISO8601DateFormatter()
                try await supabase.database
                    .from("subscriptions")
                    .upsert(values: [
                        "user_id": userId,
                        "product_id": product.id,
                        "transaction_id": String(transaction.id),
                        "purchase_date": dateFormatter.string(from: transaction.purchaseDate),
                        "expires_date": transaction.expirationDate.map { dateFormatter.string(from: $0) },
                        "status": "active"
                    ] as [String: Any])
                    .execute()
            }
            
            return transaction
            
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verification
        case .verified(let verified):
            return verified
        }
    }
    
    func getProduct(for duration: SubscriptionDuration) async throws -> StoreKit.Product {
        let products = try await StoreKit.Product.products(for: [duration.productId])
        guard let product = products.first else {
            throw StoreError.verification
        }
        return product
    }
} 