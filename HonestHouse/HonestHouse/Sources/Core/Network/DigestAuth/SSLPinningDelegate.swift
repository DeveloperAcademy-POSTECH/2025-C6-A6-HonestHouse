//
//  SSLPinningDelegate.swift
//  CCAPI_test
//
//  Created by Subeen on 10/1/25.
//

import Foundation

/// URLSession의 SSL 인증서 처리를 위한 Delegate
/// 개발 환경에서 자체 서명 인증서를 허용하기 위해 사용
class SSLPinningDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession,
                   didReceive challenge: URLAuthenticationChallenge,
                   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        print("Received authentication challenge")
        print("  Protection space: \(challenge.protectionSpace.authenticationMethod)")
        
        // 서버 신뢰 인증 (SSL/TLS)
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
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
