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
                            isEditMode: $vm.isEditMode,
                            onShowDetail: vm.showDetailView,
                            onShowCreate: vm.showCreateView
                        )
                    }
                }
                .padding(.top, 9)
            }
            .padding(.horizontal, 16)
            .navigationDestination(item: $vm.selectedPreset) { preset in
                PresetDetailView(
                    preset: preset,
                    onDelete: preset.name.isEmpty ? nil : {
                        modelContext.delete(preset)
                        try? modelContext.save()
                        vm.selectedPreset = nil
                    }
                )
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

