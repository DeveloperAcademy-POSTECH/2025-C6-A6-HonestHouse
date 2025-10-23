//
//  ShootingSettingsTarget.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Moya

enum ShootingSettingsTarget {
    case getShootingSetting                     /// 모든 촬영 매개변수
    case putShottingSetting
    case getShootingMode                        /// 사진촬영 모드
    case putShootingMode                        /// 사진촬영 모드
    case getAv                                  /// 조리개
    case putAv                                  /// 조리개
    case getTv                                  /// 셔터스피드
    case putTv                                  /// 셔터스피드
    case getIso                                 /// ISO
    case putIso                                 /// ISO
    case getExposureCompensation                /// 노출보정
    case putExposureCompensation                /// 노출보정
    case getWhiteBalance                        /// 화이트밸런스
    case putWhiteBalance                        /// 화이트밸런스
    case getColorTemperture                     /// 색온도
    case putColorTemperture                     /// 색온도
    case getStillImageShootingImageQuality      /// 사진 형식
    case putStillImageAspectRatio               /// 사진 비율
    case getWbShift                             /// 화이트밸런스 보정 (Blue/Amber, Green/Magenta)
    case putWbShift                             /// 화이트밸런스 보정 (Blue/Amber, Green/Magenta)
}

//extension ShootingSettingsTarget: BaseTargetType {
//    var path: String {
//        <#code#>
//    }
//    
//    var method: Moya.Method {
//        <#code#>
//    }
//    
//    var task: Moya.Task {
//        <#code#>
//    }
//}
