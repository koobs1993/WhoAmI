import Foundation

// Use shared UserDeviceSettings and UserPrivacySettings from SharedModels.swift
typealias UserSettings = UserDeviceSettings
typealias PrivacySettings = UserPrivacySettings

// MARK: - Settings Service Models
struct SettingsResponse: Codable {
    let deviceSettings: UserDeviceSettings
    let privacySettings: UserPrivacySettings
    
    enum CodingKeys: String, CodingKey {
        case deviceSettings = "device_settings"
        case privacySettings = "privacy_settings"
    }
}

// MARK: - Settings Update Models
struct SettingsUpdateRequest: Codable {
    let deviceSettings: UserDeviceSettings?
    let privacySettings: UserPrivacySettings?
    
    enum CodingKeys: String, CodingKey {
        case deviceSettings = "device_settings"
        case privacySettings = "privacy_settings"
    }
} 