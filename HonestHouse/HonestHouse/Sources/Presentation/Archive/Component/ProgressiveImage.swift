//
//  ProgressiveImage.swift
//  HonestHouse
//
//  Created by 이현주 on 10/28/25.
//

import SwiftUI
import Kingfisher

/// Progressive Loading: 썸네일 → 원본 전환
struct ProgressiveImage: View {
    let thumbnailURL: String
    let originalURL: String

    @State private var loadingFailed = false

    var body: some View {
        ZStack {
            // 그리드에서 이미 캐시된 썸네일 먼저 표시 (즉시 렌더링)
            KFImage(URL(string: thumbnailURL))
                .setProcessor(
                    DownsamplingImageProcessor(size: CGSize(width: 300, height: 300))
                )
                .cacheMemoryOnly()
                .fade(duration: 0.1)
                .placeholder {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(ProgressView())
                }
                .resizable()
                .aspectRatio(contentMode: .fit)

            // 원본 이미지를 Kingfisher로 로드 (prefetch로 미리 다운로드됨)
            KFImage(URL(string: originalURL))
                .retry(maxCount: 3, interval: .seconds(2))  // 503 에러 자동 재시도
                .fade(duration: 0.3)
                .onSuccess { _ in
                    loadingFailed = false
                }
                .onFailure { error in
                    loadingFailed = true
                    print("Failed to load original image: \(error)")
                }
                .resizable()
                .aspectRatio(contentMode: .fit)

            // 에러 발생 시 UI 표시
            if loadingFailed {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                    Text("Failed to load image")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Retry in progress...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
            }
        }
    }
}
