//
//  RemoteControllerView.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import SwiftUI

struct TrishotSettingView: View {
    
    @State var vm: TrishotSettingViewModel
    
    var body: some View {
        ZStack {
            Color.g12.ignoresSafeArea(.all)
            VStack {
                presetListView()
                Spacer()
                startButtonView()
            }
        }
    }
    
    // 프리셋 3개 목록 (트라이샷)
    func presetListView() -> some View {
        VStack(spacing: 32) {
            ForEach(Array(vm.selectedTrishot.keys), id: \.id) { preset in
                presetView(preset)
            }
        }
    }
    
    // 프리셋 타이틀 + 내용
    func presetView(_ preset: Preset) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            titleView(name: preset.name)
            contentView(preset)
        }
        .onTapGesture {
            vm.send(action: .togglePreset(preset))
        }
    }
    
    // 프리셋 타이틀
    func titleView(name: String) -> some View {
        
        Button {
            vm.send(action: .goToTrishotSelection)
            checkFontFile()
        } label: {
            HStack {
                Text(name)
                    .font(.title3)
                    .foregroundStyle(Color.g0)
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.g7)
                
            }
        }
    }
    
    // 프리셋 내용
    func contentView(_ preset: Preset) -> some View {
        HStack {
            contentSettingsView(preset)
            Spacer()
            contentCircleView(num: 1)
        }
        .environment(\.layoutDirection, vm.selectedTrishot[preset] == true ? .leftToRight : .rightToLeft)
        .animation(.default, value: vm.selectedTrishot[preset])
        .background(Color.g11)
        .clipShape(RoundedRectangle(cornerRadius: 100))
    }
    
    // 프리셋 내용 - 세팅 종류
    func contentSettingsView(_ preset: Preset) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle().frame(width: 32, height: 32).foregroundStyle(Color.blue)
                Circle().frame(width: 32, height: 32).foregroundStyle(Color.white)
                Circle().frame(width: 32, height: 32).foregroundStyle(Color.white)
                Circle().frame(width: 32, height: 32).foregroundStyle(Color.white)
                Circle().frame(width: 32, height: 32).foregroundStyle(Color.white)
            }
            Text(preset.settingsDescription)
                .foregroundStyle(Color.g0)
                .font(.num4)
                
        }
        .frame(maxWidth: .infinity)
        .environment(\.layoutDirection, .leftToRight)
        .padding(.leading, 39)
        
    }
    
    // 프리셋 내용 - 원
    func contentCircleView(num: Int) -> some View {
        Circle()
            .stroke(lineWidth: 0.5)
            .frame(width: 110, height: 110)

            .overlay {
                Text("\(num)")
                    .font(.num1)
            }
            .padding(.vertical, 6)
            .padding(.trailing, 8)
            .foregroundStyle(Color.yellow1)
    }
    
    func startButtonView() -> some View {
        Button {
            
        } label: {
            Text("시작하기")
                .font(.labelL)
                .foregroundStyle(Color.g12)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color.g0)
                .clipShape(RoundedRectangle(cornerRadius: 62))
        }
    }
}

#Preview {
    TrishotSettingView(vm: .init(container: .stub))
}
