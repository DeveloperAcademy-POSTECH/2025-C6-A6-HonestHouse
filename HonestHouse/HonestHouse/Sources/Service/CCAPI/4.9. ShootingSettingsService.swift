//
//  ShootingSettingsService.swift
//  HonestHouse
//
//  Created by Subeen on 10/23/25.
//

import Foundation

protocol ShootingSettingsServiceType {
    /// 촬영 모드
    func getShootingMode(with: VersionType) async throws -> ShootingSettings.ShootingModeResponse
    func putShootingMode(with: VersionType, request: ShootingSettings.ShootingModeRequest) async throws -> ShootingSettings.ShootingModeResponse
    func getShootingModeDial(with: VersionType) async throws -> ShootingSettings.ShootingModeResponse
    func putShootingModeDial(with: VersionType, request: ShootingSettings.ShootingModeRequest) async throws -> ShootingSettings.ShootingModeResponse
    /// 조리개
    func getAV(with: VersionType) async throws -> ShootingSettings.AVResponse
    func putAV(with: VersionType, request: ShootingSettings.AVRequest) async throws -> ShootingSettings.AVResponse
    /// 셔터스피드
    func getTV(with: VersionType) async throws -> ShootingSettings.TVResponse
    func putTV(with: VersionType, request: ShootingSettings.TVRequest) async throws -> ShootingSettings.TVResponse
    /// ISO
    func getISO(with: VersionType) async throws -> ShootingSettings.ISOResponse
    func putISO(with: VersionType, request: ShootingSettings.ISORequest) async throws -> ShootingSettings.ISOResponse
    /// 노출 보정
    func getExposureCompensation(with: VersionType) async throws -> ShootingSettings.ExposureCompensationResponse
    func putExposureCompensation(with: VersionType, request: ShootingSettings.ExposureCompensationRequest) async throws -> ShootingSettings.ExposureCompensationResponse
    /// 화이트 밸런스
    func getWhiteBalance(with: VersionType) async throws -> ShootingSettings.WhiteBalanceResponse
    func putWhiteBalance(with: VersionType, request: ShootingSettings.WhiteBalanceRequest) async throws -> ShootingSettings.WhiteBalanceResponse
    /// 색온도
    func getColorTemperature(with: VersionType) async throws -> ShootingSettings.ColorTemperatureResponse
    func putColorTemperature(with: VersionType, request: ShootingSettings.ColorTemperatureRequest) async throws -> ShootingSettings.ColorTemperatureResponse
    /// 화이트 밸런스 쉬프트(틴트)
    func getWbShift(with: VersionType) async throws -> ShootingSettings.WBShiftResponse
    func putWbShift(with: VersionType, request: ShootingSettings.WBShiftRequest) async throws -> ShootingSettings.WBShiftResponse
    /// 픽쳐스타일
    func getPictureStyle(with: VersionType) async throws -> ShootingSettings.PictureStyleResponse
    func putPictureStyle(with: VersionType, request: ShootingSettings.PictureStyleRequest) async throws -> ShootingSettings.PictureStyleResponse
}

final class ShootingSettingsService: BaseService, ShootingSettingsServiceType {
    func getShootingMode(with version: VersionType) async throws -> ShootingSettings.ShootingModeResponse {
        let response = try await request(ShootingSettingsTarget.getShootingMode, decoding: ShootingSettings.ShootingModeResponse.self)
        
        return response
    }

    func putShootingMode(with version: VersionType, request: ShootingSettings.ShootingModeRequest) async throws -> ShootingSettings.ShootingModeResponse {
        let response = try await self.request(ShootingSettingsTarget.putShootingMode(request), decoding: ShootingSettings.ShootingModeResponse.self)
        return response
    }
    
    func getShootingModeDial(with: VersionType) async throws -> ShootingSettings.ShootingModeResponse {
        let response = try await request(ShootingSettingsTarget.getShootingModeDial, decoding: ShootingSettings.ShootingModeResponse.self)
        return response
    }
    
    func putShootingModeDial(with: VersionType, request: ShootingSettings.ShootingModeRequest) async throws -> ShootingSettings.ShootingModeResponse {
        let response = try await self.request(ShootingSettingsTarget.putShootingModeDial(request), decoding: ShootingSettings.ShootingModeResponse.self)
        return response
    }

    func getAV(with version: VersionType) async throws -> ShootingSettings.AVResponse {
        let response = try await request(ShootingSettingsTarget.getAv, decoding: ShootingSettings.AVResponse.self)
        return response
    }

