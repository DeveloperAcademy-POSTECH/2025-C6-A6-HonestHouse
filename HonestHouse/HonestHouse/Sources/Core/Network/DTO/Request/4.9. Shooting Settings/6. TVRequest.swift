//
//  TVRequest.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

extension ShootingSettings {
    struct TVRequest: BaseRequest {
        let value: String
    }
}

typealias ShutterSpeedRequest = ShootingSettings.TVRequest
