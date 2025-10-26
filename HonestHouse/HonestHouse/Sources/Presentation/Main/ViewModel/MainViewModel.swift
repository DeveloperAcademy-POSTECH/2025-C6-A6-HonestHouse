//
//  MainViewModel.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/24/25.
//

import SwiftUI

@Observable
final class MainViewModel {
    var selectedSegment: MainViewSegmentType = .trishot
    var segments: [MainViewSegmentType] = [.trishot, .preset]
}
