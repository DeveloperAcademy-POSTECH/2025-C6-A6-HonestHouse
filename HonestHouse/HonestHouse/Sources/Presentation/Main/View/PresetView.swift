//
//  PresetView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI
import SwiftData

struct PresetView: View {
    @EnvironmentObject private var container: DIContainer
    @Query(sort: \Preset.createdAt, order: .reverse) private var presets: [Preset]
    @State private var vm: PresetDetailViewModel = PresetDetailViewModel()

    @Binding var isEditMode: Bool
    let onShowDetail: (Preset) -> Void
    let onShowEditor: (Preset?) -> Void
    let onShowCreate: () -> Void


    init(
        container: DIContainer,
        isEditMode: Binding<Bool>,
        onShowDetail: @escaping (Preset) -> Void,
        onShowEditor: @escaping (Preset?) -> Void,
        onShowCreate: @escaping () -> Void
    ) {
        _isEditMode = isEditMode
        self.onShowDetail = onShowDetail
        self.onShowEditor = onShowEditor
        self.onShowCreate = onShowCreate
        _vm = State(initialValue: PresetViewModel(container: container))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            presetGridScrollView()

            Group {
                if isEditMode {
                    deleteButton()
                } else {
                    HStack {
                        Spacer()
                        addButton()
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .onChange(of: isEditMode) { _, newValue in
            if !newValue {
                vm.clearSelection()
            }
        }
        .alert("프리셋 적용", isPresented: $vm.showingShootAlert) {
            Button("취소", role: .cancel) {}
            Button("적용") {
                // TODO: 값 세팅 연결
            }
        } message: {
            if let preset = vm.shootAlertPreset {
                Text("'\(preset.name)' 프리셋을 적용하시겠습니까?")
            }
        }
    }
    
    private func presetGridScrollView() -> some View {
        ScrollView {
            PresetGridView(
                presets: presets,
                isEditMode: isEditMode,
                selectedPresets: vm.selectedPresets,
                onTap: { preset in
                    onShowDetail(preset)
                },
                onShoot: { preset in
                    vm.showShootAlert(for: preset)
                },
                onToggleSelection: { preset in
                    vm.toggleSelection(for: preset)
                }
            )
            .padding(.top, 3)
            .padding(.horizontal, 2)
        }
        .scrollIndicators(.hidden)
    }

    private func addButton() -> some View {
        Button {
            onShowCreate()
        } label: {
            if #available(iOS 26.0, *) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 48, height: 48)
                    .glassEffect()
            } else {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(.gray))
            }
        }
    }

    private func deleteButton() -> some View {
        Button {
            vm.deleteSelectedPresets()
            isEditMode = false
        } label: {
            HStack {
                Spacer()
                Text("삭제 (\(vm.selectedPresets.count))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .frame(height: 50)
            .background(vm.selectedPresets.isEmpty ? Color.gray : Color.red)
            .cornerRadius(12)
        }
        .disabled(vm.selectedPresets.isEmpty)
    }
}
