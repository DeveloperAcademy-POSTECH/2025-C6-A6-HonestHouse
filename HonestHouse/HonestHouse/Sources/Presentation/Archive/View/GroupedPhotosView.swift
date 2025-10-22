//
//  GroupedPhotosView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct GroupedPhotos: Identifiable {
    let id = UUID()
    let photos: [Photo]
}

struct GroupedPhotosView: View {
    @State private var vm: GroupedPhotosViewModel
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: 2)
    }
    
    init(selectedPhotos: [Photo]) {
        _vm = State(wrappedValue: GroupedPhotosViewModel(selectedPhotos: selectedPhotos))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(vm.groupedPhotos) { group in
                        groupedPhotosGridCell(group: group)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 32)
            }
        }
    }
    
    private func groupedPhotosGridCell(group: GroupedPhotos) -> some View {
        NavigationLink(
            destination: GroupedPhotosDetailView(
                groupedPhotos: group,
                finalSelectedPhotos: vm.selectedPhotosInGroup,
                onTapGroupedPhoto: toggleGroupedPhoto)
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
    
    private func toggleGroupedPhoto(for photo: Photo) {
        if let index = vm.selectedPhotosInGroup.firstIndex(where: { $0.url == photo.url}) {
            vm.selectedPhotosInGroup.remove(at: index)
        } else {
            vm.selectedPhotosInGroup.append(photo)
        }
    }
}
