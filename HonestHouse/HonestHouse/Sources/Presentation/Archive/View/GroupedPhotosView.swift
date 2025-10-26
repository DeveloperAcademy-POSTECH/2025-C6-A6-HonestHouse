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
    @EnvironmentObject var container: DIContainer
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: 2)
    }
    
    init(selectedPhotos: [Photo]) {
        _vm = State(wrappedValue: GroupedPhotosViewModel(selectedPhotos: selectedPhotos))
    }
    
    var body: some View {
        NavigationStack {
            switch vm.state {
            case .idle, .loading:
                ProgressView()
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
            case .failure(let groupingError):
                Color.clear
            }
            
            if showToast {
                ToastView(message: toastMessage, isShowing: $showToast)
                    .transition(.move(edge: .bottom))
            }
        }
        .task {
            vm.configure(container: container)
            vm.startGrouping()
        }
        .onChange(of: vm.state) { _, newState in
            if case .failure(let groupingError) = newState {
                toastMessage = "오류 발생: \(groupingError.localizedDescription)"
                showToast = true
            } else {
                showToast = false
            }
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
