//
//  PhotoSelectionView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct PhotoSelectionView: View {
    @State private var vm = PhotoSelectionViewModel()
    
    let columnCount: Int = 3
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 2), count: columnCount)
    }
    
    @State private var selectedPhotos: [Photo] = []
    @State var viewModel: PhotoSelectionViewModel = .init()
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(vm.mockPhotos) { photo in
                            SelectionGridCellView(
                                item: photo,
                                isSelected: vm.selectedPhotos.contains(where: { $0.url == photo.url }),
                                onTapSelectionGridCell: { vm.toggleGridCell(for: photo) }
                            )
                VStack {
                    Button("Refresh") {
                        Task {
                            await viewModel.fetchFirstPageImage()
                        }
                    }
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(viewModel.entireContentUrls.map { Photo(url: $0) }) { photo in
                                SelectionGridCellView(
                                    item: photo,
                                    isSelected: selectedPhotos.contains(where: { $0.url == photo.url }),
                                    onTapSelectionGridCell: { toggleGridCell(for: photo) }
                                )
                            }
                            
                            if viewModel.hasMore {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .task {
                                        await viewModel.loadCurrentPage()
                                    }
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
                
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
            .navigationTitle("카메라 이름")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.fetchFirstPageImage()
            }
        }
    }
}
