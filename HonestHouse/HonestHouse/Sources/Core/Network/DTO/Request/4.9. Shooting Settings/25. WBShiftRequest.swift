//
//  WBShiftRequest.swift
//  HonestHouse
//
//  Created by Subeen on 10/23/25.
//

extension ShootingSettings {
    struct WBShiftRequest: BaseRequest {
        var value: WBShift
    }
}

extension ShootingSettings.WBShiftRequest {
    struct WBShift: BaseRequest {
        var blueAmber: Int
        var magentaGreen: Int

        enum CodingKeys: String, CodingKey {
            case blueAmber = "ba"
            case magentaGreen = "mg"
        }
    }
}
