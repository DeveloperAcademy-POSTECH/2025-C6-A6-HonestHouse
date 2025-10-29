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
    var presetService: PresetServiceType { get set }
    var visionManager: VisionManagerType { get }
    var photoManager: PhotoManagerType { get }
}

class Services: ServiceType {
    var shootingControlService: ShootingControlServiceType
    var shootingSettingsService: ShootingSettingsServiceType
    var imageOperationsService: ImageOperationsServiceType
    var presetService: PresetServiceType
    var visionManager: VisionManagerType
    var photoManager: PhotoManagerType
    
    init(modelContext: ModelContext) {
        self.shootingControlService = ShootingControlService()
        self.shootingSettingsService = ShootingSettingsService()
        self.imageOperationsService = ImageOperationsService()
        self.presetService = PresetService(modelContext: modelContext)
        self.visionManager = VisionManager()
        self.photoManager = PhotoManager()
    }
}
