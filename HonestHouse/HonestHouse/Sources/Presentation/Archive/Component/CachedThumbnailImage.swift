//
//  CachedThumbnailImage.swift
//  HonestHouse
//
//  Created by Claude on 10/28/25.
//

import SwiftUI
import Kingfisher

/// 썸네일 이미지 컴포넌트 (다운샘플링 + 메모리 캐시)
struct CachedThumbnailImage: View {
    let url: String
    let size: CGSize
    let cornerRadius: CGFloat

    @State private var loadingFailed = false

    init(
        url: String,
        size: CGSize = CGSize(width: 300, height: 300),
        cornerRadius: CGFloat = 0
    ) {
        self.url = url
        self.size = size
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        KFImage(URL(string: url))
            .setProcessor(DownsamplingImageProcessor(size: size))
            .cacheMemoryOnly()
            .loadDiskFileSynchronously()  // 메인 스레드에서 디스크 캐시 확인 (빠른 표시)
            .fade(duration: 0.2)
            .retry(maxCount: 2, interval: .seconds(1))  // WiFi Direct 연결 불안정 대비
            .onSuccess { _ in
                loadingFailed = false
            }
            .onFailure { _ in
                loadingFailed = true
            }
            .placeholder {
                placeholderView()
            }
            .resizable()
            .overlay(
                loadingFailed ? errorOverlay() : nil
            )
    }

    private func placeholderView() -> some View { // TODO: - 스켈레톤 UI 씌우기
        Group {
            if cornerRadius > 0 {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(ProgressView())
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(ProgressView())
            }
        }
    }

    private func errorOverlay() -> some View { // 로딩 실패시, 뷰
        ZStack {
            if cornerRadius > 0 {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.black.opacity(0.5))
            } else {
                Color.black.opacity(0.5)
            }

            VStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 16))
                Text("Load Failed")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
        }
    }
}
