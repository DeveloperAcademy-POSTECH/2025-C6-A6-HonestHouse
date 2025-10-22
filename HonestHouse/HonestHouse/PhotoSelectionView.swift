//
//  PhotoSelectionView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct Photo: Identifiable {
    let id = UUID()
    let url: String
    
    static func mockPhotos(count: Int) -> [Photo] {
        let baseURL = "https://raw.githubusercontent.com/Rama-Moon/MockImage/main"
        
        return (1...count).map { index in
            Photo(url: "\(baseURL)/photo\(index).JPG")
        }
    }
}

struct PhotoGridView: View {
    let columnCount: Int = 3
    let photos = Photo.mockPhotos(count: 20)
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 2), count: columnCount)
    }
    
    @State private var selectedPhotoURLs: [String] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(photos) { photo in
                            PhotoGridCell(
                                photo: photo,
                                isSelected: selectedPhotoURLs.contains(photo.url),
                                onTap: {
                                    toggleSelection(for: photo)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 2)
                }
                
                VStack {
                    Spacer()
                    // TODO: 사진이 한 장 이상 선택됐을 때 push 가능하게 수정
                    NavigationLink(destination: GroupedPhotosView(selectedPhotoURLs: $selectedPhotoURLs)) {
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
    
    private func toggleSelection(for photo: Photo) {
        if let index = selectedPhotoURLs.firstIndex(of: photo.url) {
            selectedPhotoURLs.remove(at: index)
        } else {
            selectedPhotoURLs.append(photo.url)
        }
    }
}

struct PhotoGridCell: View {
    let photo: Photo
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationLink(destination: PhotoDetailView(photo: photo)) {
                KFImage(URL(string: photo.url))
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .overlay(isSelected ? Color.black.opacity(0.3) : Color.clear)
            }
            
            Button(action: onTap) {
                if isSelected {
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
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
    }
}
