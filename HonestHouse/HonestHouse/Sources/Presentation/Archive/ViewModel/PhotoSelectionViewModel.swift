//
//  PhotoSelectionViewModel.swift
//  HonestHouse
//
//  Created by 이현주 on 10/23/25.
//

import SwiftUI

@Observable
final class PhotoSelectionViewModel {
    typealias Success = [String]
    typealias Failure = SelectionError
    var state: ArchiveState<Success, Failure> = .idle
    
    var storageList: StorageList?
    var directoryList: DirectoryList?
    var contentList: ContentList?
    
    var presentStorage: String?
    var presentDirectory: String?
    
    var currentPage: Int = 1
    var isLoading: Bool = false
    var hasMore: Bool = true
    var entireContentUrls: [String] = []
    
    var selectedPhotos: [Photo] = []
    
    private var imageOperationsService: ImageOperationsServiceType?
    
}

extension PhotoSelectionViewModel: ArchiveErrorHandleable {
    func configure(container: DIContainer) {
        guard self.imageOperationsService == nil else { return }
        self.imageOperationsService = container.services.imageOperationsService
    }
    
    func handleError(_ error: Error) {
        if let selectionError = error as? SelectionError {
            state = .failure(selectionError)
        } else {
            state = .failure(SelectionError.from(error))
        }
    }
    
    /// storageListResponse를 받아와서 storageList로 변환
    func getStorageList() async throws {
        guard let imageOperationsService = imageOperationsService else {
            throw SelectionError.generic
        }
        
        do {
            let storageListResponse = try await imageOperationsService.getStorageList()
            storageList = storageListResponse.toEntity()
        } catch {
            throw SelectionError.from(error)
        }
    }
    
    /// directoryListResponse를 받아와서 directoryList로 변환
    func getDirectoryList(storage: String) async throws {
        guard let imageOperationsService = imageOperationsService else {
            throw SelectionError.generic
        }
        
        do {
            let directoryListResponse = try await imageOperationsService.getDirectoryList(storage: storage)
            directoryList = directoryListResponse.toEntity()
        } catch {
            throw SelectionError.from(error)
        }
    }
    
    /// contentListResponse를 받아와서 contentList로 변환
    func getContentList(storage: String, directory: String, type: String, kind: String, page: Int) async throws {
        guard let imageOperationsService = imageOperationsService else {
            throw SelectionError.generic
        }
        
        do {
            let contentListResponse = try await imageOperationsService.getContentList(storage: storage, directory: directory, type: type, kind: kind, page: page)
            contentList = contentListResponse.toEntity()
        } catch {
            throw SelectionError.from(error)
        }
    }
    
    /// storageList에서 첫번째 storage 가져오기
    func setPresentStorage() async throws {
        try await getStorageList()
        guard
            let storageUrl = storageList?.url?.first,
            let storageName = storageUrl.split(separator: "/").last.map(String.init)
        else {
            throw SelectionError.generic
        }
        presentStorage = storageName
    }
    
    /// directoryList에서 첫번째 directory가져오기
    func setPresentDirectory(storage: String) async throws {
        try await getDirectoryList(storage: storage)
        guard
            let dirUrl = directoryList?.url?.first,
            let dirName = dirUrl.split(separator: "/").last.map(String.init)
        else {
            throw SelectionError.generic
        }
        presentDirectory = dirName
    }
    
    /// 전체 페이지 초기화 및 1페이지 로딩 (state 전환)
    func fetchFirstPageImage() async {
        
        state = .loading
        
        do {
            try await setPresentStorage()
            guard let storage = presentStorage else { throw SelectionError.generic }
            
            try await setPresentDirectory(storage: storage)
            resetPaging()
            try await loadCurrentPage()
            
            state = .success(entireContentUrls)
        } catch {
            handleError(error)
        }
    }
    
    /// paging처리 초기화
    func resetPaging() {
        currentPage = 1
        hasMore = true
        entireContentUrls.removeAll()
    }
    
    /// 현재 페이지에 해당하는 이미지들 불러오기 (state 관여 x)
    func loadCurrentPage() async throws {
        guard !isLoading, hasMore else { return }
        guard let storage = presentStorage,
              let directory = presentDirectory else { throw SelectionError.generic }
        
        isLoading = true
        defer { isLoading = false }
        
        // 현재 page의 contentList를 업데이트
        
        try await getContentList(
            storage: storage,
            directory: directory,
            type: "jpeg",
            kind: "list",
            page: currentPage
        )
        
        // contentList에 append
        if let urls = contentList?.url, !urls.isEmpty {
            entireContentUrls.append(contentsOf: urls)
            currentPage += 1
        } else {
            hasMore = false
        }
    }
    
    // 스크롤 시 추가 로딩 (state 유지)
    func loadCurrentPageSafely() async {
        do {
            try await loadCurrentPage()
            state = .success(entireContentUrls)
        } catch {
            handleError(error)
        }
    }
    
    func toggleGridCell(for photo: Photo) {
        if let index = selectedPhotos.firstIndex(where: { $0.url == photo.url }) {
            selectedPhotos.remove(at: index)
        } else {
            selectedPhotos.append(photo)
        }
    }
}
