//
//  AVRequest.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

extension ShootingSettings {
    struct AVRequest: BaseRequest {
        let value: String
    }
}

typealias ApertureRequest = ShootingSettings.AVRequest
