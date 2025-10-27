//
//  PhotoManager.swift
//  HonestHouse
//
//  Created by Rama on 10/27/25.
//

import Foundation
import Photos

final class PhotoKitManager: PhotoManagerType {
    private let imageLoader = ImageLoader()
    
    func savePhotos(photos: [Photo], albumName: String) async throws {
        try await requestAuthorization()
        let album = try await getOrCreateAlbum(albumName: albumName)
        for photo in photos {
            let imageData = try await fetchImageData(from: photo)
            try await saveImageData(imageData, to: album)
        }
    }
    
    private func requestAuthorization() async throws {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            return
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            if newStatus != .authorized && newStatus != .limited {
                throw PhotoError.authorizationDenied
            }
        case .denied:
            throw PhotoError.authorizationDenied
        case .restricted:
            throw PhotoError.authorizationRestricted
        default:
            throw PhotoError.unknown
        }
    }
    
    private func getOrCreateAlbum(albumName: String) async throws -> PHAssetCollection {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let album = collections.firstObject { return album }

        var albumPlaceholder: PHObjectPlaceholder?
        
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                albumPlaceholder = request.placeholderForCreatedAssetCollection
            }
            if let albumPlaceholder = albumPlaceholder,
               let createdAlbum = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers:
                                                                            [albumPlaceholder.localIdentifier], options: nil).firstObject {
                return createdAlbum
            } else {
                throw PhotoError.albumCreationFailed
            }
        } catch {
            throw PhotoError.albumCreationFailed
        }
    }
    
    private func fetchImageData(from photo: Photo) async throws -> Data {
        let image = try await imageLoader.fetchUIImage(from: photo.url)
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            throw PhotoError.imageDataMissing
        }
        
        return imageData
    }
    
    private func saveImageData(_ data: Data, to album: PHAssetCollection) async throws {
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: data, options: nil)
                if let assetPlaceholder = creationRequest.placeholderForCreatedAsset,
                   let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) {
                    let assets: NSArray = [assetPlaceholder]
                    albumChangeRequest.addAssets(assets)
                }
            }
        } catch {
            throw PhotoError.photoSaveFailed(error)
        }
    }
}

