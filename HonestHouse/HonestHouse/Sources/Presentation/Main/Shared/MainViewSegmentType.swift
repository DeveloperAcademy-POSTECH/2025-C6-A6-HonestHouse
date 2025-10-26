//
//  MainViewSegmentType.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/26/25.
//

import Foundation

enum MainViewSegmentType {
    case trishot
    case preset
    
    var displayName: String {
        switch self {
        case .trishot:
            return "트라이샷"
        case .preset:
            return "프리셋"
        }
    }
}
