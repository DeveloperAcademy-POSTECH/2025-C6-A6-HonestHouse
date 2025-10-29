//
//  Services.swift
//  HonestHouse
//
//  Created by Subeen on 10/23/25.
//

import Foundation
import SwiftData

protocol ServiceType {
    var shootingControlService: ShootingControlServiceType { get set }
    var shootingSettingsService: ShootingSettingsServiceType { get set }
    var imageOperationsService: ImageOperationsServiceType { get set }
    var presetService: PresetServiceType { get }

}

class Services: ServiceType {
    var shootingControlService: ShootingControlServiceType
    var shootingSettingsService: ShootingSettingsServiceType
    var imageOperationsService: ImageOperationsServiceType
    var presetService: PresetServiceType
    
    init(modelContext: ModelContext) {
        self.shootingControlService = ShootingControlService()
        self.shootingSettingsService = ShootingSettingsService()
        self.imageOperationsService = ImageOperationsService()
        self.presetService = PresetService(modelContext: modelContext)
    }
}

// MARK: - StubServices

class StubServices: ServiceType {
    var shootingControlService: ShootingControlServiceType = StubShootingControlServiceType()
    var shootingSettingsService: ShootingSettingsServiceType = StubShootingSettingsService()
    var imageOperationsService: ImageOperationsServiceType = StubImageOperationsService()
    var presetService: PresetServiceType = StubPresetService()
}
