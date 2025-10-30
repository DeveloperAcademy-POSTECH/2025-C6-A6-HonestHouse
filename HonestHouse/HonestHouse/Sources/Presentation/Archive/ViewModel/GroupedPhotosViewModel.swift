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
    private var visionManager: VisionManagerType
    private var photoManager: PhotoManagerType
    private var container: DIContainer
    
    var photosFromSelection: [Photo]
    var selectedPhotosInGroup: [Photo] = []
    
    var groupingState: GroupingState = .idle
    var savingState: SavingState = .idle
    
    init(
        container: DIContainer,
        selectedPhotos: [Photo]
    ) {
        self.container = container
        visionManager = container.managers.visionManager
        photoManager = container.managers.photoManager
        
        self.photosFromSelection = selectedPhotos
    }
    
//    func configure(container: DIContainer) {
//        guard self.visionManager == nil else { return }
//        self.visionManager = container.services.visionManager
//        
//        guard self.photoManager == nil else { return }
//        self.photoManager = container.services.photoManager
//    }
    
    func startGrouping() {
//        guard let visionManager else {
//            groupingState = .failure(.unknown)
//            return
//        }
        
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
    
    func saveSelectedPhotos() {
//        guard let photoManager else {
//            savingState = .failure("PhotoManager not exist")
//            return
//        }
//        
        savingState = .saving
        
        Task {
            do {
                try await photoManager.savePhotos(photos: selectedPhotosInGroup)
                savingState = .success
            } catch {
                savingState = .failure(error.localizedDescription)
            }
        }
    }
    
    func toggleGroupedPhotoView(for photo: Photo) {
        if let index = selectedPhotosInGroup.firstIndex(where: { $0.url == photo.url}) {
            selectedPhotosInGroup.remove(at: index)
        } else {
            selectedPhotosInGroup.append(photo)
        }
    }
}

extension GroupedPhotosViewModel {
    func goToMain() {
        container.navigationRouter.popToRoot()
    }
}
