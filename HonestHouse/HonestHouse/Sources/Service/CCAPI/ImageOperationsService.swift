//
//  ImageOperationsService.swift
//  HonestHouse
//
//  Created by 이현주 on 10/23/25.
//

import Combine
import CombineMoya
import Moya

protocol ImageOperationsServiceType {
    /// storageList 조회
    func getStorageList() async throws -> ImageOperations.StorageListResponse
    
    /// directoryList 조회
    func getDirectoryList(storage: String) async throws -> ImageOperations.DirectoryListResponse
    
    /// contentList(이미지 리스트) 조회
    func getContentList(storage: String, directory: String, type: String, kind: String, page: Int) async throws -> ImageOperations.ContentListResponse
}

final class ImageOperationsService: BaseService, ImageOperationsServiceType {
    // MARK: - GET list of storage URLs
    func getStorageList() async throws -> ImageOperations.StorageListResponse {
        let response = try await requestWithRetry(ImageOperationsTarget.getStorageList, decoding: ImageOperations.StorageListResponse.self)
        
        return response
    }

    // MARK: - GET list of storage directorie URLs
    func getDirectoryList(storage: String) async throws -> ImageOperations.DirectoryListResponse {
        let response = try await requestWithRetry(ImageOperationsTarget.getDirectoryList(storage), decoding: ImageOperations.DirectoryListResponse.self)
        
        return response
    }
    
    // MARK: - GET list of Content URLs
    func getContentList(storage: String, directory: String, type: String, kind: String, page: Int) async throws -> ImageOperations.ContentListResponse {
        let response = try await requestWithRetry(ImageOperationsTarget.getContentList(storage, directory, type, kind, page), decoding: ImageOperations.ContentListResponse.self)
        
        return response
    }
}
