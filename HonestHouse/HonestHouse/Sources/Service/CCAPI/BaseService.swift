//
//  BaseService.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation
import Moya

/// 모든 CCAPI Service의 공통 기능을 제공하는 Base 클래스
class BaseService {
    
    // MARK: - Properties
    
    private let networkManager: NetworkManager = NetworkManager.shared
    private let jsonDecoder = JSONDecoder()
    
    // MARK: - Request Methods
    
    /// 응답이 있는 API 요청 (GET, PUT 등)
    /// NetworkManager가 401 재시도를 처리하므로 여기서는 디코딩만
    func request<T: Decodable, Target: TargetType>(
        _ target: Target,
        decoding: T.Type
    ) async throws -> T {
        let response = try await networkManager.request(target)
        
        // 200번대가 아니면 에러
        guard (200...299).contains(response.statusCode) else {
            throw CCAPIError.unexpectedStatusCode(response.statusCode)
        }
        
        // JSON 디코딩
        do {
            return try jsonDecoder.decode(T.self, from: response.data)
        } catch {
            throw CCAPIError.decodingFailed(error.localizedDescription)
        }
    }
    
    /// 응답이 없는 API 요청 (POST, DELETE 등)
    func request<Target: TargetType>(_ target: Target) async throws {
        let response = try await networkManager.request(target)
        
        guard (200...299).contains(response.statusCode) else {
            throw CCAPIError.unexpectedStatusCode(response.statusCode)
        }
    }
    
    /// Raw Data 응답 (이미지, 파일 다운로드 등)
    func requestData<Target: TargetType>(_ target: Target) async throws -> Data {
        let response = try await networkManager.request(target)
        
        guard (200...299).contains(response.statusCode) else {
            throw CCAPIError.unexpectedStatusCode(response.statusCode)
        }
        
        return response.data
    }
    
    /// String 응답 (텍스트 응답)
    func requestString<Target: TargetType>(_ target: Target) async throws -> String {
        let data = try await requestData(target)
        
        guard let string = String(data: data, encoding: .utf8) else {
            throw CCAPIError.decodingFailed("Failed to decode as UTF-8 string")
        }
        
        return string
    }
    
    /// 응답 본문이 있지만 디코딩이 필요없는 PUT 요청용
    func request<T: Decodable, Target: TargetType>(
        _ target: Target,
        decoding: T.Type,
        expectResponse: Bool
    ) async throws -> T {
        let response = try await networkManager.request(target)
        
        guard (200...299).contains(response.statusCode) else {
            throw CCAPIError.unexpectedStatusCode(response.statusCode)
        }
        
        // PUT 요청이지만 응답 본문이 있는 경우
        do {
            return try jsonDecoder.decode(T.self, from: response.data)
        } catch {
            throw CCAPIError.decodingFailed(error.localizedDescription)
        }
    }
}

// MARK: - Error Types

enum CCAPIError: Error, LocalizedError {
    case unexpectedStatusCode(Int)
    case decodingFailed(String)
    case authenticationFailed(Int)
    
    var errorDescription: String? {
        switch self {
        case .unexpectedStatusCode(let code):
            return "Unexpected status code: \(code)"
        case .decodingFailed(let message):
            return "Decoding failed: \(message)"
        case .authenticationFailed(let code):
            return "Authentication failed with code: \(code)"
        }
    }
}
