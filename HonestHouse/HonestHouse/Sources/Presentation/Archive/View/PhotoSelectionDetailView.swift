//
//  PhotoSelectionDetailView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct PhotoSelectionDetailView<Item: SelectableItem>: View {
    let item: Item

    var body: some View {
        ProgressiveImage(
            thumbnailURL: item.thumbnailURL,
            originalURL: item.url
        )
    }
}
