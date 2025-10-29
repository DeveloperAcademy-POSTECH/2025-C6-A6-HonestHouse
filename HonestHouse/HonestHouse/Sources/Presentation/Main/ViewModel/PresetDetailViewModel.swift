//
//  PresetViewModel.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI
import SwiftData

@Observable
final class PresetDetailViewModel {
    var presets: [Preset] = []
    var selectedPreset: Preset?
    var selectedPresets: Set<UUID> = []
    var showingCreateSheet = false
    var showingShootAlert = false
    var shootAlertPreset: Preset?
    var error: PresetError?

    private var presetService: PresetServiceType?
    private var shootingControlService: ShootingControlServiceType?
    private var shootingSettingsService: ShootingSettingsServiceType?
}

extension PresetDetailViewModel: PresetErrorHandleable {
    func configure(container: DIContainer) {
        guard self.presetService == nil else { return }
        self.presetService = container.services.presetService
        
        guard self .shootingControlService == nil else { return }
        self.shootingControlService = container.services.shootingControlService

        guard self.shootingSettingsService == nil else { return }
        self.shootingSettingsService = container.services.shootingSettingsService
    }

    func selectPreset(_ preset: Preset) {
        selectedPreset = preset
    }

    func showCreateSheet() {
        showingCreateSheet = true
    }

    func showShootAlert(for preset: Preset) {
        shootAlertPreset = preset
        showingShootAlert = true
    }

    func toggleSelection(for preset: Preset) {
        if selectedPresets.contains(preset.id) {
            selectedPresets.remove(preset.id)
        } else {
            selectedPresets.insert(preset.id)
        }
    }

    func deleteSelectedPresets() {
        guard let presetService else {
            handleError(PresetError.unknown)
            return
        }

        do {
            for id in selectedPresets {
                try presetService.delete(at: id)
            }
            selectedPresets.removeAll()
            loadPresets()
        } catch {
            handleError(error)
        }
    }

    func clearSelection() {
        selectedPresets.removeAll()
    }
}

//MARK: - SwiftData Related
extension PresetDetailViewModel {
    func loadPresets() {
        guard let presetService else {
            handleError(PresetError.unknown)
            return
        }

        do {
            presets = try presetService.fetchAll()
            error = nil
        } catch {
            handleError(error)
        }
    }

    func createPreset(_ preset: Preset) {
        guard let presetService else {
            handleError(PresetError.unknown)
            return
        }

        do {
            try presetService.create(preset)
            loadPresets()
        } catch {
            handleError(error)
        }
    }

    func updatePreset(_ preset: Preset) {
        guard let presetService else {
            handleError(PresetError.unknown)
            return
        }

        do {
            try presetService.update(preset)
            loadPresets()
        } catch {
            handleError(error)
        }
    }

    func deletePreset(_ preset: Preset) {
        guard let presetService else {
            handleError(PresetError.unknown)
            return
        }

        do {
            try presetService.delete(preset)
            loadPresets()
        } catch {
            handleError(error)
        }
    }

    func deletePreset(at id: UUID) {
        guard let presetService else {
            handleError(PresetError.unknown)
            return
        }

        do {
            try presetService.delete(at: id)
            loadPresets()
        } catch {
            handleError(error)
        }
    }
}

//MARK: - Shooting Settings Related
extension PresetDetailViewModel {
    /// View 진입 시 처음 호출할 용도로 만든 getAperture
    func getAperture() async {
        guard let shootingSettingsService = shootingSettingsService else {
            handleError(PresetError.unknown)
            return
        }
        
        do {
            let res = try await shootingSettingsService.getAV(with: .ver100)
            print(res)
        } catch {
            handleError(error)
        }
    }
    
