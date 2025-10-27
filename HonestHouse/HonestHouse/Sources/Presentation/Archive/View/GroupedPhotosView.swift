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
            switch vm.groupingState {
            case .idle, .loading:
                ProgressView()
            case .success(let groupedPhotos):
                groupedPhotosGridView(groupedPhotos: groupedPhotos)
                selectionCompleteButtonView()
            case .failure(_):
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
        .onChange(of: vm.groupingState) { _, newState in
            if case .failure(let groupingError) = newState {
                toastMessage = "오류 발생: \(groupingError.localizedDescription)"
                showToast = true
            } else {
                showToast = false
            }
        }
    }
    
    private func groupedPhotosGridView(groupedPhotos: [SimilarPhotoGroup]) -> some View {
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
    }
    
    private func toggleGroupedPhotoView(for photo: Photo) {
        if let index = vm.selectedPhotosInGroup.firstIndex(where: { $0.url == photo.url}) {
            vm.selectedPhotosInGroup.remove(at: index)
        } else {
            vm.selectedPhotosInGroup.append(photo)
        }
    }
    
    private func selectionCompleteButtonView() -> some View {
        VStack {
            Spacer()
            if !vm.selectedPhotosInGroup.isEmpty {
                Button {
                    vm.saveSelectedPhotos()
                } label: {
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
    }
}

