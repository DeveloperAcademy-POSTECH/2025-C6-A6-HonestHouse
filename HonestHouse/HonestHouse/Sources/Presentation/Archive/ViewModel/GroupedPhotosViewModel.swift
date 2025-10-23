//
//  GroupedPhotosViewModel.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI

@Observable
class GroupedPhotosViewModel {
    var photosFromSelection = Photo.mockPhotos(count: 20)
    var groupedPhotos: [GroupedPhotos] = []
    var selectedPhotosInGroup: [Photo] = []
    
    init(selectedPhotos: [Photo]) {
        self.photosFromSelection = selectedPhotos
        groupPhotosTemporarily()
    }
    
    func groupPhotosTemporarily() {
        let chunkSize = 5
        let chunks = stride(from: 0, to: photosFromSelection.count, by: chunkSize).map {
            Array(photosFromSelection[$0..<min($0 + chunkSize, photosFromSelection.count)])
        }
        self.groupedPhotos = chunks.map { GroupedPhotos(photos: $0)}
    }
}
