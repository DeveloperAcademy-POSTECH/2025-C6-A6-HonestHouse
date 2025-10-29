//
//  SelectionGridCellView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct SelectionGridCellView<Item: SelectableItem>: View {
    let item: Item
    let isSelected: Bool
    let onTapSelectionGridCell: () -> Void
    let onPrefetchForDetailView: (() -> Void)?
    let onAppear: (() -> Void)?

    init(
        item: Item,
        isSelected: Bool,
        onTapSelectionGridCell: @escaping () -> Void,
        onPrefetchForDetailView: (() -> Void)? = nil,
        onAppear: (() -> Void)? = nil
    ) {
        self.item = item
        self.isSelected = isSelected
        self.onTapSelectionGridCell = onTapSelectionGridCell
        self.onPrefetchForDetailView = onPrefetchForDetailView
        self.onAppear = onAppear
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationLink(destination: PhotoSelectionDetailView(item: item)) {
                CachedThumbnailImage(url: item.thumbnailURL)
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()
                    .overlay(isSelected ? Color.black.opacity(0.3) : Color.clear)
            }
            .simultaneousGesture(
                TapGesture().onEnded {
                    // NavigationLink 탭 시 즉시 DetailView용 이미지 prefetch
                    onPrefetchForDetailView?()
                }
            )
            
            Button(action: onTapSelectionGridCell) {
                Group {
                    ZStack(alignment: .bottomTrailing) {
                        if isSelected {
                            Circle()
                                .fill(Color.white)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 24))
                        } else { Circle().fill(Color.white) }
                    }
                }
                .frame(width: 24, height: 24)
                .padding(.top, 24)
                .padding(.leading, 24)
            }
            .frame(width: 80, height: 80)
            .contentShape(Rectangle())
        }
        .onAppear {
            // 화면에 보이는 즉시 해당 이미지 prefetch
            onAppear?()
        }
    }
}