    func putAV(with version: VersionType, request: ShootingSettings.AVRequest) async throws -> ShootingSettings.AVResponse {
        let response = try await self.request(ShootingSettingsTarget.putAv(request), decoding: ShootingSettings.AVResponse.self)
        return response
    }

    func getTV(with version: VersionType) async throws -> ShootingSettings.TVResponse {
        let response = try await request(ShootingSettingsTarget.getTv, decoding: ShootingSettings.TVResponse.self)
        return response
    }

    func putTV(with version: VersionType, request: ShootingSettings.TVRequest) async throws -> ShootingSettings.TVResponse {
        let response = try await self.request(ShootingSettingsTarget.putTv(request), decoding: ShootingSettings.TVResponse.self)
        return response
    }

    func getISO(with version: VersionType) async throws -> ShootingSettings.ISOResponse {
        let response = try await request(ShootingSettingsTarget.getIso, decoding: ShootingSettings.ISOResponse.self)
        return response
    }

    func putISO(with version: VersionType, request: ShootingSettings.ISORequest) async throws -> ShootingSettings.ISOResponse {
        let response = try await self.request(ShootingSettingsTarget.putIso(request), decoding: ShootingSettings.ISOResponse.self)
        return response
    }

    func getExposureCompensation(with version: VersionType) async throws -> ShootingSettings.ExposureCompensationResponse {
        let response = try await request(ShootingSettingsTarget.getExposureCompensation, decoding: ShootingSettings.ExposureCompensationResponse.self)
        return response
    }

    func putExposureCompensation(with version: VersionType, request: ShootingSettings.ExposureCompensationRequest) async throws -> ShootingSettings.ExposureCompensationResponse {
        let response = try await self.request(ShootingSettingsTarget.putExposureCompensation(request), decoding: ShootingSettings.ExposureCompensationResponse.self)
        return response
    }

    func getWhiteBalance(with version: VersionType) async throws -> ShootingSettings.WhiteBalanceResponse {
        let response = try await request(ShootingSettingsTarget.getWhiteBalance, decoding: ShootingSettings.WhiteBalanceResponse.self)
        return response
    }

    func putWhiteBalance(with version: VersionType, request: ShootingSettings.WhiteBalanceRequest) async throws -> ShootingSettings.WhiteBalanceResponse {
        let response = try await self.request(ShootingSettingsTarget.putWhiteBalance(request), decoding: ShootingSettings.WhiteBalanceResponse.self)
        return response
    }

    func getColorTemperature(with version: VersionType) async throws -> ShootingSettings.ColorTemperatureResponse {
        let response = try await request(ShootingSettingsTarget.getColorTemperature, decoding: ShootingSettings.ColorTemperatureResponse.self)
        return response
    }

    func putColorTemperature(with version: VersionType, request: ShootingSettings.ColorTemperatureRequest) async throws -> ShootingSettings.ColorTemperatureResponse {
        let response = try await self.request(ShootingSettingsTarget.putColorTemperature(request), decoding: ShootingSettings.ColorTemperatureResponse.self)
        return response
    }

    func getWbShift(with version: VersionType) async throws -> ShootingSettings.WBShiftResponse {
        let response = try await request(ShootingSettingsTarget.getWbShift, decoding: ShootingSettings.WBShiftResponse.self)
        return response
    }

    func putWbShift(with version: VersionType, request: ShootingSettings.WBShiftRequest) async throws -> ShootingSettings.WBShiftResponse {
        let response = try await self.request(ShootingSettingsTarget.putWbShift(request), decoding: ShootingSettings.WBShiftResponse.self)
        return response
    }

    func getPictureStyle(with version: VersionType) async throws -> ShootingSettings.PictureStyleResponse {
        let response = try await request(ShootingSettingsTarget.getPictureStyle, decoding: ShootingSettings.PictureStyleResponse.self)
        return response
    }

    func putPictureStyle(with version: VersionType, request: ShootingSettings.PictureStyleRequest) async throws -> ShootingSettings.PictureStyleResponse {
        let response = try await self.request(ShootingSettingsTarget.putPictureStyle(request), decoding: ShootingSettings.PictureStyleResponse.self)
        return response
    }
}

// MARK: - StubShootingSettingsService

class StubShootingSettingsService: ShootingSettingsServiceType {
    func getShootingMode(with: VersionType) async throws -> ShootingSettings.ShootingModeResponse {
        return .stub1
    }
    
    func getPictureStyle(with: VersionType) async throws -> ShootingSettings.PictureStyleResponse {
        return .stub1
    }
    
    func putPictureStyle(with: VersionType, request: StringValueRequest) async throws -> ShootingSettings.PictureStyleResponse {
        return .stub1
    }
}
