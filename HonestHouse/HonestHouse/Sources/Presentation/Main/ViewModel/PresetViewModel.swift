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
    var errorMessage: String?

    private var service: PresetServiceType

    init(container: DIContainer) {
        self.service = container.services.presetService
    }

    func loadPresets() {
        do {
            presets = try service.fetchAll()
        } catch {
            errorMessage = "Failed to load presets: \(error.localizedDescription)"
        }
    }

    func createPreset(_ preset: Preset) {
        do {
            try service.create(preset)
            loadPresets()
        } catch {
            errorMessage = "Failed to create preset: \(error.localizedDescription)"
        }
    }

    func updatePreset(_ preset: Preset) {
        do {
            try service.update(preset)
            loadPresets()
        } catch {
            errorMessage = "Failed to update preset: \(error.localizedDescription)"
        }
    }

    func deletePreset(_ preset: Preset) {
        do {
            try service.delete(preset)
            loadPresets()
        } catch {
            errorMessage = "Failed to delete preset: \(error.localizedDescription)"
        }
    }

    func deletePreset(at id: UUID) {
        do {
            try service.delete(at: id)
            loadPresets()
        } catch {
            errorMessage = "Failed to delete preset: \(error.localizedDescription)"
        }
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
        do {
            for id in selectedPresets {
                try service.delete(at: id)
            }
            selectedPresets.removeAll()
            loadPresets()
        } catch {
            errorMessage = "Failed to delete presets: \(error.localizedDescription)"
        }
    }

    func clearSelection() {
        selectedPresets.removeAll()
    }
}
