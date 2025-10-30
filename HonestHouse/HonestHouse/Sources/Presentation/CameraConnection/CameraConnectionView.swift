//
//  CameraConnectionView.swift
//  HonestHouse
//
//  Created by Subeen on 10/27/25.
//

import SwiftUI

struct CameraConnectionView: View {
    var body: some View {
        
        VStack {
            // TODO: - 카메라 연결 시트
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
