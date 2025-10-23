//
//  ColorTemperature.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation

struct ColorTemperature {
    let value: String?
    let ability: Ability?
}

extension ColorTemperature {
    struct Ability {
        let min: Int?
        let max: Int?
        let step: Int?
    }
}
