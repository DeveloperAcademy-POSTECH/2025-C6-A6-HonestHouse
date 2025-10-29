//
//  ImagePrefetchManager.swift
//  HonestHouse
//
//  Created by 이현주 on 10/28/25.
//

import Foundation
import Kingfisher

final class ImagePrefetchManager: ImagePrefetchManagerType {

    private var prefetcher: ImagePrefetcher?

    /// 전체 이미지 URL 목록으로 prefetch 시작
    func startPrefetch(urls: [String]) {
        guard !urls.isEmpty else { return }

        // 기존 prefetch 중단
        stopAll()

        let imageUrls = urls.compactMap { URL(string: $0) }

        prefetcher = ImagePrefetcher(
            urls: imageUrls,
            options: [.backgroundDecode],
//            completionHandler: { skipped, failed, completed in
//                
//            }
        )

        prefetcher?.start()
    }

    /// 모든 prefetch 작업 중단
    func stopAll() {
        prefetcher?.stop()
        prefetcher = nil
    }
}

// MARK: - StubImagePrefetchManager

final class StubImagePrefetchManager: ImagePrefetchManagerType {
    func startPrefetch(urls: [String]) {
        return
    }
    
    func stopAll() {
        return
    }
    
    func savePhotos(photos: [Photo]) async throws {
        return
    }
}
