//
//  PresetGridView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI

struct PresetGridView: View {
    let presets: [Preset]
    let isEditMode: Bool
    let selectedPresets: Set<UUID>
    let onTap: (Preset) -> Void
    let onShoot: (Preset) -> Void
    let onToggleSelection: ((Preset) -> Void)?

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(presets) { preset in
                PresetGridCellView(
                    preset: preset,
                    isEditMode: isEditMode,
                    isSelected: selectedPresets.contains(preset.id),
                    onTap: onTap,
                    onShoot: onShoot,
                    onToggleSelection: onToggleSelection
                )
            }
        }
    }
}

