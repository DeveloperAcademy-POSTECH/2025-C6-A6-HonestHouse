//
//  GroupedPhotosViewModel.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI

@MainActor
@Observable
class GroupedPhotosViewModel {
    private var visionManager: VisionManagerType!
    
    var photosFromSelection: [Photo]
    var selectedPhotosInGroup: [Photo] = []
    var state: GroupingState = .idle
    
    init(selectedPhotos: [Photo]) {
        self.photosFromSelection = selectedPhotos
    }
    
    func configure(container: DIContainer) {
        guard self.visionManager == nil else { return }
        self.visionManager = container.services.visionManager
    }
    
    func startGrouping() {
        if case .loading = state { return }
        if case .success = state { return }
        
        state = .loading
        
        Task {
            do {
                let result = try await visionManager.analyzeImages(photosFromSelection, threshold: 8.0)
                state = .success(result)
            } catch let error as VisionError {
                state = .failure(GroupingError.from(visionError: error))
            } catch {
                state = .failure(.unknown)
            }
        }
    }
}
