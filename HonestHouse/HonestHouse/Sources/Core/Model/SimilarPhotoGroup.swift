//
//  SimilarPhotoGroup.swift
//  HonestHouse
//
//  Created by Rama on 10/24/25.
//

import SwiftUI

struct SimilarPhotoGroup: Identifiable {
    let id = UUID()
    let photos: [Photo]
    let averageDistance: Float
    let confidence: Float
}
