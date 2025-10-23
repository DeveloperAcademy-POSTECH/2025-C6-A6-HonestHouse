//
//  PhotoSelectionViewModel.swift
//  HonestHouse
//
//  Created by 이현주 on 10/23/25.
//

import SwiftUI

@Observable
final class PhotoSelectionViewModel {
    var storageList: StorageList?
    var directoryList: DirectoryList?
    var contentList: ContentList?
    
    var presentStorage: String?
    var presentDirectory: String?
    
    var currentPage: Int = 1
    var isLoading: Bool = false
    var hasMore: Bool = true
    var entireContentUrls: [String] = []
    
    let imageOperationsService = ImageOperationsService()
}

extension PhotoSelectionViewModel {
    /// storageListResponse를 받아와서 storageList로 변환
    func getStorageList() async {
        do {
            let storageListResponse = try await imageOperationsService.getStorageList()
            storageList = storageListResponse.toEntity()
        } catch {
            print("storageList를 불러오지 못했습니다.")
        }
    }
    
    /// directoryListResponse를 받아와서 directoryList로 변환
    func getDirectoryList(storage: String) async {
        do {
            let directoryListResponse = try await imageOperationsService.getDirectoryList(storage: storage)
            directoryList = directoryListResponse.toEntity()
        } catch {
            print("directoryList를 불러오지 못했습니다.")
        }
    }
    
    /// contentListResponse를 받아와서 contentList로 변환
    func getContentList(storage: String, directory: String, type: String, kind: String, page: Int) async {
        do {
            let contentListResponse = try await imageOperationsService.getContentList(storage: storage, directory: directory, type: type, kind: kind, page: page)
            contentList = contentListResponse.toEntity()
        } catch {
            print("contentList를 불러오지 못했습니다.")
        }
    }
    
    /// storageList에서 첫번째 storage 가져오기
    func setPresentStorage() async {
        await getStorageList()
        guard
            let storageUrl = storageList?.url?.first,
            let storageName = storageUrl.split(separator: "/").last.map(String.init)
        else {
            print("Storage URL 파싱 실패")
            return
        }
        presentStorage = storageName
    }
    
    /// directoryList에서 첫번째 directory가져오기
    func setPresentDirectory(storage: String) async {
        await getDirectoryList(storage: storage)
        guard
            let dirUrl = directoryList?.url?.first,
            let dirName = dirUrl.split(separator: "/").last.map(String.init)
        else {
            print("Directory URL 파싱 실패")
            return
        }
        presentDirectory = dirName
    }
    
    /// paging처리 초기화
    func resetPaging() {
        currentPage = 1
        hasMore = true
        entireContentUrls.removeAll()
    }
    
    /// 현재 페이지에 해당하는 이미지들 불러오기
    func loadCurrentPage() async {
        guard !isLoading, hasMore else { return }
        guard let storage = presentStorage,
              let directory = presentDirectory else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        // 현재 page의 contentList를 업데이트
        await getContentList(
            storage: storage,
            directory: directory,
            type: "jpeg",
            kind: "thumbnail",
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
}
