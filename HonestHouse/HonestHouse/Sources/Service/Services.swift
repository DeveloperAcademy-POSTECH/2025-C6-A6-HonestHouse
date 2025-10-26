//
//  Services.swift
//  HonestHouse
//
//  Created by Subeen on 10/23/25.
//

import Foundation

protocol ServiceType {
    var shootingSettingsService: ShootingSettingsServiceType { get set }
    var visionManager: VisionManagerType { get }
}

class Services: ServiceType {
    var shootingSettingsService: ShootingSettingsServiceType
    var visionManager: VisionManagerType
    
    init() {
        self.shootingSettingsService = ShootingSettingsService()
        self.visionManager = VisionManager()
    }
}