    /// 현재 프리셋 적용
    func setCurrentPreset(_ preset: Preset) async {
        let shootingMode = preset.shootingMode
        let pictureStyle = preset.pictureStyle
        
        do {
            /// 현재 슈팅 모드 무시 on
            try await ignoreShootingMode(action: "on")
            try await setShootingMode(value: shootingMode.apiValue)
            
            try await setPictureStyle(value: pictureStyle.apiValue)
            
            switch shootingMode {
            case .av:
                if let aperture = preset.aperture {
                    try await setAperture(value: aperture)
                }
                
            case .tv:
                if let shutterSpeed = preset.shutterSpeed {
                    try await setShutterSpeed(value: shutterSpeed)
                }
            case .p:
                break
            }
            
            if let iso = preset.iso {
                try await setISO(value: iso)
            }
            
            if let exposureCompensation = preset.exposureCompensation {
                try await setExposureCompensation(value: exposureCompensation)
            }
            
            print(preset.colorTemperature ?? -1)
            
            if let colorTemperature = preset.colorTemperature {
                try await setColorTemperature(value: colorTemperature)
            }
            
            if let tintBlueAmber = preset.tintBlueAmber, let tintMagentaGreen = preset.tintMagentaGreen {
                try await setWbShift(blueAmber: tintBlueAmber, magentaGreen: tintMagentaGreen)
            }
            
            error = nil
            
            // 현재 슈팅 모드 무시 off
            try await ignoreShootingMode(action: "off")
        } catch {
            handleError(error)
        }
    }
}

//MARK: - CCAPI
extension PresetDetailViewModel {
    private func ignoreShootingMode(action: String) async throws {
        guard let shootingControlService else { throw PresetError.unknown }
        let request = ShootingControl.IgnoreShootingModeRequest(action: action)
        try await shootingControlService.ignoreShootingMode(with: .ver100, request: request)
    }
    
    private func getShootingMode() async throws {
        guard let shootingSettingsService = shootingSettingsService else {
            handleError(PresetError.unknown)
            return
        }
        
        do {
            let res = try await shootingSettingsService.getShootingMode(with: .ver110)
            print(res)
        } catch {
            handleError(error)
        }
    }

    private func setShootingMode(value: String) async throws {
        guard let shootingSettingsService else { throw PresetError.unknown }
        let request = ShootingSettings.ShootingModeRequest(value: value)
//        _ = try await shootingSettingsService.putShootingMode(with: .ver100, request: request)
        let response = try await shootingSettingsService.putShootingMode(with: .ver110, request: request)
        print(response)
    }

    private func setPictureStyle(value: String) async throws {
        guard let shootingSettingsService else { throw PresetError.unknown }
        let request = ShootingSettings.PictureStyleRequest(value: value)
        let response = try await shootingSettingsService.putPictureStyle(with: .ver100, request: request)
        print(response)
    }

    private func setAperture(value: String) async throws {
        guard let shootingSettingsService else { throw PresetError.unknown }
        let request = ShootingSettings.AVRequest(value: value)
        let response = try await shootingSettingsService.putAV(with: .ver100, request: request)
        print(response)
    }

    private func setShutterSpeed(value: String) async throws {
        guard let shootingSettingsService else { throw PresetError.unknown }
        let request = ShootingSettings.TVRequest(value: value)
        _ = try await shootingSettingsService.putTV(with: .ver100, request: request)
    }

    private func setISO(value: String) async throws {
        guard let shootingSettingsService else { throw PresetError.unknown }
        let request = ShootingSettings.ISORequest(value: value)
        let response = try await shootingSettingsService.putISO(with: .ver100, request: request)
        print(response)
    }

    private func setExposureCompensation(value: String) async throws {
        guard let shootingSettingsService else { throw PresetError.unknown }
        let request = ShootingSettings.ExposureCompensationRequest(value: value)
        let response = try await shootingSettingsService.putExposureCompensation(with: .ver100, request: request)
        print(response)
    }

    private func setColorTemperature(value: Int) async throws {
        guard let shootingSettingsService else { throw PresetError.unknown }
        let request = ShootingSettings.ColorTemperatureRequest(value: value)
        let response = try await shootingSettingsService.putColorTemperature(with: .ver100, request: request)
        print(response)
    }

    private func setWbShift(blueAmber: Int, magentaGreen: Int) async throws {
        guard let shootingSettingsService else { throw PresetError.unknown }
        let wbShift = ShootingSettings.WBShiftRequest.WBShift(blueAmber: blueAmber, magentaGreen: magentaGreen)
        let request = ShootingSettings.WBShiftRequest(value: wbShift)
        let response = try await shootingSettingsService.putWbShift(with: .ver100, request: request)
        print(response)
    }
}
