//
//  GroupedPhotosViewModel.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI

@Observable
class GroupedPhotosViewModel {
    var selectedPhotos = Photo.mockPhotos(count: 20)
    var groupedPhotos: [GroupedPhotos] = []
    
    init(selectedPhotos: [Photo]) {
        self.selectedPhotos = selectedPhotos
        groupPhotosTemporarily()
    }
    
    func groupPhotosTemporarily() {
        let chunkSize = 5
        let chunks = stride(from: 0, to: selectedPhotos.count, by: chunkSize).map {
            Array(selectedPhotos[$0..<min($0 + chunkSize, selectedPhotos.count)])
        }
        self.groupedPhotos = chunks.map { GroupedPhotos(photos: $0)}
    }
}
