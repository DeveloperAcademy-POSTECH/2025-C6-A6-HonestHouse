//
//  ShootingSettingsService.swift
//  HonestHouse
//
//  Created by Subeen on 10/23/25.
//

import Foundation

protocol ShootingSettingsServiceType {
    func getShootingMode(with: VersionType) async throws -> ShootingSettings.ShootingModeResponse
    
    func getPictureStyle(with: VersionType) async throws -> ShootingSettings.PictureStyleResponse
    func putPictureStyle(with: VersionType, request: StringValueRequest) async throws -> ShootingSettings.PictureStyleResponse
}

final class ShootingSettingsService: BaseService, ShootingSettingsServiceType {
    
    func getShootingMode(with version: VersionType) async throws -> ShootingSettings.ShootingModeResponse {
        let response = try await requestWithRetry(ShootingSettingsTarget.getShootingMode, decoding: ShootingSettings.ShootingModeResponse.self)
        
        return response
    }
    
    func getPictureStyle(with version: VersionType) async throws -> ShootingSettings.PictureStyleResponse {
        let response = try await request(ShootingSettingsTarget.getPictureStyle, decoding: ShootingSettings.PictureStyleResponse.self)
        
        return response
    }
    
    func putPictureStyle(with version: VersionType, request: StringValueRequest) async throws -> ShootingSettings.PictureStyleResponse {
        let response = try await self.request(ShootingSettingsTarget.putPictureStyle(request), decoding: ShootingSettings.PictureStyleResponse.self)
        
        return response
    }
}
