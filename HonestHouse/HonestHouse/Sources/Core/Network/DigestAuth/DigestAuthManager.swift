//
//  CCAPIClient.swift
//  CCAPI_test
//
//  Created by Subeen on 10/8/25.
//

import Foundation

/// Canon CCAPI 인증 상태 관리
class DigestAuthManager {
    
    // MARK: - Properties
    
    private let baseURL: String
    private let digestAuth: HTTPDigestAuth
    private let sslDelegate: SSLPinningDelegate
    private var isAuthenticated = false
    
    /// 인증 준비 상태
    var isReady: Bool {
        return isAuthenticated
    }
    
    // MARK: - Initialization
    
    init(baseURL: String,
         username: String,
         password: String,
         sslDelegate: SSLPinningDelegate) {
        
        self.baseURL = baseURL
        self.digestAuth = HTTPDigestAuth(username: username, password: password)
        self.sslDelegate = sslDelegate
    }
    
    // MARK: - Public Methods
    
    /// 초기 인증 - 401 응답 받아서 nonce 획득
    func authenticate() async throws {
        print("🔐 DigestAuthManager.authenticate() called")
        print("   baseURL: \(baseURL)")
        
        guard let url = URL(string: baseURL) else {
            print("❌ Invalid baseURL")
            return
        }
        
        let session = URLSession(configuration: .default, delegate: sslDelegate, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        print("   Sending initial GET request to obtain nonce...")
        let (_, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("   Response status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 401,
               let wwwAuthHeader = extractWWWAuthenticateHeader(from: httpResponse) {
                
                print("   WWW-Authenticate header found")
                print("   Header: \(wwwAuthHeader)")
                
                // 첫 번째 nonce 저장
                _ = digestAuth.getDigestAuthHeader(
                    method: "GET",
                    url: url.absoluteString,
                    body: nil,
                    wwwAuthHeader: wwwAuthHeader
                )
                
                isAuthenticated = true
                print("✅ Authentication initialized with Digest Auth")
            } else {
                // 401이 아닌 경우 (405, 503 등)
                // Canon CCAPI는 일부 엔드포인트에서 Digest Auth를 요구하지 않음
                // 또는 라이브뷰가 시작되지 않아 503을 반환할 수 있음
                // 이 경우에도 인증을 활성화하여 이후 요청 진행 가능하도록 함
                isAuthenticated = true
                print("✅ Authentication initialized (no Digest Auth required, status: \(httpResponse.statusCode))")
            }
        }
    }
    
    /// Authorization 헤더 생성
    func getAuthorizationHeader(method: String, url: String, body: Data?) -> String? {
        guard isAuthenticated else {
            print("⚠️ getAuthorizationHeader called but not authenticated")
            return nil
        }
        
        let header = digestAuth.getDigestAuthHeader(
            method: method,
            url: url,
            body: body,
            wwwAuthHeader: nil  // 기존 nonce 재사용
        )
        
        if header != nil {
            print("🔑 Auth header generated for \(method) \(url)")
        }
        
        return header
    }
    
    /// 401 응답 시 nonce 갱신
    func updateNonce(from response: HTTPURLResponse, method: String, url: String, body: Data?) -> String? {
        print("🔄 Updating nonce from 401 response")
        
        guard let wwwAuthHeader = extractWWWAuthenticateHeader(from: response) else {
            print("❌ No WWW-Authenticate header in 401 response")
            return nil
        }
        
        print("   New WWW-Authenticate: \(wwwAuthHeader)")
        
        let header = digestAuth.getDigestAuthHeader(
            method: method,
            url: url,
            body: body,
            wwwAuthHeader: wwwAuthHeader  // 새 nonce로 갱신
        )
        
        if header != nil {
            print("✅ Nonce updated successfully")
        }
        
        return header
    }

    
    /// 인증 리셋
    func reset() {
        isAuthenticated = false
    }
    
    // MARK: - Private Methods
    
    private func extractWWWAuthenticateHeader(from response: HTTPURLResponse) -> String? {
        for (key, value) in response.allHeaderFields {
            if let keyString = key as? String,
               keyString.lowercased() == "www-authenticate",
               let valueString = value as? String {
                return valueString
            }
        }
        return nil
    }
}
