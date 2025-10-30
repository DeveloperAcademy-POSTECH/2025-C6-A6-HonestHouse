//
//  PhotoSelectionViewModel.swift
//  HonestHouse
//
//  Created by 이현주 on 10/23/25.
//

import SwiftUI
import Kingfisher

@Observable
final class PhotoSelectionViewModel {
    typealias Success = [String]
    typealias Failure = SelectionError
    
    enum Action {
        case goToGroupedPhoto
    }
    
    private var container: DIContainer
    private var imageOperationsService: ImageOperationsServiceType
    private var imagePrefetchManager: ImagePrefetchManagerType
    
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
    
    // 캐시 관련 변수 (뷰 복원 시 API 재호출 방지)
    private var cachedUrls: [String] = []
    private var isCacheValid: Bool = false
    
    init(container: DIContainer) {
        self.container = container
        self.imageOperationsService = container.services.imageOperationsService
    }
    
}

extension PhotoSelectionViewModel: ArchiveErrorHandleable {
    
    func send(action: Action) {
        switch action {
            
        case .goToGroupedPhoto:
            container.navigationRouter.push(to: .groupedPhotos(selectedPhotos))
        }
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
        do {
            let storageListResponse = try await imageOperationsService.getStorageList()
            storageList = storageListResponse.toEntity()
        } catch {
            throw SelectionError.from(error)
        }
    }
    
    /// directoryListResponse를 받아와서 directoryList로 변환
    func getDirectoryList(storage: String) async throws {
        do {
            let directoryListResponse = try await imageOperationsService.getDirectoryList(storage: storage)
            directoryList = directoryListResponse.toEntity()
        } catch {
            throw SelectionError.from(error)
        }
    }
    
    /// contentListResponse를 받아와서 contentList로 변환
    func getContentList(storage: String, directory: String, type: String, kind: String, page: Int) async throws {
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
        // 캐시가 유효하면 API 호출 없이 복원
        if isCacheValid, !cachedUrls.isEmpty {
            entireContentUrls = cachedUrls
            state = .success(entireContentUrls)
            return
        }

        state = .loading

        do {
            try await setPresentStorage()
            guard let storage = presentStorage else { throw SelectionError.generic }

            try await setPresentDirectory(storage: storage)
            resetPaging()
            try await loadCurrentPage()

            // 캐시 저장
            cachedUrls = entireContentUrls
            isCacheValid = true

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
        // 중복 호출 방지 강화
        guard !isLoading else {
            print("⚠️ [loadCurrentPage] Already loading, skipping...")
            return
        }
        guard hasMore else {
            print("⚠️ [loadCurrentPage] No more pages, skipping...")
            return
        }
        guard let storage = presentStorage,
              let directory = presentDirectory else {
            throw SelectionError.generic
        }

        isLoading = true
        defer {
            isLoading = false
        }

        do {
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

                // 캐시 업데이트
                cachedUrls = entireContentUrls
            } else {
                hasMore = false
            }
        } catch {
            throw error
        }
    }

    // 스크롤 시 추가 로딩 (state 유지)
    func loadCurrentPageSafely() async {
        // 이미 로딩 중이면 스킵 (빠른 스크롤 대비)
        guard !isLoading else {
            return
        }

        do {
            try await loadCurrentPage()
            state = .success(entireContentUrls)
        } catch {
            handleError(error)
        }
    }

    func toggleGridCell(for photo: Photo, at index: Int) {
        if let selectedIndex = selectedPhotos.firstIndex(where: { $0.url == photo.url }) {
            selectedPhotos.remove(at: selectedIndex)
        } else {
            selectedPhotos.append(photo)
        }
    }

    /// 캐시 무효화
    func invalidateCache() {
        cachedUrls.removeAll()
        isCacheValid = false
        imagePrefetchManager.stopAll()
    }

    // MARK: - 완료 버튼 로직

    /// 완료 버튼을 누를 때 호출
    func onCompleteSelection() {
        guard !selectedPhotos.isEmpty else { return }

        print("✅ [Complete] Moving to GroupedView with \(selectedPhotos.count) selected photos")
        print("   - Display images will be prefetched per-group on demand")
    }
}

extension PhotoSelectionViewModel {
    func goToGroupedPhotos() {
        container.navigationRouter.push(to: .groupedPhotos(selectedPhotos))
    }
}
