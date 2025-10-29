//
//  ShootingControlTarget.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/29/25.
//

import Moya

enum ShootingControlTarget {
    case ignoreShootingMode(ShootingControl.IgnoreShootingModeRequest)
}

extension ShootingControlTarget: BaseTargetType {
    var path: String {
        switch self {
        case .ignoreShootingMode:
            return ShootingControlAPI.ignoreShootingMode.path(with: .ver100)
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .ignoreShootingMode:
                .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .ignoreShootingMode(let request):
            return .requestJSONEncodable(request)
        }
    }
}
