//
//  PhotoSelectionView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct PhotoSelectionView: View {
    let columnCount: Int = 3
    let photos = Photo.mockPhotos(count: 20)
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 2), count: columnCount)
    }
    
    @State private var selectedPhotos: [Photo] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(photos) { photo in
                            SelectionGridCellView(
                                item: photo,
                                isSelected: selectedPhotos.contains(where: { $0.url == photo.url }),
                                onTapSelectionGridCell: { toggleGridCell(for: photo) }
                            )
                        }
                    }
                    .padding(.horizontal, 2)
                }
                
                VStack {
                    Spacer()
                    // TODO: 사진이 한 장 이상 선택됐을 때 push 가능하게 수정
                    NavigationLink(destination: GroupedPhotosView(selectedPhotos: photos)) {
                        Text("완료")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.gray)
                            .foregroundStyle(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
            .navigationTitle("카메라 이름")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func toggleGridCell(for photo: Photo) {
        if let index = selectedPhotos.firstIndex(where: { $0.url == photo.url }) {
            selectedPhotos.remove(at: index)
        } else {
            selectedPhotos.append(photo)
        }
    }
}
