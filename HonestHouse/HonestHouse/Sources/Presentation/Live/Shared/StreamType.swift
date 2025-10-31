//
//  StreamType.swift
//  HonestHouse
//
//  Created by Rama on 10/29/25.
//

import Foundation

enum ScrollType {
    case scroll
    case scrollDetail
    
    var endpoint: String {
        switch self {
        case .scroll: return "/shooting/liveview/scroll"
        case .scrollDetail: return "/shooting/liveview/scrolldetail"
        }
    }
}
