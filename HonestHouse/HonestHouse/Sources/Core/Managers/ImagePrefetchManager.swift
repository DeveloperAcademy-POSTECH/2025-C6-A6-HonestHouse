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

    init() {
        // WiFi Direct 연결 최적화: 동시 다운로드 수 제한
        ImageDownloader.default.downloadTimeout = 15.0

        // 메모리 캐시 제한 설정 (150MB로 제한)
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 150 * 1024 * 1024  // 150MB
        cache.memoryStorage.config.countLimit = 50  // 최대 50개 이미지

        // 디스크 캐시 제한 (3GB)
        cache.diskStorage.config.sizeLimit = 3 * 1024 * 1024 * 1024  // 3GB

        // 캐시 만료 시간 (30분)
        cache.memoryStorage.config.expiration = .seconds(1800)  // 30분
        cache.diskStorage.config.expiration = .seconds(1800)  // 30분
    }

    /// 선택된 이미지들을 디스크에 display 사이즈(1200x1200)로 prefetch
    func prefetchSelectedPhotosForDisk(urls: [String]) {
        guard !urls.isEmpty else { return }

        let imageUrls = urls.compactMap { URL(string: $0) }

        print("💾 [Disk Prefetch] Starting prefetch for \(imageUrls.count) selected images")

        // Display 사이즈로 prefetch하여 디스크에 저장
        let prefetcher = ImagePrefetcher(
            urls: imageUrls,
            options: [
                .backgroundDecode,
                .processor(DownsamplingImageProcessor(size: CGSize(width: 1200, height: 1200))),
                .cacheOriginalImage  // 디스크에 캐시
            ]
        )

        // WiFi Direct 대역폭 고려하여 동시 다운로드 2개로 제한
        prefetcher.maxConcurrentDownloads = 2

        prefetcher.start()
    }

    /// 썸네일 사이즈(300x300)로 prefetch (Vision 처리용)
    func prefetchThumbnails(urls: [String]) {
        guard !urls.isEmpty else { return }

        let imageUrls = urls.compactMap { URL(string: $0) }

        print("🖼️ [Thumbnail Prefetch] Starting prefetch for \(imageUrls.count) thumbnails")

        let prefetcher = ImagePrefetcher(
            urls: imageUrls,
            options: [
                .backgroundDecode,
                .processor(DownsamplingImageProcessor(size: CGSize(width: 300, height: 300)))
            ]
        )

        prefetcher.maxConcurrentDownloads = 3  // 썸네일은 작으니 3개 동시
        prefetcher.start()
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
