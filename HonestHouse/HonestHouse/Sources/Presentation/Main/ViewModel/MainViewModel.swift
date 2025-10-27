//
//  MainViewModel.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/24/25.
//

import SwiftUI

@Observable
final class MainViewModel {
    var selectedSegment: MainViewSegmentType = .trishot {
        didSet {
            if selectedSegment != oldValue {
                exitEditMode()
            }
        }
    }
    
    var segments: [MainViewSegmentType] = [.trishot, .preset]
    var isEditMode: Bool = false
    var selectedDetailPreset: Preset?
    var selectedEditorPreset: Preset?
    var showingCreateSheet = false

    var showEditButton: Bool {
        selectedSegment == .preset
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
