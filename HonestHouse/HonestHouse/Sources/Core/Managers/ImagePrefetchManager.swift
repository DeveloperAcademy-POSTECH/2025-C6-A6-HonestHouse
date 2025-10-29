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

        // 메모리 캐시 제한 설정 (300MB로 제한)
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 300 * 1024 * 1024  // 300MB
        cache.memoryStorage.config.countLimit = 50  // 최대 50개 이미지

        // 디스크 캐시 제한 (500MB)
        cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024

        // 메모리 경고 시 자동 정리
        cache.memoryStorage.config.expiration = .seconds(300)  // 5분 후 만료
    }

    /// 전체 이미지 URL 목록으로 prefetch 시작
    func startPrefetch(urls: [String], highPriority: Bool = false) {
        guard !urls.isEmpty else { return }

        // 기존 prefetch 중단
        stopAll()

        let imageUrls = urls.compactMap { URL(string: $0) }

        // highPriority면 모든 이미지 prefetch (그룹화된 이미지용)
        // 아니면 WiFi Direct 대역폭 고려하여 첫 20개만
        let urlsToPrefetch: [URL]
        if highPriority {
            urlsToPrefetch = imageUrls
            print("🚀 [Prefetch] HIGH PRIORITY: Prefetching all \(imageUrls.count) images")
        } else {
            urlsToPrefetch = Array(imageUrls.prefix(20))
            print("🚀 [Prefetch] Normal priority: Prefetching first \(urlsToPrefetch.count) of \(imageUrls.count) images")
        }

        prefetcher = ImagePrefetcher(
            urls: urlsToPrefetch,
            options: [
                .backgroundDecode,
                .processor(DownsamplingImageProcessor(size: CGSize(width: 1200, height: 1200)))  // DetailView용 1200x1200
            ]
        )

        // 동시 다운로드 수를 2개로 제한 (WiFi Direct 대역폭 고려)
        prefetcher?.maxConcurrentDownloads = 2
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
