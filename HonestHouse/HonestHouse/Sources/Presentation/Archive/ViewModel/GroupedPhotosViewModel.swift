//
//  GroupedPhotosViewModel.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI

@Observable
class GroupedPhotosViewModel {
    private let visionManager = VisionManager()
    
    var photosFromSelection: [Photo]
    var selectedPhotosInGroup: [Photo] = []
    var state: GroupingState = .idle
    
    init(selectedPhotos: [Photo]) {
        self.photosFromSelection = selectedPhotos
    }
    
    func startGrouping() {
        if case .loading = state { return }
        if case .success = state { return }
        
        state = .loading
        
        Task {
            do {
                let result = try await visionManager.analyzeImages(photosFromSelection)
                state = .success(result)
            } catch {
                state = .failure(error)
                print("Error while grouping:\(error.localizedDescription)")
            }
        }
    }
}
