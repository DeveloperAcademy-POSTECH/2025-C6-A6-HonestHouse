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
        guard let url = URL(string: baseURL) else { return }
        
        let session = URLSession(configuration: .default, delegate: sslDelegate, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (_, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 401,
           let wwwAuthHeader = extractWWWAuthenticateHeader(from: httpResponse) {
            
            // 첫 번째 nonce 저장
            _ = digestAuth.getDigestAuthHeader(
                method: "GET",
                url: url.absoluteString,
                body: nil,
                wwwAuthHeader: wwwAuthHeader
            )
            
            isAuthenticated = true
        }
    }
    
    /// Authorization 헤더 생성
    func getAuthorizationHeader(method: String, url: String, body: Data?) -> String? {
        guard isAuthenticated else { return nil }
        
        return digestAuth.getDigestAuthHeader(
            method: method,
            url: url,
            body: body,
            wwwAuthHeader: nil  // 기존 nonce 재사용
        )
    }
    
    /// 401 응답 시 nonce 갱신
    func updateNonce(from response: HTTPURLResponse, method: String, url: String, body: Data?) -> String? {
        guard let wwwAuthHeader = extractWWWAuthenticateHeader(from: response) else {
            return nil
        }
        
        return digestAuth.getDigestAuthHeader(
            method: method,
            url: url,
            body: body,
            wwwAuthHeader: wwwAuthHeader  // 새 nonce로 갱신
        )
    }
    
    /// 인증 준비 상태
    var isReady: Bool {
        return isAuthenticated
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
