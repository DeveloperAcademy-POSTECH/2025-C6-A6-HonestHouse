//
//  ImagePrefetchManagerType.swift
//  HonestHouse
//
//  Created by 이현주 on 10/28/25.
//

import Foundation

protocol ImagePrefetchManagerType {

    /// 전체 이미지 URL 목록으로 prefetch 시작
    /// - Parameters:
    ///   - urls: prefetch할 이미지 URL 목록
    ///   - highPriority: true면 제한 없이 모두 prefetch (그룹화된 이미지용), false면 처음 20개만
    func startPrefetch(urls: [String], highPriority: Bool)

    /// 모든 prefetch 작업 중단
    func stopAll()
}
