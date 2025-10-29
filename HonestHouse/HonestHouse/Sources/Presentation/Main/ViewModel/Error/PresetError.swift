//
//  PresetError.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/28/25.
//

import Foundation

enum PresetError: Error, LocalizedError {
    // MARK: - SwiftData Errors
    case fetchFailed
    case createFailed
    case updateFailed
    case deleteFailed
    case presetNotFound

    // MARK: - Data Integrity Errors
    case invalidPictureStyle(String)
    case invalidShootingMode(String)

    // MARK: - CCAPI Errors
    case cameraBusy
    case cameraUnavailable
    case settingFailed

    // MARK: - General
    case unknown

    var errorDescription: String? {
        switch self {
        case .fetchFailed: return "프리셋을 불러오는 데 실패했습니다. 다시 시도해주세요."
        case .createFailed: return "프리셋을 생성하는 데 실패했습니다. 다시 시도해주세요."
        case .updateFailed: return "프리셋을 업데이트하는 데 실패했습니다. 다시 시도해주세요."
        case .deleteFailed: return "프리셋을 삭제하는 데 실패했습니다. 다시 시도해주세요."
        case .presetNotFound: return "프리셋을 찾을 수 없습니다."
        case .invalidPictureStyle(let value): return "잘못된 픽쳐스타일입니다: \(value)"
        case .invalidShootingMode(let value): return "잘못된 촬영 모드입니다: \(value)"
        case .cameraBusy: return "카메라가 사용 중입니다. 잠시 후 다시 시도해주세요."
        case .cameraUnavailable: return "카메라 연결이 불안정합니다. 다시 연결해주세요."
        case .settingFailed: return "프리셋 적용 중 오류가 발생했습니다. 다시 시도해주세요."
        case .unknown: return "알 수 없는 오류가 발생했습니다. 다시 시도해주세요."
        }
    }
}

extension PresetError: Equatable {
    static func from(presetServiceError: PresetServiceError) -> PresetError {
        switch presetServiceError {
        case .presetNotFound:
            return .presetNotFound
        }
    }

    static func from(ccapiError: CCAPIError) -> PresetError {
        switch ccapiError {
        case .deviceUnavailable:
            return .cameraBusy
        case .invalidResponse, .unexpectedStatusCode, .urlNotFound, .badRequest:
            return .settingFailed
        default:
            return .cameraUnavailable
        }
    }
}
