//
//  GroupedPhotosDetailView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct GroupedPhotosDetailView: View {
    let groupedPhotos: SimilarPhotoGroup
    @Environment(GroupedPhotosViewModel.self) var vm
    /// selectedPhotosInGroup: vm.selectedPhotosInGroup,
   /// onTapGroupedPhoto: vm.toggleGroupedPhotoView
//    let finalSelectedPhotos: [Photo]
//    let onTapGroupedPhoto: (Photo) -> Void
    
    var body: some View {
        TabView {
            groupedImagesView()
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
//        .onDisappear {
//            // DetailView를 나갈 때 메모리 캐시 일부 정리 (메모리 사용량 감소)
//            ImageCache.default.memoryStorage.removeExpired()
//            print("🧹 [GroupedPhotosDetailView] Memory cache cleaned on disappear")
//        }
    }
    
    //MARK: View Component
    private func groupedImagesView() -> some View {
        ForEach(vm.selectedPhotosInGroup) { photo in
            ZStack(alignment: .bottomTrailing) {
                ProgressiveImage(
                    thumbnailURL: photo.thumbnailURL,
                    displayURL: photo.displayURL
                )

                selectionButtonView(photo: photo)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
        }
    }
    
    private func selectionButtonView(photo: Photo) -> some View {
        Button(action: { vm.toggleGroupedPhotoView(for: photo) }) {
            if vm.selectedPhotosInGroup.contains(where: { $0.id == photo.id }) {
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
    }
}
