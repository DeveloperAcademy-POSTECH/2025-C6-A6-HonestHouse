//
//  StreamService.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/30/25.
//

import Foundation

class StreamService {

    // MARK: - Properties

    private let networkManager: NetworkManager
    private var urlSession: URLSession?
    private var streamingTask: URLSessionDataTask?
    private(set) var isStreaming = false

    // MARK: - Configuration (Subclass Override Required)

    var endpoint: String {
        fatalError("Subclass must override endpoint")
    }

    var httpMethod: String {
        fatalError("Subclass must override httpMethod")
    }

    // MARK: - Initialization

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    // MARK: - Public Methods

    @discardableResult
    func startStreaming(
        onData: @escaping (Data) -> Void,
        onError: @escaping (Error) -> Void
    ) async -> Bool {
        guard !isStreaming else {
            print("Already streaming")
            return false
        }

        // Phase 1: Authentication
        guard let url = buildURL() else {
            onError(CCAPIError.invalidURL)
            return false
        }

        let authHeader = await getDigestAuthHeader(for: url)

        // Phase 2: Request Setup
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        if let authHeader = authHeader {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
            print("🔑 Authorization header added to streaming request")
        } else {
            print("⚠️ No Authorization header - will handle 401 if needed")
        }

        // Phase 3: Network Streaming Setup
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = .infinity
        config.timeoutIntervalForResource = .infinity
        config.waitsForConnectivity = true

        let delegate = StreamDelegate(
            onData: onData,
            onError: onError
        )

        urlSession = URLSession(
            configuration: config,
            delegate: delegate,
            delegateQueue: nil
        )

        // Start streaming
        streamingTask = urlSession?.dataTask(with: request)
        streamingTask?.resume()
        isStreaming = true

        print("✅ Streaming started: \(endpoint)")
        return true
    }

    func stopStreaming() async throws {
        guard isStreaming else {
            print("Not streaming")
            return
        }

        streamingTask?.cancel()
        streamingTask = nil
        urlSession?.invalidateAndCancel()
        urlSession = nil
        isStreaming = false

        try await sendDeleteRequest()

        print("✅ Streaming stopped: \(endpoint)")
    }

    // MARK: - Private Methods

    private func buildURL() -> URL? {
        return URL(string: "\(BaseAPI.base.apiDesc)\(endpoint)")
    }

    private func getDigestAuthHeader(for url: URL) async -> String? {
        do {
            try await networkManager.initializeAuthentication()
        } catch {
            print("⚠️ Auth initialization failed: \(error)")
            return nil
        }

        return networkManager.getAuthorizationHeader(
            method: httpMethod,
            url: url.absoluteString,
            body: nil
        )
    }

    private func sendDeleteRequest() async throws {
        guard let url = buildURL() else {
            throw CCAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        if let authHeader = networkManager.getAuthorizationHeader(
            method: "DELETE",
            url: url.absoluteString,
            body: nil
        ) {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
            print("🔑 Authorization header added to DELETE request")
        }

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("DELETE response: \(httpResponse.statusCode)")
            }
        } catch {
            print("DELETE request error: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Stream Delegate

private class StreamDelegate: NSObject, URLSessionDataDelegate {
    private var buffer = Data()
    private let onData: (Data) -> Void
    private let onError: (Error) -> Void

    init(
        onData: @escaping (Data) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        self.onData = onData
        self.onError = onError
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)

        let dataCopy = Data(buffer)

        print("📥 Received chunk: \(data.count) bytes, buffer total: \(buffer.count) bytes")
        print("   First 20 bytes: \(dataCopy.prefix(20).map { String(format: "%02X", $0) }.joined(separator: " "))")

        onData(dataCopy)

        buffer.removeAll()
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 Stream response status: \(httpResponse.statusCode)")

            if httpResponse.statusCode == 401 {
                print("⚠️ 401 received - authentication required")
                print("   This usually means initial authentication didn't get nonce")
                print("   The stream will fail, please check authentication setup")
            }

            completionHandler(.allow)
        } else {
            completionHandler(.allow)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("❌ Stream completed with error: \(error.localizedDescription)")
            onError(error)
        } else {
            print("✅ Stream completed successfully")
        }
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
