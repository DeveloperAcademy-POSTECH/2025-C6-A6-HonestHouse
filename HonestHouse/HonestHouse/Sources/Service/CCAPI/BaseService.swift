//
//  BaseService.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation
import Moya

/// 모든 CCAPI Service의 공통 기능을 제공하는 Base 클래스
/// - Digest 인증 자동 처리
/// - 401 응답 시 자동 재시도
/// - Thread-safe 인증 관리
class BaseService {
    
    // MARK: - Properties
    
    /// JSON 디코더 (모든 서브클래스에서 사용)
    let jsonDecoder = JSONDecoder()
    
    /// MultiTarget Provider (모든 Target 통합)
    let provider = NetworkManager.shared.ccapiProvider
    
    /// Digest 인증 Plugin
    let authPlugin = NetworkManager.shared.digestAuthPlugin
    
    /// 인증 초기화 상태 (앱 전체에서 공유)
    private static var isAuthInitialized = false
    
    /// Thread-safe를 위한 Lock
    private static let authLock = NSLock()
    
    // MARK: - Initialization
    
    init() {
        // 초기화 로직 없음 (필요시 서브클래스에서 override)
    }
    
    // MARK: - Authentication
    
    /// 첫 API 호출 시 인증 초기화
    /// - 앱 전체에서 한 번만 실행 (Thread-safe)
    /// - 모든 Service가 공유하는 인증 상태
    func ensureAuthenticated() async throws {
        BaseService.authLock.lock()
        defer { BaseService.authLock.unlock() }
        
        guard !BaseService.isAuthInitialized else {
            return
        }
        
        print("🔐 Initializing authentication...")
        try await authPlugin.initializeAuth()
        BaseService.isAuthInitialized = true
        print("✅ Authentication ready for all services")
    }
    
    // MARK: - Request Methods
    
    /// 응답이 있는 API 요청 (GET, PUT 등)
    /// - 401 재시도 자동 처리
    /// - JSON 자동 디코딩
    ///
    /// - Parameters:
    ///   - target: API 타겟 (ShootingTarget, DeviceStatusTarget 등)
    ///   - decoding: 디코딩할 타입
    ///   - maxRetries: 최대 재시도 횟수 (기본값: 3)
    /// - Returns: 디코딩된 응답 객체
    /// - Throws: CCAPIError 또는 디코딩 에러
    ///
    /// 사용 예시:
    /// ```swift
    /// let response = try await requestWithRetry(
    ///     ShootingTarget.getISO,
    ///     decoding: SettingResponse.self
    /// )
    /// ```
    func requestWithRetry<T: Decodable, Target: TargetType>(
        _ target: Target,
        decoding: T.Type,
        maxRetries: Int = 3
    ) async throws -> T {
        // 인증 초기화 확인
        try await ensureAuthenticated()
        
        var retryCount = 0
        
        // 재시도 루프 (안드로이드의 while(true)와 동일)
        while retryCount <= maxRetries {
            let result = await withCheckedContinuation { (continuation: CheckedContinuation<Result<T, Error>, Never>) in
                // MultiTarget으로 래핑하여 요청
                provider.request(MultiTarget(target)) { result in
                    switch result {
                    case .success(let response):
                        // 401 체크
                        if response.statusCode == 401 && retryCount < maxRetries {
                            print("⚠️  Received 401, will retry (\(retryCount + 1)/\(maxRetries))")
                            continuation.resume(returning: .failure(CCAPIError.authenticationFailed(401)))
                            return
                        }
                        
                        // 성공 응답 처리
                        do {
                            let filteredResponse = try response.filterSuccessfulStatusCodes()
                            let decoded = try self.jsonDecoder.decode(T.self, from: filteredResponse.data)
                            continuation.resume(returning: .success(decoded))
                            
                        } catch MoyaError.statusCode(let response) {
                            print("❌ API Error - Status: \(response.statusCode)")
//                            Log.network("Failure - \(target.path)", "Status code: \(response.statusCode)")
                            continuation.resume(returning: .failure(CCAPIError.unexpectedStatusCode(response.statusCode)))
                            
                        } catch {
                            print("❌ Decoding failed: \(error.localizedDescription)")
//                            Log.network("Failure - \(target.path) - Decoding", error.localizedDescription)
                            continuation.resume(returning: .failure(CCAPIError.decodingFailed(error.localizedDescription)))
                        }
                        
                    case .failure(let error):
                        print("❌ Request failed: \(error.localizedDescription)")
//                        Log.network("Failure - \(target.path) - Request", error.localizedDescription)
                        continuation.resume(returning: .failure(error))
                    }
                }
            }
            
            // 결과 확인
            switch result {
            case .success(let response):
                return response  // 성공 - 반환
                
            case .failure(let error):
                if let ccapiError = error as? CCAPIError,
                   case .authenticationFailed = ccapiError {
                    // 401 에러 - 재시도
                    retryCount += 1
//                    try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1초 대기
                    continue
                } else {
                    // 다른 에러 - 바로 throw
                    throw error
                }
            }
        }
        
        throw CCAPIError.maxRetriesExceeded
    }
    
    /// 응답이 없는 API 요청 (POST, DELETE 등)
    /// - 401 재시도 자동 처리
    ///
    /// - Parameters:
    ///   - target: API 타겟
    ///   - maxRetries: 최대 재시도 횟수 (기본값: 3)
    /// - Throws: CCAPIError
    ///
    /// 사용 예시:
    /// ```swift
    /// try await requestWithoutResponse(
    ///     ShootingTarget.shutterButton(af: true)
    /// )
    /// ```
    func requestWithoutResponse<Target: TargetType>(
        _ target: Target,
        maxRetries: Int = 3
    ) async throws {
        try await ensureAuthenticated()
        
        var retryCount = 0
        
        while retryCount <= maxRetries {
            let result = await withCheckedContinuation { (continuation: CheckedContinuation<Result<Void, Error>, Never>) in
                provider.request(MultiTarget(target)) { result in
                    switch result {
                    case .success(let response):
                        if response.statusCode == 401 && retryCount < maxRetries {
                            print("⚠️  Received 401, will retry (\(retryCount + 1)/\(maxRetries))")
                            continuation.resume(returning: .failure(CCAPIError.authenticationFailed(401)))
                            return
                        }
                        
                        do {
                            _ = try response.filterSuccessfulStatusCodes()
                            continuation.resume(returning: .success(()))
                        } catch {
                            continuation.resume(returning: .failure(error))
                        }
                        
                    case .failure(let error):
                        continuation.resume(returning: .failure(error))
                    }
                }
            }
            
            switch result {
            case .success:
                return
                
            case .failure(let error):
                if let ccapiError = error as? CCAPIError,
                   case .authenticationFailed = ccapiError {
                    retryCount += 1
//                    try? await Task.sleep(nanoseconds: 100_000_000)
                    continue
                } else {
                    throw error
                }
            }
        }
        
        throw CCAPIError.maxRetriesExceeded
    }
    
    // MARK: - Authentication Reset
    
    /// 인증 상태 리셋
    /// - 모든 Service의 인증 상태를 초기화
    /// - 앱 로그아웃 또는 카메라 재연결 시 사용
    func resetAuthentication() {
        BaseService.authLock.lock()
        defer { BaseService.authLock.unlock() }
        
        BaseService.isAuthInitialized = false
        NetworkManager.shared.resetAuthentication()
        print("🔄 All services authentication reset")
    }
}
