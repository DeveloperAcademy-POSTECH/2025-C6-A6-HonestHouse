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
        KFImage(URL(string: item.url))
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
