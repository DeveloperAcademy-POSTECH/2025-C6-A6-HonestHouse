//
//  ImageLoader.swift
//  HonestHouse
//
//  Created by Rama on 10/24/25.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private init() {}
    
    func fetchUIImage(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw ImageLoadingError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ImageLoadingError.networkError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        guard let image = UIImage(data: data) else {
            throw ImageLoadingError.invalidImageData
        }
        
        return image
    }
    
    func fetchImageData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw ImageLoadingError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ImageLoadingError.networkError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        return data
    }
}
