//
//  CanonLiveViewStreamAuth.swift
//  CCAPI_test
//
//  Created by Subeen on 10/27/25.
//


import Foundation
import UIKit
import Combine

/// Canon 라이브뷰 스트림 관리자 (Digest Auth 적용)
@MainActor
class CanonLiveViewStreamAuth: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentImage: UIImage?
    @Published var isStreaming = false
    @Published var fps: Double = 0.0
    @Published var errorMessage: String?
    @Published var afFrames: [LiveViewInfo.AFFrame] = []
    @Published var connectionStatus: ConnectionStatus = .disconnected
    
    // MARK: - Connection Status
    enum ConnectionStatus {
        case disconnected
        case connecting
        case authenticating
        case connected
        case streaming
        case error(String)
        
        var description: String {
            switch self {
            case .disconnected: return "연결 안됨"
            case .connecting: return "연결 중..."
            case .authenticating: return "인증 중..."
            case .connected: return "연결됨"
            case .streaming: return "스트리밍 중"
            case .error(let msg): return "에러: \(msg)"
            }
        }
    }
    
    // MARK: - Stream Type
    enum StreamType {
        case scroll
        case scrollDetail
        
        var endpoint: String {
            switch self {
            case .scroll: return "/shooting/liveview/scroll"
            case .scrollDetail: return "/shooting/liveview/scrolldetail"
            }
        }
    }
    
    // MARK: - Private Properties
    private var cameraIP: String = ""
    private var port: Int = 443
    private var baseURL: String = ""
    private var streamTask: URLSessionDataTask?
    private var authManager: DigestAuthManager?
    private let parser = ChunkedStreamParser()
    
    // SSL Delegate
    private let sslDelegate = SSLPinningDelegate()
    
    // FPS 계산
    private var frameCount = 0
    private var fpsStartTime = Date()
    private let fpsUpdateInterval: TimeInterval = 1.0
    
    // 인증 재시도
    private let maxAuthRetries = 3
    private var authRetryCount = 0
    
    // MARK: - Initialization
    
    override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// 카메라 설정 및 인증 매니저 초기화
    func configureCamera(ipAddress: String, port: Int = 8080, username: String = "", password: String = "") async throws {
        self.cameraIP = ipAddress
        self.port = port
        self.baseURL = "http://\(ipAddress):\(port)/ccapi/ver100"
        
        // SSL 신뢰 호스트 추가
        sslDelegate.addTrustedHost(ipAddress)
        
        // Digest Auth Manager 초기화
        // 일반 엔드포인트로 초기 인증 (라이브뷰 활성화 전에는 /scroll이 503 반환)
        let authBaseURL = "\(baseURL)/shooting/liveview"
        authManager = DigestAuthManager(
            baseURL: authBaseURL,
            username: username,
            password: password,
            sslDelegate: sslDelegate
        )
        
        connectionStatus = .authenticating
        
        // 초기 인증 (401 응답으로 nonce 획득)
        // 참고: /liveview는 POST만 지원하므로 401 또는 405 응답 예상
        try await authManager?.authenticate()
        
        connectionStatus = .connected
        print("Camera configured and authenticated: \(baseURL)")
    }
    
    /// 라이브뷰 시작
    func startLiveView(size: String = "medium", display: String = "on") async throws {
        print("🔵 startLiveView called")
        print("   baseURL: \(baseURL)")
        print("   authManager.isReady: \(authManager?.isReady ?? false)")
        
        guard !baseURL.isEmpty else {
            print("❌ Error: No camera set")
            throw StreamError.noCameraSet
        }
        
        guard authManager?.isReady == true else {
            print("❌ Error: Not authenticated")
            throw StreamError.notAuthenticated
        }
        
        connectionStatus = .connecting
        authRetryCount = 0
        
        print("📡 Step 1: Enabling LiveView...")
        // 1. 라이브뷰 활성화 (POST with Digest Auth)
        try await enableLiveView(size: size, display: display)
        
        // 카메라가 라이브뷰를 준비할 시간 제공
        print("⏳ Waiting for camera to prepare LiveView (1 second)...")
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
        
        print("📡 Step 2: Starting streaming...")
        // 2. 스트리밍 시작
        try await startStreaming(type: .scrollDetail)
    }
    
    /// 스트리밍 중지
    func stopStreaming() async {
        guard isStreaming else { return }
        
        // DELETE 요청으로 스트림 종료
        if !baseURL.isEmpty {
            await sendDeleteRequest()
        }
        
        streamTask?.cancel()
        streamTask = nil
        isStreaming = false
        connectionStatus = .connected
        await parser.reset()
        
        print("Streaming stopped")
    }
    
    /// 라이브뷰 완전 중지
    func stopLiveView() async {
        await stopStreaming()
        
        // 라이브뷰 비활성화
        if !baseURL.isEmpty {
            try? await disableLiveView()
        }
        
        connectionStatus = .disconnected
        currentImage = nil
        
        print("LiveView stopped completely")
    }
    
    // MARK: - Private Methods - LiveView Control
    
    private func enableLiveView(size: String, display: String) async throws {
        let url = URL(string: "\(baseURL)/shooting/liveview")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "liveviewsize": size,
            "cameradisplay": display
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = bodyData
        
        print("   POST URL: \(url.absoluteString)")
        print("   Body: \(body)")
        
        // Digest Auth 헤더 추가
        if let authHeader = authManager?.getAuthorizationHeader(
            method: "POST",
            url: url.absoluteString,
            body: bodyData
        ) {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
            print("   Auth header added")
        } else {
            print("   ⚠️ No auth header available")
        }
        
        let session = URLSession(configuration: .default, delegate: sslDelegate, delegateQueue: nil)
        
        // 재시도 로직
        for attempt in 0..<maxAuthRetries {
            print("   Attempt \(attempt + 1)/\(maxAuthRetries)...")
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("   Response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    print("✅ LiveView enabled successfully")
                    if data.count > 0 {
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("   Response: \(responseString)")
                        }
                    }
                    return
                } else if httpResponse.statusCode == 401 {
                    print("   ⚠️ 401 Unauthorized, updating nonce...")
                    // nonce 갱신 후 재시도
                    if let newAuthHeader = authManager?.updateNonce(
                        from: httpResponse,
                        method: "POST",
                        url: url.absoluteString,
                        body: bodyData
                    ) {
                        request.setValue(newAuthHeader, forHTTPHeaderField: "Authorization")
                        print("   Auth retry \(attempt + 1)/\(maxAuthRetries)")
                        continue
                    }
                } else {
                    // 다른 에러 코드의 경우 응답 내용 출력
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("   Error response: \(responseString)")
                    }
                }
                
                throw StreamError.httpError(httpResponse.statusCode)
            }
        }
        
        throw StreamError.authenticationFailed
    }
    
    private func disableLiveView() async throws {
        let url = URL(string: "\(baseURL)/shooting/liveview")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "liveviewsize": "off",
            "cameradisplay": "on"
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = bodyData
        
        // Digest Auth 헤더 추가
        if let authHeader = authManager?.getAuthorizationHeader(
            method: "POST",
            url: url.absoluteString,
            body: bodyData
        ) {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession(configuration: .default, delegate: sslDelegate, delegateQueue: nil)
        _ = try? await session.data(for: request)
    }
    
    // MARK: - Private Methods - Streaming
    
    private func startStreaming(type: StreamType) async throws {
        let url = URL(string: "\(baseURL)\(type.endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Canon CCAPI 라이브뷰 스트림에 필요한 헤더 설정
        request.setValue("image/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("chunked", forHTTPHeaderField: "transfer-encoding")
        
        print("   GET URL: \(url.absoluteString)")
        print("   Headers: Content-Type=image/octet-stream, transfer-encoding=chunked")
        
        // Digest Auth 헤더 추가
        if let authHeader = authManager?.getAuthorizationHeader(
            method: "GET",
            url: url.absoluteString,
            body: nil
        ) {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
            print("   Auth header added for streaming")
        } else {
            print("   ⚠️ No auth header available for streaming")
        }
        
        isStreaming = true
        connectionStatus = .streaming
        await parser.reset()
        resetFPS()
        
        print("✅ Streaming configuration complete")
        
        // 커스텀 델리게이트로 스트림 처리
        let streamDelegate = AuthStreamDelegate(
            parser: parser,
            authManager: authManager,
            sslDelegate: sslDelegate
        ) { [weak self] frames in
            Task { @MainActor in
                self?.processFrames(frames)
            }
        } onAuthError: { [weak self] in
            Task { @MainActor in
                self?.handleAuthError()
            }
        }
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 300.0
        
        let streamSession = URLSession(
            configuration: sessionConfig,
            delegate: streamDelegate,
            delegateQueue: nil
        )
        
        let streamRequest = streamSession.dataTask(with: request)
        self.streamTask = streamRequest
        
        print("✅ Streaming task created")
        print("   Starting data task...")
        
        streamRequest.resume()
        
        print("✅ Streaming started: \(type.endpoint)")
        print("   Waiting for data...")
    }
    
    private func sendDeleteRequest() async {
        let url = URL(string: "\(baseURL)/shooting/liveview/scroll")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Digest Auth 헤더 추가
        if let authHeader = authManager?.getAuthorizationHeader(
            method: "DELETE",
            url: url.absoluteString,
            body: nil
        ) {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession(configuration: .default, delegate: sslDelegate, delegateQueue: nil)
        _ = try? await session.data(for: request)
    }
    
    // MARK: - Private Methods - Processing
    
    private func processFrames(_ frames: [ChunkedStreamParser.ParsedFrame]) {
        print("🔄 Processing \(frames.count) frames...")
        
        for frame in frames {
            print("   Frame type: \(frame.type), data size: \(frame.data.count) bytes")
            
            switch frame.type {
            case .image:
                print("   Attempting to decode image from \(frame.data.count) bytes...")
                
                // JPEG 시그니처 확인
                let preview = frame.data.prefix(10).map { String(format: "%02X", $0) }.joined(separator: " ")
                print("   Data starts with: \(preview)")
                
                if let image = UIImage(data: frame.data) {
                    print("   ✅ UIImage created successfully")
                    self.currentImage = image
                    self.updateFPS()
                    print("🖼️ Image frame processed: \(image.size.width)x\(image.size.height)")
                } else {
                    print("⚠️ Image frame received but UIImage(data:) returned nil")
                    print("   Data size: \(frame.data.count) bytes")
                }
                
            case .info:
                if let info = frame.info {
                    self.afFrames = info.afFrame ?? []
                    print("ℹ️ Info frame processed: \(info.afFrame?.count ?? 0) AF frames")
                }
                
            case .event:
                // 이벤트 처리
                print("📢 Event frame received")
                break
            }
        }
    }
    
    private func handleAuthError() {
        authRetryCount += 1
        
        if authRetryCount >= maxAuthRetries {
            connectionStatus = .error("인증 실패")
            errorMessage = "인증 재시도 횟수 초과"
            Task {
                await stopStreaming()
            }
        } else {
            print("Auth error during streaming, retry: \(authRetryCount)")
            // 스트림 재시작 시도
            Task {
                await stopStreaming()
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
                try? await startStreaming(type: .scrollDetail)
            }
        }
    }
    
    private func updateFPS() {
        frameCount += 1
        
        let elapsed = Date().timeIntervalSince(fpsStartTime)
        if elapsed >= fpsUpdateInterval {
            fps = Double(frameCount) / elapsed
            resetFPS()
        }
    }
    
    private func resetFPS() {
        frameCount = 0
        fpsStartTime = Date()
    }
    
    // MARK: - Public Methods - AF Control
    
    func setAFPosition(x: Int, y: Int) async {
        let url = URL(string: "\(baseURL)/shooting/liveview/afframeposition")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Int] = [
            "positionx": x,
            "positiony": y
        ]
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = bodyData
            
            // Digest Auth 헤더 추가
            if let authHeader = authManager?.getAuthorizationHeader(
                method: "PUT",
                url: url.absoluteString,
                body: bodyData
            ) {
                request.setValue(authHeader, forHTTPHeaderField: "Authorization")
            }
            
            let session = URLSession(configuration: .default, delegate: sslDelegate, delegateQueue: nil)
            let (_, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("AF position set to: (\(x), \(y)) - Status: \(httpResponse.statusCode)")
            }
        } catch {
            print("Failed to set AF position: \(error)")
        }
    }
}

// MARK: - Custom Stream Delegate with Auth

private class AuthStreamDelegate: NSObject, URLSessionDataDelegate {
    private let parser: ChunkedStreamParser
    private let authManager: DigestAuthManager?
    private let sslDelegate: SSLPinningDelegate
    private let onFramesReceived: ([ChunkedStreamParser.ParsedFrame]) -> Void
    private let onAuthError: () -> Void
    private var currentRequest: URLRequest?
    
    init(parser: ChunkedStreamParser,
         authManager: DigestAuthManager?,
         sslDelegate: SSLPinningDelegate,
         onFramesReceived: @escaping ([ChunkedStreamParser.ParsedFrame]) -> Void,
         onAuthError: @escaping () -> Void) {
        self.parser = parser
        self.authManager = authManager
        self.sslDelegate = sslDelegate
        self.onFramesReceived = onFramesReceived
        self.onAuthError = onAuthError
        super.init()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // 청크 데이터 수신 시 파싱
        print("📦 Received \(data.count) bytes")
        Task {
            let frames = await parser.appendChunk(data)
            if !frames.isEmpty {
                print("   Parsed \(frames.count) frames")
                onFramesReceived(frames)
            }
        }
    }
    
    func urlSession(_ session: URLSession,
                   dataTask: URLSessionDataTask,
                   didReceive response: URLResponse,
                   completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 Stream response status: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 401 {
                print("⚠️ 401 received during streaming")
                
                // nonce 갱신
                if let request = dataTask.originalRequest,
                   let url = request.url?.absoluteString,
                   let method = request.httpMethod {
                    _ = authManager?.updateNonce(
                        from: httpResponse,
                        method: method,
                        url: url,
                        body: request.httpBody
                    )
                }
                
                onAuthError()
                completionHandler(.cancel)
            } else {
                completionHandler(.allow)
            }
        } else {
            completionHandler(.allow)
        }
    }
    
    func urlSession(_ session: URLSession,
                   didReceive challenge: URLAuthenticationChallenge,
                   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // SSL 인증서 처리 위임
        sslDelegate.urlSession(session, didReceive: challenge, completionHandler: completionHandler)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("❌ Stream error: \(error.localizedDescription)")
            if let urlError = error as? URLError {
                print("   URLError code: \(urlError.code.rawValue)")
            }
        } else {
            print("✅ Stream completed successfully")
        }
    }
}

// MARK: - Errors

enum StreamError: LocalizedError {
    case noCameraSet
    case notAuthenticated
    case authenticationFailed
    case failedToStart
    case streamingFailed
    case invalidData
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .noCameraSet:
            return "카메라 IP가 설정되지 않았습니다"
        case .notAuthenticated:
            return "인증되지 않았습니다"
        case .authenticationFailed:
            return "인증에 실패했습니다"
        case .failedToStart:
            return "라이브뷰 시작에 실패했습니다"
        case .streamingFailed:
            return "스트리밍 중 오류가 발생했습니다"
        case .invalidData:
            return "잘못된 데이터 형식입니다"
        case .httpError(let code):
            return "HTTP 오류: \(code)"
        }
    }
}
