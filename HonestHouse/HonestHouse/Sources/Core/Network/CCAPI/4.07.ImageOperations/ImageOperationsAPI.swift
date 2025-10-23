//
//  ImageOperationsAPI.swift
//  HonestHouse
//
//  Created by 이현주 on 10/23/25.
//

import Foundation

enum ImageOperationsAPI {
    case storage
    case directory(String)
    case contentList(String, String)
    
    var apiDesc: String {
        switch self {
        case .storage:
            "ver100/contents"
            
        case .directory(let storage):
            "ver100/contents/\(storage)"
            
        case .contentList(let storage, let directory):
            "ver100/contents/\(storage)/\(directory)"
        }
    }
}
