//
//  PhotoSelectionDetailView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct PhotoSelectionDetailView: View {
    let photo: Photo
    
    var body: some View {
            KFImage(URL(string: photo.url))
                .resizable()
                .aspectRatio(contentMode: .fit)
    }
}
