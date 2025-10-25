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
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationLink(destination: PhotoSelectionDetailView(item: item)) {
                KFImage(URL(string: item.thumbnailURL))
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()
                    .overlay(isSelected ? Color.black.opacity(0.3) : Color.clear)
            }
            
            Button(action: onTapSelectionGridCell) {
                if isSelected {
                    ZStack(alignment: .bottomTrailing) {
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
            .frame(width: 66, height: 66)
            .contentShape(Rectangle())
        }
    }
}
