//
//  VisionManager.swift
//  HonestHouse
//
//  Created by Rama on 10/24/25.
//

import SwiftUI
import Vision

class VisionManager {
    private let imageLoader = ImageLoader()
    public func analyzeImages(
        _ photos: [Photo],
        threshold: Float = 0.8
    ) async throws -> [SimilarPhotoGroup] {
        let features = try await extractFeatures(from: photos)
        
        return try await groupSimilarImages(
            analyzedPhotos: features,
            threshold: threshold
        )
    }
    
    // 각 이미지의 특징을 Vision으로 추출
    private func extractFeatures(from photos: [Photo]) async throws -> [AnalyzedPhoto] {
        var features: [AnalyzedPhoto] = []
        
        for photo in photos {
            do {
                let uiImage = try await imageLoader.fetchUIImage(from: photo.url)
                
                guard let cgImage = uiImage.cgImage else {
                    print("fail to get CGImage from UIImage from URL: \(photo.url)")
                    continue
                }
                
                let request = VNGenerateImageFeaturePrintRequest()
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                
                try handler.perform([request])
                
                guard let observation = request.results?.first else {
                    print("fail to get VNFeaturePrintObservation for URL: \(photo.url)")
                    continue
                }
                
                features.append(
                    AnalyzedPhoto(
                        photo: photo,
                        observation: observation
                    )
                )
            }
            catch {
               print("Error fetching or analyzing image from \(photo.url): \(error.localizedDescription)")
               continue
           }
        }
        return features
    }
    
    // 비슷한 이미지를 그룹핑
    private func groupSimilarImages(
        analyzedPhotos: [AnalyzedPhoto],
        threshold: Float
    ) async throws -> [SimilarPhotoGroup] {
        var similarGroups: [SimilarPhotoGroup] = []
        var processedImageSet = Set<Int>()
        
        for idx in 0..<analyzedPhotos.count {
            if processedImageSet.contains(idx) { continue }
            
            let group = try findSimilarImagesForGroup(
                startIndex: idx,
                photos: analyzedPhotos,
                threshold: threshold,
                processed: &processedImageSet
            )
            
            if let validGroup = group {
                similarGroups.append(validGroup)
            }
        }
        
        return similarGroups
    }
    
    // 그룹핑을 위한 이미지를 찾음
    private func findSimilarImagesForGroup(
        startIndex: Int,
        photos: [AnalyzedPhoto],
        threshold: Float,
        processed: inout Set<Int>
    ) throws -> SimilarPhotoGroup? {
        var groupImages = [photos[startIndex].photo]
        var groupIndices = [startIndex]
        var distances: [Float] = []
        processed.insert(startIndex)
        
        for idx in (startIndex + 1)..<photos.count {
            if processed.contains(idx) { continue }
            
            let avgDistance = try calculateAverageDistanceToGroup(
                targetIndex: idx,
                groupIndices: groupIndices,
                photos: photos
            )
            
            // 현재 검사하는 이미지와 그룹 내 모든 이미지들 간의 유사도를 확인, 그 유사도의 평균값이 임계값보다 작으면 통과
            if avgDistance < threshold {
                groupImages.append(photos[idx].photo)
                groupIndices.append(idx)
                distances.append(avgDistance)
                processed.insert(idx)
            }
        }
        
        guard groupImages.count > 1 else { return nil }
        
        return makeSimillarGroup(
            photos: groupImages,
            distances: distances,
            threshold: threshold
        )
    }
    
    
    private func calculateAverageDistanceToGroup(
        targetIndex: Int,
        groupIndices: [Int],
        photos: [AnalyzedPhoto]
    ) throws -> Float {
        var sumDistance: Float = 0.0
        
        for groupIdx in groupIndices {
            var distance: Float = 0.0
            try photos[groupIdx].observation.computeDistance(
                &distance,
                to: photos[targetIndex].observation
            )
            sumDistance += distance
        }
        
        return sumDistance / Float(groupIndices.count)
    }

    private func makeSimillarGroup(
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
}
