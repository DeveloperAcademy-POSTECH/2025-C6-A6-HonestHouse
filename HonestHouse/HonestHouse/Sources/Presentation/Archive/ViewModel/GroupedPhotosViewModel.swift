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
    
    var photosFromSelection = Photo.mockPhotos(count: 20)
    var groupedPhotos: [SimilarPhotoGroup] = []
    var selectedPhotosInGroup: [Photo] = []
    
    init(selectedPhotos: [Photo]) {
        self.photosFromSelection = selectedPhotos
        
        Task {
            self.groupedPhotos = try await visionManager.analyzeImages(photosFromSelection)
        }
    }
}
