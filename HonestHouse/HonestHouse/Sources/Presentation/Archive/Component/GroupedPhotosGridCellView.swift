//
//  GroupedPhotosGridCellView.swift
//  HonestHouse
//
//  Created by Rama on 10/25/25.
//

import SwiftUI
import Kingfisher

struct GroupedPhotosGridCellView: View {
    let group: SimilarPhotoGroup
    let selectedPhotosInGroup: [Photo]
    let onTapGroupedPhoto: (Photo) -> Void
    
    var body: some View {
        NavigationLink(
            destination: GroupedPhotosDetailView(
                groupedPhotos: group,
                finalSelectedPhotos: selectedPhotosInGroup,
                onTapGroupedPhoto: onTapGroupedPhoto)
        ) {
            if let firstPhoto = group.photos.first {
                KFImage(URL(string: firstPhoto.url))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 160, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        ZStack(alignment: .topTrailing) {
                            Text("\(group.photos.count)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                                .padding(8)
                        }
                    )
            }
        }
    }
}
