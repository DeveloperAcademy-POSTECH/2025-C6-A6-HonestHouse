//
//  BaseAPI.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

public enum BaseAPI: String {
    case base
    
    public var apiDesc: String {
        switch self {
        case .base:
            return "https://192.168.1.2:443/ccapi/" // TODO: 카메라마다 API 주소 다름
        }
    }
}

