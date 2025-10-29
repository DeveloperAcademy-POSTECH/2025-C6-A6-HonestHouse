//
//  PresetDetailView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI
import SwiftData

//TODO: Preset CRUD 확인용 임시 뷰입니다. 추후 실제 PresetDetailView(가제) 구현 시 삭제 혹은 변경해주세요.

struct PresetDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let preset: Preset
    let onDelete: (() -> Void)?

    @State private var mode: PresetDetailMode
    @State private var showingDeleteAlert = false

    // 편집용 임시 상태
    @State private var editedName: String = ""
    @State private var editedMode: ShootingModeType = .av
    @State private var editedPictureStyle: PictureStyleType = .auto
    @State private var editedAperture: String = ""
    @State private var editedShutterSpeed: String = ""
    @State private var editedISO: String = ""
    @State private var editedExposureCompensation: String = ""
    @State private var editedColorTemperature: String = ""
    @State private var editedTintBlueAmber: String = ""
    @State private var editedTintMagentaGreen: String = ""

    private let shootingModes: [ShootingModeType] = [.av, .tv, .p]
    private let pictureStyles: [PictureStyleType] = [.auto, .standard, .portrait, .landscape, .finedetail, .neutral, .faithful, .monochrome]

    init(preset: Preset, onDelete: (() -> Void)? = nil) {
        self.preset = preset
        self.onDelete = onDelete
        // preset의 name이 비어있으면 create 모드, 아니면 view 모드로 시작
        _mode = State(initialValue: preset.name.isEmpty ? .create : .view)
    }
    
    var body: some View {
        Group {
            switch mode {
            case .view:
                viewModeContent()
            case .edit, .create:
                editModeContent()
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(mode == .create)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if mode == .create {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(toolbarButtonTitle) {
                    if mode == .view {
                        loadEditingValues()
                        mode = .edit
                    } else if mode == .edit {
                        saveChanges()
                        mode = .view
                    } else if mode == .create {
                        createPreset()
                        dismiss()
                    }
                }
                .disabled((mode == .edit || mode == .create) && editedName.isEmpty)
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
    
    private var navigationTitle: String {
        switch mode {
        case .view:
            return preset.name
        case .edit:
            return "프리셋 편집"
        case .create:
            return "프리셋 생성"
        }
    }
    
    private var toolbarButtonTitle: String {
        switch mode {
        case .view:
            return "편집"
        case .edit, .create:
            return "저장"
        }
    }
    
}

extension PresetDetailView {
    // MARK: - 조회 모드 Content
    private func viewModeContent() -> some View {
        List {
            Section("프리셋 정보") {
                LabeledContent("이름") {
                    Text(preset.name)
                }

                LabeledContent("촬영 모드") {
                    Text(preset.shootingMode.displayValue)
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
                LabeledContent("픽쳐스타일") {
                    Text(preset.pictureStyle.displayValue)
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
    }

    // MARK: - 편집 모드 Content
    private func editModeContent() -> some View {
        Form {
            Section("프리셋 정보") {
                TextField("프리셋 이름", text: $editedName)

                Picker("촬영 모드", selection: $editedMode) {
                    ForEach(shootingModes, id: \.self) { mode in
                        Text(mode.displayValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("색상 설정") {
                Picker("픽쳐스타일", selection: $editedPictureStyle) {
                    ForEach(pictureStyles, id: \.self) { style in
                        Text(style.displayValue).tag(style)
                    }
                }
                TextField("색온도 (예: 5200)", text: $editedColorTemperature)
                    .keyboardType(.numberPad)
            }

            Section("노출 설정") {
                switch editedMode {
                case .av:
                    TextField("조리개 (예: f2.8)", text: $editedAperture)
                        .autocapitalization(.none)
                case .tv:
                    TextField("셔터 스피드 (예: 1/250)", text: $editedShutterSpeed)
                        .autocapitalization(.none)
                case .p:
                    EmptyView()
                }

                TextField("ISO (예: 400)", text: $editedISO)
                    .autocapitalization(.none)
                TextField("노출 보정 (예: +1)", text: $editedExposureCompensation)
                    .autocapitalization(.none)
            }

            Section("틴트 설정") {
                TextField("Blue/Amber (예: 0)", text: $editedTintBlueAmber)
                    .keyboardType(.numberPad)
                TextField("Magenta/Green (예: 0)", text: $editedTintMagentaGreen)
                    .keyboardType(.numberPad)
            }

            if onDelete != nil {
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
    }

    // MARK: - Helper Methods
    private func loadEditingValues() {
        editedName = preset.name
        editedMode = preset.shootingMode
        editedPictureStyle = preset.pictureStyle
        editedAperture = preset.aperture ?? ""
        editedShutterSpeed = preset.shutterSpeed ?? ""
        editedISO = preset.iso ?? ""
        editedExposureCompensation = preset.exposureCompensation ?? ""
        editedColorTemperature = preset.colorTemperature.map { String($0) } ?? ""
        editedTintBlueAmber = preset.tintBlueAmber.map { String($0) } ?? ""
        editedTintMagentaGreen = preset.tintMagentaGreen.map { String($0) } ?? ""
    }

    private func saveChanges() {
        preset.name = editedName
        preset.shootingMode = editedMode
        preset.pictureStyle = editedPictureStyle
        preset.aperture = editedAperture.isEmpty ? nil : editedAperture
        preset.shutterSpeed = editedShutterSpeed.isEmpty ? nil : editedShutterSpeed
        preset.iso = editedISO.isEmpty ? nil : editedISO
        preset.exposureCompensation = editedExposureCompensation.isEmpty ? nil : editedExposureCompensation
        preset.colorTemperature = Int(editedColorTemperature)
        preset.tintBlueAmber = Int(editedTintBlueAmber)
        preset.tintMagentaGreen = Int(editedTintMagentaGreen)
        preset.updatedAt = Date()

        try? modelContext.save()
    }

    private func createPreset() {
        guard !editedName.isEmpty else { return }

        let newPreset = Preset(
            name: editedName,
            pictureStyle: editedPictureStyle,
            shootingMode: editedMode,
            aperture: editedAperture.isEmpty ? nil : editedAperture,
            shutterSpeed: editedShutterSpeed.isEmpty ? nil : editedShutterSpeed,
            iso: editedISO.isEmpty ? nil : editedISO,
            exposureCompensation: editedExposureCompensation.isEmpty ? nil : editedExposureCompensation,
            colorTemperature: Int(editedColorTemperature),
            tintBlueAmber: Int(editedTintBlueAmber),
            tintMagentaGreen: Int(editedTintMagentaGreen)
        )

        modelContext.insert(newPreset)
        try? modelContext.save()
    }
}
