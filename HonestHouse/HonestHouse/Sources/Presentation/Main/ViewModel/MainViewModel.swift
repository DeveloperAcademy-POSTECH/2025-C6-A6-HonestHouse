//
//  MainViewModel.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/24/25.
//

import SwiftUI

@Observable
final class MainViewModel {
    
    enum Action {
        case goToTriShotSelection
        case goToTriShotSetting
        case goToTriMode
        case goToPresetEditor(PresetDetailMode, Preset)
        case goToPhotoSelection
    }
    
    var selectedSegment: MainViewSegmentType = .trishot
    private var container: DIContainer
    
    var segments: [MainViewSegmentType] = [.trishot, .preset]
    var isPresetEditMode: Bool = false
    var selectedPreset: Preset?

    var showEditButton: Bool {
        selectedSegment == .preset
    }
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func send(action: Action) {
        switch action {
        case .goToTriShotSelection:
            container.navigationRouter.push(to: .trishotSelection)
            
        case .goToTriShotSetting:
            container.navigationRouter.push(to: .trishotSetting)
            
        case .goToTriMode:
            container.navigationRouter.push(to: .trimode)
            
        case .goToPresetEditor(let mode, let preset):
            container.navigationRouter.push(to: .presetEditor(mode, preset))
            
        case .goToPhotoSelection:
            container.navigationRouter.push(to: .photoSelection)
        }
    }
    
    func setSelectedSegment(_ segment: MainViewSegmentType) {
        guard selectedSegment != segment else { return }
        selectedSegment = segment
        exitEditMode()
    }

    func toggleEditMode() {
        isPresetEditMode.toggle()
    }

    func exitEditMode() {
        isPresetEditMode = false
    }

//    func showDetailView(for preset: Preset) {
//        selectedDetailPreset = preset
//    }
//
//    func showEditorView(for preset: Preset? = nil) {
//        selectedEditorPreset = preset
//    }
//
//    func showCreateSheet() {
//        showingCreateSheet = true
//    }
}

extension MainViewModel {
    
    
}
