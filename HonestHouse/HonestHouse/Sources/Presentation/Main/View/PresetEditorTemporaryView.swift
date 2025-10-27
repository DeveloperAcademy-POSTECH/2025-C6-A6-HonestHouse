//
//  PresetEditorTemporaryView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI

//TODO: Preset CRUD 확인용 임시 뷰입니다. 추후 실제 PresetEditorView(가제) 구현 시 삭제 혹은 변경해주세요.

struct PresetEditorTemporaryView: View {
    @Environment(\.dismiss) private var dismiss

    let preset: Preset?
    let onSave: (String, String, String?, String?, String?, String?, String?, Int?, Int?, Int?) -> Void
    let onDelete: (() -> Void)?

    @State private var name: String
    @State private var selectedMode: String
    @State private var pictureStyle: String
    @State private var aperture: String
    @State private var shutterSpeed: String
    @State private var iso: String
    @State private var exposureCompensation: String
    @State private var colorTemperature: String
    @State private var tintBlueAmber: String
    @State private var tintMagentaGreen: String
    @State private var showingDeleteAlert = false

    private let shootingModes = ["Av", "Tv", "P"]

    init(
        preset: Preset? = nil,
        onSave: @escaping (String, String, String?, String?, String?, String?, String?, Int?, Int?, Int?) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.preset = preset
        self.onSave = onSave
        self.onDelete = onDelete
        _name = State(initialValue: preset?.name ?? "")
        _selectedMode = State(initialValue: preset?.shootingMode ?? "Av")
        _pictureStyle = State(initialValue: preset?.pictureStyle ?? "")
        _aperture = State(initialValue: preset?.aperture ?? "")
        _shutterSpeed = State(initialValue: preset?.shutterSpeed ?? "")
        _iso = State(initialValue: preset?.iso ?? "")
        _exposureCompensation = State(initialValue: preset?.exposureCompensation ?? "")
        _colorTemperature = State(initialValue: preset?.colorTemperature.map { String($0) } ?? "")
        _tintBlueAmber = State(initialValue: preset?.tintBlueAmber.map { String($0) } ?? "")
        _tintMagentaGreen = State(initialValue: preset?.tintMagentaGreen.map { String($0) } ?? "")
    }

    private func resetToInitialValues() {
        name = preset?.name ?? ""
        selectedMode = preset?.shootingMode ?? "Av"
        pictureStyle = preset?.pictureStyle ?? ""
        aperture = preset?.aperture ?? ""
        shutterSpeed = preset?.shutterSpeed ?? ""
        iso = preset?.iso ?? ""
        exposureCompensation = preset?.exposureCompensation ?? ""
        colorTemperature = preset?.colorTemperature.map { String($0) } ?? ""
        tintBlueAmber = preset?.tintBlueAmber.map { String($0) } ?? ""
        tintMagentaGreen = preset?.tintMagentaGreen.map { String($0) } ?? ""
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("프리셋 정보") {
                    TextField("프리셋 이름", text: $name)

                    Picker("촬영 모드", selection: $selectedMode) {
                        ForEach(shootingModes, id: \.self) { mode in
                            Text(mode).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("색상 설정") {
                    TextField("픽쳐스타일 (예: Standard)", text: $pictureStyle)
                    TextField("색온도 (예: 5200)", text: $colorTemperature)
                        .keyboardType(.numberPad)
                }

                Section("노출 설정") {
                    TextField("조리개 (예: f/2.8)", text: $aperture)
                    TextField("셔터 스피드 (예: 1/250)", text: $shutterSpeed)
                    TextField("ISO (예: 400)", text: $iso)
                    TextField("노출 보정 (예: +1)", text: $exposureCompensation)
                }

                Section("틴트 설정") {
                    TextField("Blue/Amber (예: 0)", text: $tintBlueAmber)
                        .keyboardType(.numberPad)
                    TextField("Magenta/Green (예: 0)", text: $tintMagentaGreen)
                        .keyboardType(.numberPad)
                }

                if preset != nil, onDelete != nil {
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
            }
            .navigationTitle(preset == nil ? "프리셋 생성" : "프리셋 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if preset != nil {
                            resetToInitialValues()
                        } else {
                            dismiss()
                        }
                    } label: {
                        if preset == nil {
                            Text("취소")
                                .foregroundStyle(.black)
                        } else {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundStyle(.black)
                        }
                        
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        onSave(
                            name,
                            selectedMode,
                            pictureStyle.isEmpty ? nil : pictureStyle,
                            aperture.isEmpty ? nil : aperture,
                            shutterSpeed.isEmpty ? nil : shutterSpeed,
                            iso.isEmpty ? nil : iso,
                            exposureCompensation.isEmpty ? nil : exposureCompensation,
                            Int(colorTemperature),
                            Int(tintBlueAmber),
                            Int(tintMagentaGreen)
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .alert("프리셋 삭제", isPresented: $showingDeleteAlert) {
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive) {
                    onDelete?()
                    dismiss()
                }
            } message: {
                Text("이 프리셋을 삭제하시겠습니까?")
            }
        }
    }
}
