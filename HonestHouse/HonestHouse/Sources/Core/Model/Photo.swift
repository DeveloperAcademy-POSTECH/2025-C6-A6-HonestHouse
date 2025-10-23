//
//  Photo.swift
//  HonestHouse
//
//  Created by Rama on 10/23/25.
//

import SwiftUI

struct Photo: Identifiable, SelectableItem {
    let id = UUID()
    var url: String
    var mediaType: MediaType
    
    var thumbnailURL: String? {
        "\(url)?kind=thumbnail"
    }
    
    init(url: String) {
        self.url = url
        let fileExtension = (url as NSString).pathExtension.lowercased()
        switch fileExtension {
        case "jpeg":
            self.mediaType = .jpeg
        case "cr2":
            self.mediaType = .cr2
        case "cr3":
            self.mediaType = .cr3
        default:
            self.mediaType = .unknown
        }
    }
}

extension Photo {
    static func mockPhotos(count: Int) -> [Photo] {
        let baseURL = "https://raw.githubusercontent.com/Rama-Moon/MockImage/main"
        
        return (1...count).map { index in
            Photo(url: "\(baseURL)/photo\(index).JPG")
        }
    }
}
