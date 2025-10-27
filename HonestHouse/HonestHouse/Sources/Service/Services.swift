//
//  Services.swift
//  HonestHouse
//
//  Created by Subeen on 10/23/25.
//

import Foundation
import SwiftData

protocol ServiceType {
    var shootingSettingsService: ShootingSettingsServiceType { get set }
    var imageOperationsService: ImageOperationsServiceType { get set }
    var presetService: PresetServiceType { get }
    var visionManager: VisionManagerType { get }
    var photoManager: PhotoManagerType { get }
}

class Services: ServiceType {
    var shootingSettingsService: ShootingSettingsServiceType
    var imageOperationsService: ImageOperationsServiceType
    var presetService: PresetServiceType
    var visionManager: VisionManagerType
    var photoManager: PhotoManagerType
    
    init(modelContext: ModelContext) {
        self.shootingSettingsService = ShootingSettingsService()
        self.imageOperationsService = ImageOperationsService()
        self.presetService = PresetService(modelContext: modelContext)
        self.visionManager = VisionManager()
        self.photoManager = PhotoManager()
    }
}
