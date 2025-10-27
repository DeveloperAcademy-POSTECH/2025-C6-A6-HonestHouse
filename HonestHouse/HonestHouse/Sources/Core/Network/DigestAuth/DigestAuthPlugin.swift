//
//  DigestAuthPlugin.swift
//  CCAPI_test
//
//  Created by Subeen on 10/7/25.
//

import Foundation
import Moya

/// Moya Plugin으로 Digest 인증 처리
final class DigestAuthPlugin: PluginType {
    
    // MARK: - Properties
    
    private let authManager: DigestAuthManager
    
    // MARK: - Initialization
    
    init(authManager: DigestAuthManager) {
        self.authManager = authManager
    }
    
    // MARK: - PluginType
    
    /// 요청 전 Authorization 헤더 추가
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        
        if let url = request.url?.absoluteString,
           let method = request.httpMethod,
           let authHeader = authManager.getAuthorizationHeader(
                method: method,
                url: url,
                body: request.httpBody
           ) {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    /// 401 응답 처리
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        guard case .success(let response) = result,
              response.statusCode == 401,
              let request = response.request,
              let url = request.url?.absoluteString,
              let method = request.httpMethod,
              let httpResponse = response.response else {
            return result
        }
        
        // nonce 갱신
        _ = authManager.updateNonce(
            from: httpResponse,
            method: method,
            url: url,
            body: request.httpBody
        )
        
        // 재시도를 위해 에러 반환
        return .failure(MoyaError.statusCode(response))
    }
}
