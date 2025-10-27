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
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 2), count: columnCount)
    }
    
    @State var vm: PhotoSelectionViewModel = .init()
    @EnvironmentObject var container: DIContainer
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                switch vm.state {
                case .idle, .loading:
                    ProgressView("사진을 불러오는 중...")
                    
                case .success:
                    ZStack {
                        photoSelectionGridView()
                        selectionCompleteButtonView()
                    }
                    
                case .failure(_):
                    Color.clear
                }
                
                if showToast {
                    ToastView(message: toastMessage, isShowing: $showToast)
                        .transition(.move(edge: .bottom))
                }
            }
            .navigationTitle("카메라 이름")
            .navigationBarTitleDisplayMode(.large)
            .task {
                vm.configure(container: container)
                await vm.fetchFirstPageImage()
            }
            .onChange(of: vm.state) { _, newState in
                if case .failure(let error) = newState {
                    toastMessage = "\(error.errorDescription)"
                    showToast = true
                } else {
                    showToast = false
                }
            }
        }
    }
    
    private func photoSelectionGridView() -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(vm.entireContentUrls.map { Photo(url: $0) }) { photo in
                    SelectionGridCellView(
                        item: photo,
                        isSelected: vm.selectedPhotos.contains(where: { $0.id == photo.id }),
                        onTapSelectionGridCell: { vm.toggleGridCell(for: photo) }
                    )
                }
                
                if vm.hasMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .task {
                            await vm.loadCurrentPageSafely()
                        }
                }
            }
            .padding(.horizontal, 2)
        }
    }
    
    private func selectionCompleteButtonView() -> some View {
        VStack {
            Spacer()
            if !vm.selectedPhotos.isEmpty {
                NavigationLink(destination: GroupedPhotosView(selectedPhotos: vm.selectedPhotos)) {
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
