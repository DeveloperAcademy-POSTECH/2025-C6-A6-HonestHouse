//
//  ChunkedStreamParser.swift
//  HonestHouse
//
//  Created by Subeen on 10/27/25.
//

import Foundation
import UIKit

actor ChunkedStreamParser {
    private var buffer = Data()
    private let streamType: StreamType

    init(streamType: StreamType) {
        self.streamType = streamType
    }

    func appendChunk(_ chunk: Data) {
        buffer.append(chunk)
    }

    func extractFrames() -> [ParsedFrame] {
        var frames: [ParsedFrame] = []

        while let frame = parseNextFrame() {
            frames.append(frame)
        }

        if frames.isEmpty && buffer.count > 0 {
            print("   ⏳ Waiting for more data (buffer: \(buffer.count) bytes)")
        }

        return frames
    }

    /// 버퍼 리셋
    func reset() {
        buffer.removeAll()
    }

    // MARK: - Private Methods
    private func parseNextFrame() -> ParsedFrame? {
        switch streamType {
        }
    }

    private func parseScrollFrame() -> ParsedFrame? {
        let localBuffer = Data(self.buffer)
        print("🚨\(localBuffer.map { String(format: "%02X", $0) }.joined(separator: " "))🚨")
        
        // 1. 복사된 localBuffer에서 SOI를 찾습니다.
        guard let soiRange = localBuffer.range(of: Data([0xFF, 0xD8])) else {
            return nil
        }
        
        // 2. SOI 이후부터 EOI를 찾습니다.
        let searchEoiStartIndex = soiRange.upperBound
        guard let eoiRange = localBuffer.range(of: Data([0xFF, 0xD9]), in: searchEoiStartIndex..<localBuffer.count) else {
            return nil
        }
        
        // 3. SOI부터 EOI까지의 데이터로 프레임을 추출합니다.
        let jpegData = localBuffer.subdata(in: soiRange.lowerBound..<eoiRange.upperBound)
        
        let frame = ParsedFrame(
            type: .image,
            data: jpegData,
            timestamp: Date()
        )
        
        // 4. 모든 계산이 끝난 후, 파싱에 사용된 만큼 원본 buffer에서 데이터를 제거합니다.
        // 제거할 크기는 버퍼 시작부터 EOI 끝까지의 위치입니다.
        let bytesToRemove = eoiRange.upperBound
        self.buffer.removeFirst(bytesToRemove)
        
        return frame
    }

     private func parseScrollDetailFrame() -> ParsedFrame? {
         return nil
     }
 }
