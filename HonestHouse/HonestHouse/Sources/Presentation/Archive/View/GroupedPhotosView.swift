//
//  GroupedPhotosView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

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
            switch vm.state {
            case .idle:
                Text("그룹화를 시작하려면 잠시 기다려주세요.")
                    .foregroundColor(.gray)
            case .loading:
                ProgressView("이미지 그룹화 중...")
                    .progressViewStyle(.circular)
            case .success(let groupedPhotos):
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(groupedPhotos) { group in
                            GroupedPhotosGridCellView(
                                group: group,
                                selectedPhotosInGroup: vm.selectedPhotosInGroup,
                                onTapGroupedPhoto: toggleGroupedPhotoView
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 32)
                }
            case .failure(let error):
                Text("오류 발생: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
        .task {
            vm.startGrouping()
        }
    }
    
    private func toggleGroupedPhotoView(for photo: Photo) {
        if let index = vm.selectedPhotosInGroup.firstIndex(where: { $0.url == photo.url}) {
            vm.selectedPhotosInGroup.remove(at: index)
        } else {
            vm.selectedPhotosInGroup.append(photo)
        }
    }
}
