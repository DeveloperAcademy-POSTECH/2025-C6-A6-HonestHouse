//
//  CCAPIClient.swift
//  CCAPI_test
//
//  Created by Subeen on 10/8/25.
//

import Foundation

/// Canon CCAPI 인증 관리 클래스 (인증 전용)
/// 실제 API 호출은 Moya를 사용하고, 인증 헤더만 제공
class CCAPIClient {
    static let shared = CCAPIClient()
    
    private let baseURL = BaseAPI.base.apiDesc
    private var digestAuth: HTTPDigestAuth?
    private var session: URLSession
    private let sessionDelegate = SSLPinningDelegate()
    private var isAuthenticated = false
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        
        self.session = URLSession(configuration: config, delegate: sessionDelegate, delegateQueue: nil)
        
        print("🔐 CCAPIClient initialized (Auth Only)")
    }
    
    // MARK: - Public Methods
    
    /// 초기 인증 수행 (WWW-Authenticate 헤더 받아오기)
    /// - Parameters:
    ///   - username: 사용자명
    ///   - password: 비밀번호
    func authenticate(username: String, password: String) async throws {
        guard let url = URL(string: baseURL) else {
            throw CCAPIError.invalidURL
        }
        
        print("🔄 Authenticating...")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CCAPIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            // WWW-Authenticate 헤더 추출
            guard let wwwAuthHeader = extractWWWAuthenticateHeader(from: httpResponse) else {
                throw CCAPIError.noWWWAuthenticateHeader
            }
            
            print("✅ Received WWW-Authenticate header")
            
            // Digest Auth 객체 생성
            digestAuth = HTTPDigestAuth(username: username, password: password)
            
            // 첫 번째 헤더 생성 (nonce 저장됨)
            _ = digestAuth?.getDigestAuthHeader(
                method: "GET",
                url: url.absoluteString,
                body: nil,
                wwwAuthHeader: wwwAuthHeader
            )
            
            isAuthenticated = true
            print("✅ Authentication prepared")
            
        } else {
            print("⚠️  No authentication required")
            isAuthenticated = true
        }
    }
    
    /// Authorization 헤더 문자열 반환 (Moya에서 사용)
    /// - Parameters:
    ///   - method: HTTP 메서드
    ///   - url: 요청 URL
    ///   - body: 요청 바디
    /// - Returns: Authorization 헤더 문자열
    func getAuthHeader(method: String, url: String, body: Data?) -> String? {
        guard let digestAuth = digestAuth else {
            print("⚠️  No digestAuth available")
            return nil
        }
        
        return digestAuth.getDigestAuthHeader(
            method: method,
            url: url,
            body: body,
            wwwAuthHeader: nil  // 기존 nonce 재사용
        )
    }
    
    /// 401 응답 시 nonce 갱신
    /// - Parameter wwwAuthHeader: 새로운 WWW-Authenticate 헤더
    func refreshNonce(wwwAuthHeader: String, method: String, url: String, body: Data?) {
        guard let digestAuth = digestAuth else {
            print("⚠️  No digestAuth to refresh")
            return
        }
        
        print("🔄 Refreshing nonce...")
        
        _ = digestAuth.getDigestAuthHeader(
            method: method,
            url: url,
            body: body,
            wwwAuthHeader: wwwAuthHeader
        )
        
        print("✅ Nonce refreshed")
    }
    
    /// 인증 상태 확인
    var isAuthReady: Bool {
        return isAuthenticated && digestAuth != nil
    }
    
    /// 인증 상태 리셋
    func resetAuthentication() {
        isAuthenticated = false
        digestAuth = nil
        print("🔄 Authentication reset")
    }
    
    // MARK: - Helper
    
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
