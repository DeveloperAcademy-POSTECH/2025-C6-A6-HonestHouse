//
//  RemoteControllerViewModel.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation
import SwiftUI

@Observable
final class TrishotSettingViewModel {
    var container: DIContainer
    
    var selectedTrishot: [Preset:Bool] = [.stub1 : true, .stub2 : false, .stub3 : false ]
    
    enum Action {
        case goToTrishotSelection
        case togglePreset(Preset)
    }
    
    init(container: DIContainer) {
        self.container = container
    }
}

extension TrishotSettingViewModel {
    func send(action: Action) {
        switch action {
        case .goToTrishotSelection:
            container.navigationRouter.push(to: .trishotSelection)
        case .togglePreset(let preset):
            selectedTrishot[preset]?.toggle()
        }
    }
}
