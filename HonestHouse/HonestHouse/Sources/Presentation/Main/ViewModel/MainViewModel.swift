//
//  MainViewModel.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/24/25.
//

import SwiftUI

@Observable
final class MainViewModel {
    private(set) var selectedSegment: MainViewSegmentType = .trishot
    
    var segments: [MainViewSegmentType] = [.trishot, .preset]
    var isEditMode: Bool = false
    var selectedDetailPreset: Preset?
    var selectedEditorPreset: Preset?
    var showingCreateSheet = false

    var showEditButton: Bool {
        selectedSegment == .preset
    }
    
    func setSelectedSegment(_ segment: MainViewSegmentType) {
        guard selectedSegment != segment else { return }
        selectedSegment = segment
        exitEditMode()
    }

    func toggleEditMode() {
        isEditMode.toggle()
    }

    func exitEditMode() {
        isEditMode = false
    }

    func showDetailView(for preset: Preset) {
        selectedDetailPreset = preset
    }

    func showEditorView(for preset: Preset? = nil) {
        selectedEditorPreset = preset
    }

    func showCreateSheet() {
        showingCreateSheet = true
    }
}
