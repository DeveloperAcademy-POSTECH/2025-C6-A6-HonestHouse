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
    private var visionManager: VisionManagerType?
    
    var photosFromSelection: [Photo]
    var selectedPhotosInGroup: [Photo] = []
    var groupingState: GroupingState = .idle
    
    init(selectedPhotos: [Photo]) {
        self.photosFromSelection = selectedPhotos
    }
    
    func configure(container: DIContainer) {
        guard self.visionManager == nil else { return }
        self.visionManager = container.services.visionManager
    }
    
    func startGrouping() {
        guard let visionManager else {
            groupingState = .failure(.unknown)
            return
        }
        
        if case .loading = groupingState { return }
        if case .success = groupingState { return }
        
        groupingState = .loading
        
        Task {
            do {
                let result = try await visionManager.analyzeImages(photosFromSelection, threshold: 0.8)
                groupingState = .success(result)
            } catch let error as VisionError {
                groupingState = .failure(GroupingError.from(visionError: error))
            } catch {
                groupingState = .failure(.unknown)
            }
        }
    }
}
