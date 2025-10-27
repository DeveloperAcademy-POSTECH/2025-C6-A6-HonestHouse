//
//  PhotoManagerType.swift
//  HonestHouse
//
//  Created by Rama on 10/27/25.
//

import Foundation

protocol PhotoManagerType {
    func savePhotos(photos: [Photo], albumName: String) async throws
}
