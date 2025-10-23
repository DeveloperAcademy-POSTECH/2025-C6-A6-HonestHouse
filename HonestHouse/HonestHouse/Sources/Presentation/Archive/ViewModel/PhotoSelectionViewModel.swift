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
    var storageName:
    
    let imageOperationsService = ImageOperationsService()
}

extension PhotoSelectionViewModel {
    func getStorageList() async {
        do {
            let storageListResponse = try await imageOperationsService.getStorageList()
            storageList = storageListResponse.toEntity()
        } catch {
            print("storageList를 불러오지 못했습니다.")
        }
    }
    
    func getDirectoryList(storage: String) async {
        do {
            let directoryListResponse = try await imageOperationsService.getDirectoryList(storage: storage)
            directoryList = directoryListResponse.toEntity()
        } catch {
            print("directoryList를 불러오지 못했습니다.")
        }
    }
    
    func getContentList(storage: String, directory: String, type: String, kind: String, page: Int) async {
        do {
            let contentListResponse = try await imageOperationsService.getContentList(storage: storage, directory: directory, type: type, kind: kind, page: page)
        } catch {
            print("contentList를 불러오지 못했습니다.")
        }
    }
    
    func
    
    func fetchImage() async {
        await getStorageList()
        guard let
    }
}
