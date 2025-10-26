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
    }
}
