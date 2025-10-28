//
//  Preset.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftData
import Foundation

@Model
final class Preset {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date

    var pictureStyle: String?
    var shootingMode: String

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
        pictureStyle: String? = nil,
        shootingMode: String,
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
        self.pictureStyle = pictureStyle
        self.shootingMode = shootingMode
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
