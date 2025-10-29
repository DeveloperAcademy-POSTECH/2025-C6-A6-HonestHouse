//
//  ImagePrefetchManagerType.swift
//  HonestHouse
//
//  Created by 이현주 on 10/28/25.
//

import Foundation

protocol ImagePrefetchManagerType {

    /// 전체 이미지 URL 목록으로 prefetch 시작
    func startPrefetch(urls: [String])

    /// 모든 prefetch 작업 중단
    func stopAll()
}
