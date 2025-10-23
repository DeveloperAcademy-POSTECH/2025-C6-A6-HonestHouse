//
//  ColorTemperatureResponse.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

extension ShootingSettings {
    
    /// 4.9.10. 색온도
    struct ColorTemperatureResponse: BaseResponse {
        let value: String?
        let ability: Ability?
    }
}

extension ShootingSettings.ColorTemperatureResponse {
    struct Ability: Codable {
        let min: Int?
        let max: Int?
        let step: Int?
    }
}

extension ShootingSettings.ColorTemperatureResponse {
    typealias EntityType = ColorTemperature
    
    func toEntity() -> ColorTemperature {
        ColorTemperature(
            value: value,
            ability: ColorTemperature.Ability(
                min: ability?.min,
                max: ability?.max,
                step: ability?.step
            )
        )
    }
}
