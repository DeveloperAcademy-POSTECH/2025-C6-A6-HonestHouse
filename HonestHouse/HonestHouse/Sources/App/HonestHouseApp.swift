//
//  HonestHouseApp.swift
//  HonestHouse
//
//  Created by Rama on 10/11/25.
//

import SwiftUI

@main
struct HonestHouseApp: App {
    
    @State var container = DIContainer(services: Services())
    
    var body: some Scene {
        WindowGroup {
            PhotoSelectionView()
        }
    }
}


