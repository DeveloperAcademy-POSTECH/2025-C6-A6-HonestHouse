//
//  NetworkManager.swift
//  CCAPI_test
//
//  Created by Subeen on 10/6/25.
//

import Foundation
import Moya
import Alamofire

/// Moya Provider와 Digest 인증을 통합 관리하는 싱글톤
class NetworkManager {
    static let shared = NetworkManager()
    
    private let username = "user"
    private let password = "0000"
    
    let digestAuthPlugin: DigestAuthPlugin
    private let session: Session
    
    /// CCAPI Provider
    lazy var ccapiProvider: MoyaProvider<MultiTarget> = {
        return MoyaProvider<MultiTarget>(
            session: session,
            plugins: [
                digestAuthPlugin,
                NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
            ]
        )
    }()
    
    private init() {
        // Digest Auth Plugin 생성
        digestAuthPlugin = DigestAuthPlugin(username: username, password: password)
        
        // SSL 인증서 처리를 위한 ServerTrustManager 설정
        let serverTrustManager = ServerTrustManager(evaluators: [
            "192.168.1.2": DisabledTrustEvaluator()  // 자체 서명 인증서 허용
        ])
        
        // Alamofire Session 설정
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        
        session = Session(
            configuration: configuration,
            serverTrustManager: serverTrustManager
        )
        
        print("NetworkManager initialized")
        print("  Username: \(username)")
    }
    
    /// 인증 상태 리셋
    func resetAuthentication() {
        digestAuthPlugin.resetAuthentication()
        print("NetworkManager authentication reset")
    }
}
