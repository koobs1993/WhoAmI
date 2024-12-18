import Foundation
import UserNotifications
import Supabase
#if os(iOS)
import UIKit
#endif

class PushNotificationHandler: NSObject {
    private let supabase: SupabaseClient
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(supabase: SupabaseClient) {
        self.supabase = supabase

        // Configure JSONEncoder
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
        
        // Configure JSONDecoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        super.init()
    }

    // ... (rest of your code)

    func registerDevice(token: String, userId: UUID) async throws {
        let device = UserDevice(
            id: UUID(),
            userId: userId,
            deviceToken: token,
            platform: "ios",
            deviceType: "mobile",
            isActive: true,
            lastActive: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )

        let jsonData = try encoder.encode(device)

        try await supabase.database
            .from("user_devices")
            .upsert(jsonData)
            .execute()
    }

    func getDevices(for userId: UUID) async throws -> [UserDevice] {
        let response: PostgrestResponse = try await supabase.database
            .from("user_devices")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
        
        let devices = try decoder.decode([UserDevice].self, from: response.data)
        return devices
    }
    
    // ... (rest of your code)
}