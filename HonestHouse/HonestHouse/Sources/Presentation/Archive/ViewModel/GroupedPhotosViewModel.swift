//
//  GroupedPhotosViewModel.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

@MainActor
@Observable
class GroupedPhotosViewModel {

    private var visionManager: VisionManagerType
    private var photoManager: PhotoManagerType
    private var imagePrefetchManager: ImagePrefetchManagerType
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
        imagePrefetchManager = container.managers.imagePrefetchManager
        
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

                // 그룹화 완료 후 그룹 내 이미지들 prefetch 시작
                let allGroupedUrls = result.flatMap { $0.photos.map { $0.url } }
                
                imagePrefetchManager.startPrefetch(urls: allGroupedUrls)
                
            } catch let error as VisionError {
                groupingState = .failure(GroupingError.from(visionError: error))
            } catch {
                groupingState = .failure(.unknown)
            }
        }
    }
    
    func saveSelectedPhotos() {
        savingState = .saving

        Task {
            do {
                try await photoManager.savePhotos(photos: selectedPhotosInGroup)

                // 저장 완료 후 모든 캐시 삭제
                ImageCache.default.clearMemoryCache()
                ImageCache.default.clearDiskCache {
                    print("🗑️ [Cache] All cache cleared after save")
                }

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

    // MARK: - Prefetch 관리

    /// 특정 그룹의 이미지들을 즉시 prefetch (GridCell 탭 시 호출)
    func prefetchGroupImages(for group: SimilarPhotoGroup) {

        print("⚡️ [GroupedPhotos] Immediate prefetch for group with \(group.photos.count) images")

        // DetailView에서 사용할 원본 이미지를 1200x1200으로 즉시 prefetch
        let originalUrls = group.photos.map { $0.url }.compactMap { URL(string: $0) }
        let prefetcher = ImagePrefetcher(
            urls: originalUrls,
            options: [
                .backgroundDecode,
                .processor(DownsamplingImageProcessor(size: CGSize(width: 1200, height: 1200)))
            ]
        )
        prefetcher.maxConcurrentDownloads = 2
        prefetcher.start()

        print("   - Prefetching \(originalUrls.count) original images for DetailView")
    }

    /// Prefetch 중단
    func stopPrefetching() {
        imagePrefetchManager.stopAll()
    }
}

extension GroupedPhotosViewModel {
    func goToMain() {
        container.navigationRouter.popToRoot()
    }
}
