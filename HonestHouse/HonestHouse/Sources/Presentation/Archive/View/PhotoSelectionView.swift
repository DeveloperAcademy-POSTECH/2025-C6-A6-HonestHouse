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
    
    var body: some View {
        NavigationStack {
            ZStack {
                photoSelectionGridView()
                selectionCompleteButtonView()
            }
            .navigationTitle("카메라 이름")
            .navigationBarTitleDisplayMode(.large)
            .task {
                vm.configure(container: container)
                await vm.fetchFirstPageImage()
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
                            await vm.loadCurrentPage()
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
