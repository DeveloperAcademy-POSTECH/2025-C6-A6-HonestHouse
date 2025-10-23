//
//  ShootingSettingsAPI.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation

/// 촬영 설정 (Shooting Settings)
enum ShootingSettingsAPI {
    case getShootingSetting                     /// 모든 촬영 매개변수
    case shootingMode                           /// 사진촬영 모드  (촬영 다이얼 있는 모델)
    case av                                     /// 조리개
    case tv                                     /// 셔터스피드
    case iso                                    /// ISO
    case exposureCompensation                   /// 노출보정
    case whiteBalance                           /// 화이트밸런스
    case colorTemperture                        /// 색온도
    case stillImageShootingImageQuality         /// 사진 형식
    case stillImageAspectRatio                  /// 사진 비율
    case wbShift                                /// 화이트밸런스 보정 (Blue/Amber, Green/Magenta)
    
    var apiDesc: String {
        switch self {
        case .getShootingSetting:
            return "ver100/shooting/settings"
            
        case .shootingMode:
            return "ver100/shooting/settings/shootingmodedial"
            
        case .av:
            return "ver100/shooting/settings/av"
            
        case .tv:
            return "ver100/shooting/settings/tv"
            
        case .iso:
            return "ver100/shooting/settings/iso"
            
        case .exposureCompensation:
            return "ver100/shooting/settings/exposure"
            
        case .whiteBalance:
            return "ver100/shooting/settings/wb"
            
        case .colorTemperture:
            return "ver100/shooting/settings/colortemperature"
            
        case .stillImageShootingImageQuality:
            return ""
            
        case .stillImageAspectRatio:
            return "ver100/shooting/settings/stillimageaspectratio"
            
        case .wbShift:
            return "ver100/shooting/settings/wbshift"
        }
    }
}
