//
//  Services.swift
//  HonestHouse
//
//  Created by Subeen on 10/23/25.
//

import Foundation

protocol ServiceType {
    var shootingSettingsService: ShootingSettingsServiceType { get set }
    var imageOperationsService: ImageOperationsServiceType { get set }
    var visionManager: VisionManagerType { get }
    var photoManager: PhotoManagerType { get }
}

class Services: ServiceType {
    var shootingSettingsService: ShootingSettingsServiceType
    var imageOperationsService: ImageOperationsServiceType
    var visionManager: VisionManagerType
    var photoManager: PhotoManagerType
    
    init() {
        self.shootingSettingsService = ShootingSettingsService()
        self.imageOperationsService = ImageOperationsService()
        self.visionManager = VisionManager()
        self.photoManager = PhotoManager()
    }
}
