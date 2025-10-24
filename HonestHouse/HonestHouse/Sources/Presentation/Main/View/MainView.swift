//
//  MainView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/24/25.
//

import SwiftUI

struct MainView: View {
    @State var viewModel: MainViewModel = .init()
    
    var body: some View {
        VStack {
            cameraAndArchiveHeaderView()
            Spacer().frame(height: 18)
            segmentedControlView()
            Spacer().frame(height: 27)
            // TODO: 트라이샷, 프리셋 뷰 연결 필요
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func cameraAndArchiveHeaderView() -> some View {
        HStack {
            Button {
                // TODO: 카메라 설정 뷰 연결
            } label: {
                Image(systemName: "camera.badge.ellipsis")
            }
            Spacer()
            Button {
                // TODO: 아카이빙 뷰 연결
            } label: {
                Image(systemName: "square.grid.2x2")
            }
        }
        .foregroundStyle(.black)
    }
    
    
    private func segmentedControlView() -> some View {
        VStack {
            Picker("", selection: $viewModel.selectedSegment) {
                ForEach(viewModel.segments, id: \.self) {
                    Text($0.displayName)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(4)
            }
            .pickerStyle(.segmented)
        }
    }
}

#Preview {
    MainView()
}

