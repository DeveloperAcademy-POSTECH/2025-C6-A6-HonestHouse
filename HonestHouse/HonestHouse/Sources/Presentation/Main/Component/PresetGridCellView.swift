//
//  PresetGridCellView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI

struct PresetGridCellView: View {
    let preset: Preset
    let isEditMode: Bool
    let isSelected: Bool
    let onTap: (Preset) -> Void
    let onShoot: (Preset) -> Void
    let onToggleSelection: ((Preset) -> Void)?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            backgroundRegtangleView()
            presetNameLabel()

            if isEditMode {
                presetSelectionCheckmarkButton()
            } else {
                presetShootCameraButton()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isEditMode {
                onToggleSelection?(preset)
            } else {
                onTap(preset)
            }
        }
    }
    
    private func backgroundRegtangleView() -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6))
            .frame(height: 120)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEditMode && isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
    }
    
    private func presetNameLabel() -> some View {
        VStack(alignment: .leading) {
            Text(preset.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
    }
    
    private func presetSelectionCheckmarkButton() -> some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? .blue : .gray)
                    .padding(12)
            }
            Spacer()
        }
    }
    
    private func presetShootCameraButton() -> some View {
        Button {
            onShoot(preset)
        } label: {
            Image(systemName: "camera.circle")
                .font(.system(size: 24))
                .foregroundStyle(.black)
        }
        .padding(12)
    }
}
