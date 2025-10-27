//
//  PresetDetailView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI
import SwiftData

//TODO: Preset CRUD 확인용 임시 뷰입니다. 추후 실제 뷰 구현 시 삭제 혹은 변경해주세요.

struct PresetDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let preset: Preset
    let onShowEditor: (Preset) -> Void

    @State private var showingDeleteAlert = false

    var body: some View {
        List {
            Section("프리셋 정보") {
                LabeledContent("이름") {
                    Text(preset.name)
                }

                LabeledContent("촬영 모드") {
                    Text(preset.shootingMode)
                }
            }

            Section("노출 설정") {
                if let aperture = preset.aperture {
                    LabeledContent("조리개") {
                        Text(aperture)
                    }
                }

                if let shutterSpeed = preset.shutterSpeed {
                    LabeledContent("셔터 스피드") {
                        Text(shutterSpeed)
                    }
                }

                if let iso = preset.iso {
                    LabeledContent("ISO") {
                        Text(iso)
                    }
                }

                if let exposureCompensation = preset.exposureCompensation {
                    LabeledContent("노출 보정") {
                        Text(exposureCompensation)
                    }
                }
            }

            Section("색상 설정") {
                if let pictureStyle = preset.pictureStyle {
                    LabeledContent("픽쳐스타일") {
                        Text(pictureStyle)
                    }
                }

                if let colorTemperature = preset.colorTemperature {
                    LabeledContent("색온도") {
                        Text("\(colorTemperature)K")
                    }
                }

                if let blueAmber = preset.tintBlueAmber,
                   let magentaGreen = preset.tintMagentaGreen {
                    LabeledContent("틴트") {
                        Text("BA: \(blueAmber), MG: \(magentaGreen)")
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Text("프리셋 삭제")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle(preset.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("편집") {
                    onShowEditor(preset)
                }
            }
        }
        .alert("프리셋 삭제", isPresented: $showingDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                modelContext.delete(preset)
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("이 프리셋을 삭제하시겠습니까?")
        }
    }
}

#Preview {
    NavigationStack {
        PresetDetailView(
            preset: Preset(
                name: "모노 필터",
                shootingMode: "Av",
                aperture: "f/2.8",
                iso: "400"
            ),
            onShowEditor: { _ in }
        )
    }
    .modelContainer(for: Preset.self, inMemory: true)
}
