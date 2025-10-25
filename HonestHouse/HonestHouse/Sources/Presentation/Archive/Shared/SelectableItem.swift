//
//  SelectableItem.swift
//  HonestHouse
//
//  Created by Rama on 10/23/25.
//

import Foundation

protocol SelectableItem: Identifiable {
    var url: String { get }
    var mediaType: MediaType { get }
    var thumbnailURL: String { get }
    var displayURL: String { get }
}
