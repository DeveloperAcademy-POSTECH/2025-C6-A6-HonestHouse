//
//  VisionManager.swift
//  HonestHouse
//
//  Created by Rama on 10/24/25.
//

import SwiftUI
import Vision
import Kingfisher

class VisionManager: VisionManagerType {
    private let imageLoader: ImageLoader
    
    init(imageLoader: ImageLoader = .shared) {
        self.imageLoader = imageLoader
    }
    
    public func analyzeImages(
        _ photos: [Photo],
        threshold: Float
    ) async throws -> [SimilarPhotoGroup] {
        let features = try await extractFeaturesFromThumbnails(from: photos)

        return try await groupSimilarImages(
            analyzedPhotos: features,
            threshold: threshold
        )
    }
    
    /// 썸네일에서 Vision 특징 추출 (Kingfisher 캐시 활용)
    private func extractFeaturesFromThumbnails(from photos: [Photo]) async throws -> [AnalyzedPhoto] {
        var features: [AnalyzedPhoto] = []
        var errorInfos: [(photo: Photo, error: Error)] = []

        for photo in photos {
            do {
                // Kingfisher를 사용해서 썸네일 캐시에서 이미지 가져오기
                let uiImage = try await fetchThumbnailImage(from: photo.thumbnailURL)

                guard let cgImage = uiImage.cgImage else {
                    errorInfos.append((photo, VisionError.cgImageConversion(url: photo.thumbnailURL)))
                    continue
                }

                let request = VNGenerateImageFeaturePrintRequest()
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

                try handler.perform([request])

                guard let observation = request.results?.first else {
                    errorInfos.append((photo, VisionError.observation(url: photo.thumbnailURL)))
                    continue
                }

                features.append(
                    AnalyzedPhoto(
                        photo: photo,
                        observation: observation
                    )
                )
            }
            catch let error {
                errorInfos.append((photo, VisionError.imageFetching(url: photo.thumbnailURL, underlyingError: error)))
                continue
            }
        }

        if !errorInfos.isEmpty {
            let failedPhotos = errorInfos.map { $0.photo }
            let errors = errorInfos.map{ $0.error }
            throw VisionError.partialAnalysis(failedPhotos: failedPhotos, errors: errors)
        }

        return features
    }

    /// Kingfisher를 사용해서 썸네일 이미지 가져오기 (캐시 우선)
    private func fetchThumbnailImage(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw ImageLoadingError.invalidURL
        }

