//
//  ImagePrefetchManagerType.swift
//  HonestHouse
//
//  Created by 이현주 on 10/28/25.
//

import Foundation

protocol ImagePrefetchManagerType {

    /// 선택된 이미지들을 디스크에 display 사이즈(1200x1200)로 prefetch
    /// - Parameter urls: prefetch할 이미지 URL 목록
    func prefetchSelectedPhotosForDisk(urls: [String])

    /// 썸네일 사이즈(300x300)로 prefetch (Vision 처리용)
    /// - Parameter urls: prefetch할 이미지 URL 목록
    func prefetchThumbnails(urls: [String])

    /// 모든 prefetch 작업 중단
    func stopAll()
}
