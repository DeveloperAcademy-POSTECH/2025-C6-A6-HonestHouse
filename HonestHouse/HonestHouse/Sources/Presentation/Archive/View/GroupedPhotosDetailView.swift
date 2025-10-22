//
//  GroupedPhotosDetailView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct GroupedPhotosDetailView: View {
    let groupedPhotos: GroupedPhotos
    let finalSelectedPhotos: [Photo]
    let onTapGroupedPhoto: (Photo) -> Void
    
    var body: some View {
        TabView {
            ForEach(groupedPhotos.photos) { photo in
                ZStack(alignment: .bottomTrailing) {
                    KFImage(URL(string: photo.url))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    Button(action: { onTapGroupedPhoto(photo) }) {
                        if finalSelectedPhotos.contains(where: { $0.id == photo.id }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 24))
                            }
                        } else {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                }
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