        return try await withCheckedThrowingContinuation { continuation in
            KingfisherManager.shared.retrieveImage(
                with: url,
                options: [
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 300, height: 300)))
                ]
            ) { result in
                switch result {
                case .success(let imageResult):
                    continuation.resume(returning: imageResult.image)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // 각 이미지의 특징을 Vision으로 추출
//    private func extractFeatures(from photos: [Photo]) async throws -> [AnalyzedPhoto] {
//        var features: [AnalyzedPhoto] = []
//        var errorInfos: [(photo: Photo, error: Error)] = []
//        
//        for photo in photos {
//            do {
//                let uiImage = try await imageLoader.fetchUIImage(from: photo.url)
//                
//                guard let cgImage = uiImage.cgImage else {
//                    errorInfos.append((photo, VisionError.cgImageConversion(url: photo.url)))
//                    continue
//                }
//                
//                let request = VNGenerateImageFeaturePrintRequest()
//                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//                
//                try handler.perform([request])
//                
//                guard let observation = request.results?.first else {
//                    errorInfos.append((photo, VisionError.observation(url: photo.url)))
//                    continue
//                }
//                
//                features.append(
//                    AnalyzedPhoto(
//                        photo: photo,
//                        observation: observation
//                    )
//                )
//            }
//            catch let error {
//                errorInfos.append((photo, VisionError.imageFetching(url: photo.url, underlyingError: error)))
//                continue
//            }
//        }
//        
//        if !errorInfos.isEmpty {
//            let failedPhotos = errorInfos.map { $0.photo }
//            let errors = errorInfos.map{ $0.error }
//            throw VisionError.partialAnalysis(failedPhotos: failedPhotos, errors: errors)
//        }
//        
//        return features
//    }
    
    // 비슷한 이미지를 그룹핑
    private func groupSimilarImages(
        analyzedPhotos: [AnalyzedPhoto],
        threshold: Float
    ) async throws -> [SimilarPhotoGroup] {
        var similarGroups: [SimilarPhotoGroup] = []
        var processedImageSet = Set<Int>()
        
        // 유사한 사진들끼리 그룹 생성
        for idx in 0..<analyzedPhotos.count {
            if processedImageSet.contains(idx) { continue }
            
            let group = try matchSimilarImages(
                startIndex: idx,
                photos: analyzedPhotos,
                threshold: threshold,
                processed: &processedImageSet
            )
            
            if let validGroup = group {
                similarGroups.append(validGroup)
            }
        }
        
        // 처리되지 않은 단독 사진들을 Extra 그룹으로 추가
        if let extraGroup = handleExtraPhotos(
            analyzedPhotos: analyzedPhotos,
            processedImageSet: processedImageSet
        ) {
            similarGroups.append(extraGroup)
        }
        
        return similarGroups
    }
    
    // 그룹핑을 위한 이미지를 찾음
    private func matchSimilarImages(
        startIndex: Int,
        photos: [AnalyzedPhoto],
        threshold: Float,
        processed: inout Set<Int>
    ) throws -> SimilarPhotoGroup? {
        var groupImages = [photos[startIndex].photo]
        var currentGroupIndexes = [startIndex]
        var distances: [Float] = []
        
        for idx in (startIndex + 1)..<photos.count {
            if processed.contains(idx) { continue }
            
            let avgDistance = try calculateAverageDistanceToGroup(
                targetIndex: idx,
                currentGroupIndexes: currentGroupIndexes,
                photos: photos
            )
            
            // 그룹 내 사진과 타겟 사진 유사도의 평균값이 임계값보다 작으면 통과
            if avgDistance < threshold {
                groupImages.append(photos[idx].photo)
                currentGroupIndexes.append(idx)
                distances.append(avgDistance)
            }
        }
        
        guard groupImages.count > 1 else { return nil }
        
        for index in currentGroupIndexes {
            processed.insert(index)
        }
        
        return makeSimilarGroup(
            photos: groupImages,
            distances: distances,
            threshold: threshold
        )
    }
    
    // 그룹 내 사진과 타겟 사진의 유사도 평균을 계산
    private func calculateAverageDistanceToGroup(
        targetIndex: Int,
        currentGroupIndexes: [Int],
        photos: [AnalyzedPhoto]
    ) throws -> Float {
        var sumDistance: Float = 0.0
        
        for idx in currentGroupIndexes {
            var distance: Float = 0.0
            try photos[idx].observation.computeDistance(
                &distance,
                to: photos[targetIndex].observation
            )
            sumDistance += distance
        }
        
        return sumDistance / Float(currentGroupIndexes.count)
    }
    
    private func makeSimilarGroup(
        photos: [Photo],
        distances: [Float],
        threshold: Float
    ) -> SimilarPhotoGroup {
        let avgDistance = distances.reduce(0, +) / Float(distances.count)
        let confidence = max(0, min(1, (threshold - avgDistance) / threshold))
        
        return SimilarPhotoGroup(
            photos: photos,
            averageDistance: avgDistance,
            confidence: confidence
        )
    }
    
    // 어떤 그룹에도 속하지 못한 단독 사진들을 Extra 그룹으로 생성
    private func handleExtraPhotos(
        analyzedPhotos: [AnalyzedPhoto],
        processedImageSet: Set<Int>
    ) -> SimilarPhotoGroup? {
        var extraPhotos: [Photo] = []
        
        for idx in 0..<analyzedPhotos.count {
            if !processedImageSet.contains(idx) {
                extraPhotos.append(analyzedPhotos[idx].photo)
            }
        }
        
        // Extra 사진이 없으면 nil 반환
        guard !extraPhotos.isEmpty else { return nil }
        
        // Extra 그룹 생성 (confidence와 averageDistance는 0)
        return SimilarPhotoGroup(
            photos: extraPhotos,
            averageDistance: 0.0,
            confidence: 0.0
        )
    }
}

// MARK: - StubVisionMananger

final class StubVisionManager: VisionManagerType {
    func analyzeImages(_ photos: [Photo], threshold: Float) async throws -> [SimilarPhotoGroup] {
        // TODO: stub 만들어서 넣기
        return [.init(photos: [], averageDistance: 0, confidence: 0)]
    }
}
