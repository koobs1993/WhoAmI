import Foundation
import Supabase

@MainActor
class UserDeviceViewModel: ObservableObject {
    private let supabase: SupabaseClient
    private let userId: UUID
    
    @Published var devices: [UserDevice] = []
    @Published var error: Error?
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var isLoading = false
    
    init(supabase: SupabaseClient, userId: UUID) {
        self.supabase = supabase
        self.userId = userId
    }
    
    func loadDevices() async {
        isLoading = true
        do {
            let response: PostgrestResponse<[UserDevice]> = try await supabase
                .from("user_devices")
                .select()
                .eq("user_id", value: userId)
                .execute()
            
            devices = response.value
            isLoading = false
        } catch {
            self.error = error
            self.errorMessage = error.localizedDescription
            self.showError = true
            isLoading = false
        }
    }
    
    func removeDevice(_ device: UserDevice) async {
        do {
            try await supabase
                .from("user_devices")
                .delete()
                .eq("device_id", value: device.id)
                .execute()
            
            // Remove from local array
            devices.removeAll { $0.id == device.id }
        } catch {
            self.error = error
        }
    }
    
    func updateDeviceSettings(_ device: UserDevice, settings: DeviceSettings) async {
        do {
            try await supabase
                .from("user_devices")
                .update(["settings": settings])
                .eq("device_id", value: device.id)
                .execute()
            
            // Update local array
            if let index = devices.firstIndex(where: { $0.id == device.id }) {
                devices[index] = UserDevice(
                    id: device.id,
                    userId: device.userId,
                    name: device.name,
                    platform: device.platform,
                    osVersion: device.osVersion,
                    appVersion: device.appVersion,
                    lastActive: device.lastActive,
                    pushToken: device.pushToken,
                    settings: settings
                )
            }
        } catch {
            self.error = error
        }
    }
}
