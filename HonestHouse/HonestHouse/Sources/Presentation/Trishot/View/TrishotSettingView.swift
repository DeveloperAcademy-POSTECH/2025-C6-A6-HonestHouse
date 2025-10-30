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
            ForEach(vm.trishotItems.indices) { index in
                presetView(vm.trishotItems[index], index)
            }
        }
    }
    
    // 프리셋 타이틀 + 내용
    func presetView(_ item: TrishotItem, _ index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            titleView(name: item.preset.name)
            contentView(item, index)
        }
        .onTapGesture {
            vm.send(action: .togglePreset(item.id))
        }
    }
    
    // 프리셋 타이틀
    func titleView(name: String) -> some View {
        
        Button {
            vm.send(action: .goToTrishotSelection)
            
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
    func contentView(_ item: TrishotItem, _ index: Int) -> some View {
        HStack {
            contentSettingsView(item.preset)
            Spacer()
            contentCircleView(num: index + 1)
        }
        .environment(\.layoutDirection, item.isSelected ? .leftToRight : .rightToLeft)
        .animation(.default, value: item.isSelected)
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
    
    func filterIcon(iso: ISO) -> some View {
        Image("")
    }
    
    func shootingModeIcon() -> some View {
        Image("")
    }
    
    func blueAmberIcon() -> some View {
        Image("")
    }
    
    func exposureIcon() -> some View {
        Image("")
    }
    
    func tintIcon() -> some View {
        Image("")
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
