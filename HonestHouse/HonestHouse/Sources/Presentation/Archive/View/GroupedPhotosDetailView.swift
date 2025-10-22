//
//  GroupedPhotosDetailView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct GroupedPhotosDetailView: View {
    var body: some View {
        VStack {
            KFImage(URL(string: "https://raw.githubusercontent.com/Rama-Moon/MockImage/main/photo1.JPG"))
                .frame(maxWidth: .infinity)
                .imageScale(.large)
                .padding(16)
        }

    }
}
