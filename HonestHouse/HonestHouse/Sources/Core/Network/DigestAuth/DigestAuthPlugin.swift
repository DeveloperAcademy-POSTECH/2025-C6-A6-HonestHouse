//
//  DigestAuthPlugin.swift
//  CCAPI_test
//
//  Created by Subeen on 10/7/25.
//

import Foundation
import Moya

/// Moya Plugin으로 Digest 인증 처리
/// CCAPIClient를 사용하여 실제 인증 로직 위임
final class DigestAuthPlugin: PluginType {
    
    private let authClient = CCAPIClient.shared
    private let username: String
    private let password: String
    private var isInitialized = false
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    /// 요청 전 Authorization 헤더 추가
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        
        print("🔧 DigestAuthPlugin.prepare called")
        print("   URL: \(request.url?.absoluteString ?? "nil")")
        
        // CCAPIClient에서 Authorization 헤더 가져오기
        if authClient.isAuthReady,
           let url = request.url?.absoluteString,
           let method = request.httpMethod {
            
            if let authHeader = authClient.getAuthHeader(
                method: method,
                url: url,
                body: request.httpBody
            ) {
                request.setValue(authHeader, forHTTPHeaderField: "Authorization")
                print("✅ Authorization header added from CCAPIClient")
            }
        } else {
            print("⚠️  CCAPIClient not ready yet")
        }
        
        return request
    }
    
    /// 응답 처리 - 401 체크
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        switch result {
        case .success(let response):
            print("📡 DigestAuthPlugin.process - Status: \(response.statusCode)")
            
            // 401 Unauthorized 처리
            if response.statusCode == 401 {
                print("🔄 Received 401, updating nonce...")
                
                // WWW-Authenticate 헤더 추출
                guard let wwwAuthHeader = extractWWWAuthenticateHeader(from: response.response) else {
                    print("❌ No WWW-Authenticate header found")
                    return result
                }
                
                print("📝 WWW-Authenticate found")
                
                // CCAPIClient에 nonce 갱신 요청
                if let request = response.request,
                   let url = request.url?.absoluteString,
                   let method = request.httpMethod {
                    
                    authClient.refreshNonce(
                        wwwAuthHeader: wwwAuthHeader,
                        method: method,
                        url: url,
                        body: request.httpBody
                    )
                    
                    print("🔄 Nonce updated, retry needed")
                }
            }
            
            return result
            
        case .failure:
            return result
        }
    }
    
    // MARK: - Helper
    
    private func extractWWWAuthenticateHeader(from response: HTTPURLResponse?) -> String? {
        guard let response = response else { return nil }
        
        for (key, value) in response.allHeaderFields {
            if let keyString = key as? String,
               keyString.lowercased() == "www-authenticate",
               let valueString = value as? String {
                return valueString
            }
        }
        return nil
    }
    
    /// 초기 인증 수행 (앱 시작 시 한 번만)
    func initializeAuth() async throws {
        guard !isInitialized else {
            print("✅ Already initialized")
            return
        }
        
        print("🔐 Initializing authentication...")
        try await authClient.authenticate(username: username, password: password)
        isInitialized = true
        print("✅ Authentication initialized")
    }
    
    /// 인증 상태 리셋
    func resetAuthentication() {
        authClient.resetAuthentication()
        isInitialized = false
        print("🔄 DigestAuthPlugin reset")
    }
}
