//
//  GroupedPhotosView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI

struct GroupedPhotosView: View {
    @State private var vm = GroupedPhotosViewModel()
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: 2)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    // TODO: Vision 사용한 그룹핑 이후 그룹에 대해 for문 순회하게 수정
                    ForEach(vm.selectedPhotos) { photo in
                        groupedPhotosGridCell(groupedPhotos: photo)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 32)
            }
        }
    }
    
    private func groupedPhotosGridCell(groupedPhotos: Photo) -> some View {
        NavigationLink(destination: GroupedPhotosDetailView()) {
            Image(systemName: "checkmark")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding(.horizontal, 68)
                .padding(.vertical, 52)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    GroupedPhotosView()
}
