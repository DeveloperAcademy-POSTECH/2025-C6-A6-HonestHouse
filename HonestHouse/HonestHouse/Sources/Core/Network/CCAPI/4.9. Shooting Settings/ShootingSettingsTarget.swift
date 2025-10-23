//
//  ShootingSettingsTarget.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Moya

enum ShootingSettingsTarget {
    case getShootingSetting(VersionType)                /// 모든 촬영 매개변수
    case getShootingMode                                /// 사진촬영 모드
    case putShootingMode(StringValueRequest)            /// 사진촬영 모드
    case getAv                                          /// 조리개
    case putAv(StringValueRequest)                      /// 조리개
    case getTv                                          /// 셔터스피드
    case putTv(StringValueRequest)                      /// 셔터스피드
    case getIso                                         /// ISO
    case putIso(StringValueRequest)                     /// ISO
    case getExposureCompensation                        /// 노출보정
    case putExposureCompensation(StringValueRequest)    /// 노출보정
    case getWhiteBalance                                /// 화이트밸런스
    case putWhiteBalance(StringValueRequest)            /// 화이트밸런스
    case getColorTemperature                             /// 색온도
    case putColorTemperature(IntValueRequest)            /// 색온도
    case getWbShift                                     /// 화이트밸런스 보정 (Blue/Amber, Green/Magenta)
    case putWbShift(ShootingSettings.WBShiftRequest)    /// 화이트밸런스 보정 (Blue/Amber, Green/Magenta)
}

extension ShootingSettingsTarget: BaseTargetType {
    var path: String {
        switch self {
        case .getShootingSetting(let version):
            ShootingSettingsAPI.getShootingSetting.path(with: version)
            
        case .getShootingMode:
            ShootingSettingsAPI.shootingMode.path(with: .ver100)
            
        case .putShootingMode:
            ShootingSettingsAPI.shootingMode.path(with: .ver100)
            
        case .getAv, .putAv:
            ShootingSettingsAPI.av.path(with: .ver100)
    
        case .getTv, .putTv:
            ShootingSettingsAPI.tv.path(with: .ver100)
            
        case .getIso, .putIso:
            ShootingSettingsAPI.iso.path(with: .ver100)

        case .getExposureCompensation, .putExposureCompensation:
            ShootingSettingsAPI.exposureCompensation.path(with: .ver100)

        case .getWhiteBalance, .putWhiteBalance:
            ShootingSettingsAPI.whiteBalance.path(with: .ver100)

        case .getColorTemperature, .putColorTemperature:
            ShootingSettingsAPI.colorTemperature.path(with: .ver100)

        case .getWbShift, .putWbShift:
            ShootingSettingsAPI.wbShift.path(with: .ver100)
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getShootingSetting,
                .getShootingMode,
                .getAv,
                .getTv,
                .getIso,
                .getExposureCompensation,
                .getWhiteBalance,
                .getColorTemperature,
                .getWbShift:
                return .get

        case .putShootingMode,
                .putAv,
                .putTv,
                .putIso,
                .putExposureCompensation,
                .putWhiteBalance,
                .putColorTemperature,
                .putWbShift
            :
            return .put

        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getShootingSetting,
                .getShootingMode,
                .getAv,
                .getTv,
                .getIso,
                .getExposureCompensation,
                .getWhiteBalance,
                .getColorTemperature,
                .getWbShift:
            return .requestPlain
    
        case .putShootingMode(let request):
            return .requestJSONEncodable(request)

        case .putAv(let request):
            return .requestJSONEncodable(request)

        case .putTv(let request):
            return .requestJSONEncodable(request)

        case .putIso(let request):
            return .requestJSONEncodable(request)

        case .putExposureCompensation(let request):
            return .requestJSONEncodable(request)

        case .putWhiteBalance(let request):
            return .requestJSONEncodable(request)

        case .putColorTemperature(let request):
            return .requestJSONEncodable(request)
            
        case .putWbShift(let request):
            return .requestJSONEncodable(request)
        }
    }
}
