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
    let onShowCreate: () -> Void

    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

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

            if showToast {
                ToastView(message: toastMessage, isShowing: $showToast)
                    .transition(.move(edge: .bottom))
            }
        }
        .task {
            vm.configure(container: container)
            
            NetworkManager.shared.configure(cameraIP: "192.168.1.2", port: 443)
            Task {
                try await NetworkManager.shared.initializeAuthentication()
            }
            
            await vm.getAperture()
        }
        .onChange(of: isEditMode) { _, newValue in
            if !newValue {
                vm.clearSelection()
            }
        }
        .onChange(of: vm.error) { _, newError in
            if let error = newError {
                toastMessage = error.localizedDescription
                showToast = true
            } else {
                showToast = false
            }
        }
        .alert("프리셋 적용", isPresented: $vm.showingShootAlert) {
            Button("취소", role: .cancel) {}
            Button("적용") {
                if let preset = vm.shootAlertPreset {
                    Task {
                        await vm.setCurrentPreset(preset)
                    }
                }
            }
            .keyboardShortcut(.defaultAction) // 버튼 배경 파란색 변경 용도
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
