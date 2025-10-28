//
//  MainView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/24/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @EnvironmentObject private var container: DIContainer
    @Environment(\.modelContext) private var modelContext
    @State private var vm: MainViewModel = .init()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                cameraAndArchiveHeaderView()
                segmentedControlView()
                
                Group {
                    switch vm.selectedSegment {
                    case .trishot:
                        Text("TriShot View")
                    case .preset:
                        PresetView(
                            container: container,
                            isEditMode: $vm.isEditMode,
                            onShowDetail: vm.showDetailView,
                            onShowEditor: vm.showEditorView,
                            onShowCreate: vm.showCreateSheet
                        )
                    }
                }
                .padding(.top, 9)
            }
            .padding(.horizontal, 16)
            .navigationDestination(item: $vm.selectedDetailPreset) { preset in
                PresetDetailView(
                    preset: preset,
                    onShowEditor: vm.showEditorView
                )
            }
            .navigationDestination(item: $vm.selectedEditorPreset) { preset in
                PresetEditorTemporaryView(
                    preset: preset,
                    onSave: { name, mode, pictureStyle, aperture, shutterSpeed, iso, exposureCompensation, colorTemperature, tintBlueAmber, tintMagentaGreen in
                        preset.name = name
                        preset.shootingMode = mode
                        preset.pictureStyle = pictureStyle
                        preset.aperture = aperture
                        preset.shutterSpeed = shutterSpeed
                        preset.iso = iso
                        preset.exposureCompensation = exposureCompensation
                        preset.colorTemperature = colorTemperature
                        preset.tintBlueAmber = tintBlueAmber
                        preset.tintMagentaGreen = tintMagentaGreen
                        preset.updatedAt = Date()
                        try? modelContext.save()
                    },
                    onDelete: {
                        modelContext.delete(preset)
                        try? modelContext.save()
                        vm.selectedEditorPreset = nil
                    }
                )
            }
            .sheet(isPresented: $vm.showingCreateSheet) {
                PresetEditorTemporaryView { name, mode, pictureStyle, aperture, shutterSpeed, iso, exposureCompensation, colorTemperature, tintBlueAmber, tintMagentaGreen in
                    let newPreset = Preset(
                        name: name,
                        pictureStyle: pictureStyle,
                        shootingMode: mode,
                        aperture: aperture,
                        shutterSpeed: shutterSpeed,
                        iso: iso,
                        exposureCompensation: exposureCompensation,
                        colorTemperature: colorTemperature,
                        tintBlueAmber: tintBlueAmber,
                        tintMagentaGreen: tintMagentaGreen
                    )
                    modelContext.insert(newPreset)
                    try? modelContext.save()
                }
            }
        }
    }
    
    private func cameraAndArchiveHeaderView() -> some View {
        HStack {
            Button {
                // TODO: 카메라 설정 뷰 연결
            } label: {
                Image(systemName: "camera.badge.ellipsis")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24)
            }
            Spacer()

            if vm.showEditButton {
                Button {
                    vm.toggleEditMode()
                } label: {
                    Text(vm.isEditMode ? "완료" : "편집")
                        .font(.system(size: 16, weight: .bold))
                }
                .padding(.trailing, 12)
            }

            Button {
                // TODO: 사진 불러오기 연결
            } label: {
                Image(systemName: "photo.badge.plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24)
            }
        }
        .foregroundStyle(.black)
    }
    
    
    private func segmentedControlView() -> some View {
        Picker("", selection: Binding(
            get: { vm.selectedSegment },
            set: { vm.setSelectedSegment($0) }
        )) {
            ForEach(vm.segments, id: \.self) {
                Text($0.displayName)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    MainView()
}

