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
    
    @State private var selectedPhotos: [Photo] = []
    @State var viewModel: PhotoSelectionViewModel = .init()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Button("Refresh") {
                        Task {
                            await viewModel.loadCurrentPage()
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
                    // TODO: 사진이 한 장 이상 선택됐을 때 push 가능하게 수정
                    NavigationLink(
                        destination: GroupedPhotosView(selectedPhotos: selectedPhotos),
                    ) {
                        Text("완료")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.gray)
                            .foregroundStyle(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(selectedPhotos.isEmpty)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
            .navigationTitle("카메라 이름")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.fetchFirstPageImage()
            }
        }
    }
    
    //TODO: ViewModel 생성 후 이동
    private func toggleGridCell(for photo: Photo) {
        if let index = selectedPhotos.firstIndex(where: { $0.url == photo.url }) {
            selectedPhotos.remove(at: index)
        } else {
            selectedPhotos.append(photo)
        }
    }
}
