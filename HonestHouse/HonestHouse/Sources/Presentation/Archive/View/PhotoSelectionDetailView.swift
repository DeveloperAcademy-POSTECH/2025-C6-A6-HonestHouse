//
//  PhotoSelectionDetailView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct PhotoSelectionDetailView<Item: SelectableItem>: View {
    let item: Item

    var body: some View {
        ProgressiveImage(
            thumbnailURL: item.thumbnailURL,
            displayURL: item.url
        )
        .onDisappear {
            // DetailView를 나갈 때 메모리 캐시 일부 정리 (메모리 사용량 감소)
            ImageCache.default.memoryStorage.removeExpired()
            print("🧹 [PhotoSelectionDetailView] Memory cache cleaned on disappear")
        }
    }
}
