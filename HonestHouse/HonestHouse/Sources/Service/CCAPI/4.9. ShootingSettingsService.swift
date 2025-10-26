//
//  ShootingSettingsService.swift
//  HonestHouse
//
//  Created by Subeen on 10/23/25.
//

import Foundation

protocol ShootingSettingsServiceType {
    func getShootingMode(with: VersionType) async throws -> ShootingSettings.ShootingModeResponse
}

final class ShootingSettingsService: BaseService, ShootingSettingsServiceType {
    
    func getShootingMode(with version: VersionType) async throws -> ShootingSettings.ShootingModeResponse {
        
        let response = try await requestWithRetry(ShootingSettingsTarget.getShootingMode, decoding: ShootingSettings.ShootingModeResponse.self)
        
        return response
    }
}
