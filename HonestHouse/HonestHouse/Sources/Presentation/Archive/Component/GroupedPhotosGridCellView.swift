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

    var body: some View {
        NavigationLink(
            destination: GroupedPhotosDetailView(
                groupedPhotos: group
//                finalSelectedPhotos: selectedPhotosInGroup,
//                onTapGroupedPhoto: onTapGroupedPhoto
            )
        ) {
            if let firstPhoto = group.photos.first {
                CachedThumbnailImage(
                    url: firstPhoto.url,  // 원본 URL 사용 (1200x1200으로 다운샘플링됨)
                    size: CGSize(width: 400, height: 300),
                    cornerRadius: 12
                )
                .aspectRatio(contentMode: .fill)
                .frame(width: 160, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                // 그룹 내 사진 개수 표시
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
        .simultaneousGesture(
            TapGesture().onEnded {
                // NavigationLink 탭 시 즉시 그룹 내 이미지들 prefetch
                onPrefetchForDetailView?()
            }
        )
    }
}
