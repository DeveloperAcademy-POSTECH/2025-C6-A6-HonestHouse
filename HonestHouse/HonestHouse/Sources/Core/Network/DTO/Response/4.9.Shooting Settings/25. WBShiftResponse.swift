//
//  WBShiftResponse.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

extension ShootingSettings {
    
    /// 4.9.25 화이트 밸런스 보정
    struct WBShiftResponse: BaseResponse {
        let value: Value?
        let ability: AbilityList?
    }
}

extension ShootingSettings.WBShiftResponse {
    struct Value: Codable {
        let blueAmber: Int?
        let magentaGreen: Int?

        enum CodingKeys: String, CodingKey {
            case blueAmber = "ba"
            case magentaGreen = "mg"
        }
    }
}

extension ShootingSettings.WBShiftResponse {
    struct AbilityList: Codable {
        let blueAmberAbility: Ability?
        let magentaGreenAbility: Ability?

        enum CodingKeys: String, CodingKey {
            case blueAmberAbility = "ba"
            case magentaGreenAbility = "mg"
        }
    }
}

extension ShootingSettings.WBShiftResponse.AbilityList {
    struct Ability: Codable {
        let min: Int?
        let max: Int?
        let step: Int?
    }
}

extension ShootingSettings.WBShiftResponse {
    typealias EntityType = WhiteBalance
    
    func toEntity() -> WhiteBalance {
        WhiteBalance()
    }
}
