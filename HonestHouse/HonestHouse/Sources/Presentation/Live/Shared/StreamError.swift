//
//  StreamError.swift
//  HonestHouse
//
//  Created by Rama on 10/29/25.
//

import Foundation

enum StreamError: LocalizedError {
    case noCameraSet
    case notAuthenticated
    case authenticationFailed
    case failedToStart
    case streamingFailed
    case invalidData
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .noCameraSet:
            return "카메라 IP가 설정되지 않았습니다"
        case .notAuthenticated:
            return "인증되지 않았습니다"
        case .authenticationFailed:
            return "인증에 실패했습니다"
        case .failedToStart:
            return "라이브뷰 시작에 실패했습니다"
        case .streamingFailed:
            return "스트리밍 중 오류가 발생했습니다"
        case .invalidData:
            return "잘못된 데이터 형식입니다"
        case .httpError(let code):
            return "HTTP 오류: \(code)"
        }
    }
}
