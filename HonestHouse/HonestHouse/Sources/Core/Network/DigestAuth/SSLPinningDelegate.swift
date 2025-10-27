//
//  SSLPinningDelegate.swift
//  CCAPI_test
//
//  Created by Subeen on 10/1/25.
//

import Foundation

/// URLSession의 SSL 인증서 처리를 위한 Delegate
class SSLPinningDelegate: NSObject, URLSessionDelegate {
    
    // MARK: - Properties
    
    private var allowedHosts = Set<String>()
    
    // MARK: - Public Methods
    
    /// 신뢰할 호스트 추가
    func addTrustedHost(_ host: String) {
        allowedHosts.insert(host)
    }
    
    /// 신뢰할 호스트 제거
    func removeTrustedHost(_ host: String) {
        allowedHosts.remove(host)
    }
    
    // MARK: - URLSessionDelegate
    
    func urlSession(_ session: URLSession,
                   didReceive challenge: URLAuthenticationChallenge,
                   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        print("Received authentication challenge")
        print("  Protection space: \(challenge.protectionSpace.authenticationMethod)")
        print("  Host: \(challenge.protectionSpace.host)")
        
        // 서버 신뢰 인증 (SSL/TLS)
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            // 허용된 호스트인지 확인
            if allowedHosts.contains(challenge.protectionSpace.host),
               let serverTrust = challenge.protectionSpace.serverTrust {
                print("Accepting self-signed certificate for host: \(challenge.protectionSpace.host)")
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }
        
        // 그 외의 경우 기본 처리
        completionHandler(.performDefaultHandling, nil)
    }
}
