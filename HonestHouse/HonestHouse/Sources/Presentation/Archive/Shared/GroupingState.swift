//
//  GroupingState.swift
//  HonestHouse
//
//  Created by Rama on 10/25/25.
//

import SwiftUI

enum GroupingState {
    case idle
    case loading
    case success([SimilarPhotoGroup])
    case failure(Error)
}
