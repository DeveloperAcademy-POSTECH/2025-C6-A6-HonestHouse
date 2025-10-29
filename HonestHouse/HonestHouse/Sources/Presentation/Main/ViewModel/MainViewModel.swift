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
    var selectedPreset: Preset?

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
        selectedPreset = preset
    }

    func showCreateView() {
        let tempPreset = Preset(name: "", pictureStyle: .auto, shootingMode: .av)
        selectedPreset = tempPreset
    }
}
