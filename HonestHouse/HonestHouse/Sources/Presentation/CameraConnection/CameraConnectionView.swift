//
//  CameraConnectionView.swift
//  HonestHouse
//
//  Created by Subeen on 10/27/25.
//

import SwiftUI

struct CameraConnectionView: View {
    var body: some View {
        
        NavigationStack {
            NavigationLink("연결") {
                connectionView
            }
            
        
            NavigationLink("컨트롤") {
                RemoteControllerView()
            }
        }
        
    }
    
    var connectionView: some View {
        VStack {
            Button {
                NetworkManager.shared.configure(cameraIP: "192.168.1.2", port: 443)
                Task {
                    try await NetworkManager.shared.initializeAuthentication()
                }
            } label: {
                Text("connect to camera")
            }
        }
    }
}

#Preview {
    CameraConnectionView()
}
