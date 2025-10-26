//
//  Services.swift
//  HonestHouse
//
//  Created by Subeen on 10/23/25.
//

import Foundation

protocol ServiceType {
    var shootingSettingsService: ShootingSettingsServiceType { get set }
}

class Services: ServiceType {
    var shootingSettingsService: ShootingSettingsServiceType
    
    init() {
        self.shootingSettingsService = ShootingSettingsService()
    }
}
