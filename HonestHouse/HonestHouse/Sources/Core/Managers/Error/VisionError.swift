//
//  VisionError.swift
//  HonestHouse
//
//  Created by Rama on 10/26/25.
//

import Foundation

enum VisionError: Error, LocalizedError {
    case cgImageConversion(url: String)
    case observation(url: String)
    case imageFetching(url: String, underlyingError: Error)
    case partialAnalysis(failedPhotos: [Photo], errors: [Error])
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .cgImageConversion(url: let url):
            return "Error: Failed to convert CGImage for \(url)"
        case .observation(url: let url):
            return "Error: Failed to perform vision observation for \(url)"
        case .imageFetching(url: let url, underlyingError: let underlyingError):
            return "Error: Failed to fetch image from \(url). Underlying error: \(underlyingError)"
        case .partialAnalysis(failedPhotos: let failedPhotos, errors: let errors):
            return "Error: Partial analysis. \(failedPhotos.count) failed, with errors: \(errors)"
        case .unknown:
            return "Error: Unknown error"
        }
    }
}
