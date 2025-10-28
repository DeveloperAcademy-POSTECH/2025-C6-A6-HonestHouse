//
//  LiveViewArea.swift
//  CCAPI_test
//
//  Created by Subeen on 10/27/25.
//

import SwiftUI

struct LiveViewArea: View {
    @StateObject var viewModel = CanonLiveViewStreamAuth()
    @State private var isConnected = false
    @State private var errorMessage: String?
    
    var body: some View {
        
        VStack(spacing: 20) {
            if let image = viewModel.currentImage {
                // 이 이미지는 자동으로 계속 업데이트됨!
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("라이브뷰 대기 중")
                    .foregroundColor(.gray)
            }
            
            // 연결 상태 표시
            Text("상태: \(viewModel.connectionStatus.description)")
                .font(.caption)
                .foregroundColor(isConnected ? .green : .orange)
            
            // FPS 표시
            if viewModel.isStreaming {
                Text("FPS: \(String(format: "%.1f", viewModel.fps))")
                    .font(.caption)
            }
            
            // 에러 메시지 표시
            if let error = errorMessage {
                Text("에러: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            HStack(spacing: 15) {
                Button {
                    Task {
                        await connectCamera()
                    }
                } label: {
                    Text(isConnected ? "연결됨" : "카메라 연결")
                        .padding()
                        .background(isConnected ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(isConnected)
                
                Button {
                    Task {
                        await startLiveView()
                    }
                } label: {
                    Text(viewModel.isStreaming ? "스트리밍 중" : "라이브뷰 시작")
                        .padding()
                        .background(viewModel.isStreaming ? Color.orange : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!isConnected || viewModel.isStreaming)
                
                Button {
                    Task {
                        await stopLiveView()
                    }
                } label: {
                    Text("중지")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!viewModel.isStreaming)
            }
        }
        .padding()
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func connectCamera() async {
        errorMessage = nil
        
        do {
            // 1. NetworkManager 설정 (기존 API 호출용)
            NetworkManager.shared.configure(cameraIP: "192.168.1.2", port: 443)
            try await NetworkManager.shared.initializeAuthentication()
            
            // 2. CanonLiveViewStreamAuth 설정 (라이브뷰용)
            try await viewModel.configureCamera(
                ipAddress: "192.168.1.2",
                port: 443, 
                username: "",
                password: ""
            )
            
            isConnected = true
            print("✅ 카메라 연결 성공")
        } catch {
            errorMessage = "연결 실패: \(error.localizedDescription)"
            print("❌ 카메라 연결 실패: \(error)")
        }
    }
    
    @MainActor
    private func startLiveView() async {
        guard isConnected else {
            errorMessage = "먼저 카메라를 연결하세요"
            return
        }
        
        errorMessage = nil
        
        do {
            try await viewModel.startLiveView(size: "medium", display: "on")
            print("✅ 라이브뷰 시작 성공")
        } catch {
            errorMessage = "라이브뷰 시작 실패: \(error.localizedDescription)"
            print("❌ 라이브뷰 시작 실패: \(error)")
        }
    }
    
    @MainActor
    private func stopLiveView() async {
        await viewModel.stopLiveView()
        print("✅ 라이브뷰 중지")
    }
}
