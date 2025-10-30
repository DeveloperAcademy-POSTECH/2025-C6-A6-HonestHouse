//
//  Preset.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftData
import Foundation

@Model
final class Preset: Hashable {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Private Storage (SwiftData 저장용)
    private var pictureStyleRawValue: String
    private var shootingModeRawValue: String

    // MARK: - Computed Properties (사용자 접근용)
    @Transient
    var pictureStyle: PictureStyleType {
        get {
            guard let style = PictureStyleType(rawValue: pictureStyleRawValue) else {
                fatalError("Invalid picture style: \(pictureStyleRawValue)")
            }
            return style
        }
        set {
            pictureStyleRawValue = newValue.rawValue
        }
    }

    @Transient
    var shootingMode: ShootingModeType {
        get {
            guard let mode = ShootingModeType(rawValue: shootingModeRawValue) else {
                fatalError("Invalid shooting mode: \(shootingModeRawValue)")
            }
            return mode
        }
        set {
            shootingModeRawValue = newValue.rawValue
        }
    }

    // MARK: - Optional Settings
    var aperture: String?
    var shutterSpeed: String?
    var iso: String?

    var exposureCompensation: String?
    var colorTemperature: Int?

    var tintBlueAmber: Int?
    var tintMagentaGreen: Int?

    init(
        id: UUID = UUID(),
        name: String,
        pictureStyle: PictureStyleType,
        shootingMode: ShootingModeType,
        aperture: String? = nil,
        shutterSpeed: String? = nil,
        iso: String? = nil,
        exposureCompensation: String? = nil,
        colorTemperature: Int? = nil,
        tintBlueAmber: Int? = nil,
        tintMagentaGreen: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.pictureStyleRawValue = pictureStyle.rawValue
        self.shootingModeRawValue = shootingMode.rawValue
        self.aperture = aperture
        self.shutterSpeed = shutterSpeed
        self.iso = iso
        self.exposureCompensation = exposureCompensation
        self.colorTemperature = colorTemperature
        self.tintBlueAmber = tintBlueAmber
        self.tintMagentaGreen = tintMagentaGreen
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Hashable Conformance
extension Preset {
    static func == (lhs: Preset, rhs: Preset) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Preset {
    static var stub1: Preset {
        .init(name: "", pictureStyle: .auto, shootingMode: .av)
    }
}
