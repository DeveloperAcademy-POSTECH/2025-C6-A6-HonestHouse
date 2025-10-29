//
//  Managers.swift
//  HonestHouse
//
//  Created by Subeen on 10/29/25.
//

import Foundation

protocol ManagersType {
    var visionManager: VisionManagerType { get }
    var photoManager: PhotoManagerType { get }
}

final class Managers: ManagersType {
    var visionManager: VisionManagerType
    var photoManager: PhotoManagerType
    
    init() {
        self.visionManager = VisionManager()
        self.photoManager = PhotoManager()
    }
}

// MARK: - StubManagers

final class StubManagers: ManagersType {
    var visionManager: VisionManagerType = StubVisionManager()
    var photoManager: PhotoManagerType = StubPhotoManager()
}
