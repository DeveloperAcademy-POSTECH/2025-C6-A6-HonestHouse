//
//  ChunkedStreamParser.swift
//  HonestHouse
//
//  Created by Subeen on 10/27/25.
//

import Foundation
import UIKit

/// Canon 라이브뷰 청크 데이터 파서
actor ChunkedStreamParser {
    
    // MARK: - Protocol Constants
    private let START_BYTE_1: UInt8 = 0xFF
    private let START_BYTE_2: UInt8 = 0x00
    private let END_BYTE_1: UInt8 = 0xFF
    private let END_BYTE_2: UInt8 = 0xFF
    private let HEADER_SIZE = 7  // Start(2) + Type(1) + Size(4)
    private let END_SIZE = 2
    
    // MARK: - Data Types
    enum DataType: UInt8 {
        case image = 0x00
        case info = 0x01
        case event = 0x02
    }
    
    // MARK: - Parsed Data
    struct ParsedFrame {
        let type: DataType
        let data: Data
        let timestamp: Date
        
        var image: UIImage? {
            guard type == .image else { return nil }
            return UIImage(data: data)
        }
        
        var info: LiveViewInfo? {
            guard type == .info else { return nil }
            return try? JSONDecoder().decode(LiveViewInfo.self, from: data)
        }
    }
    
    // MARK: - Properties
    private var buffer = Data()
    private var currentDataSize: Int = 0
    private var isWaitingForHeader = true
    
    // MARK: - Public Methods
    
    /// 청크 데이터 추가 및 파싱
    func appendChunk(_ chunk: Data) -> [ParsedFrame] {
        buffer.append(chunk)
        print("   📥 Buffer size after append: \(buffer.count) bytes")
        
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
        currentDataSize = 0
        isWaitingForHeader = true
    }
    
    // MARK: - Private Methods
    
    private func parseNextFrame() -> ParsedFrame? {
        // 헤더 파싱 대기 중
        if isWaitingForHeader {
            // 모든 헤더 접근을 한 번에 체크
            guard buffer.count >= HEADER_SIZE,
                  buffer[0] == START_BYTE_1,
                  buffer[1] == START_BYTE_2 else {
                
                // 버퍼가 충분하지 않으면 그냥 리턴
                if buffer.count < HEADER_SIZE {
                    return nil
                }
                
                // 시작 바이트가 잘못되었으면 복구 시도
                print("   ⚠️ Invalid start bytes: \(String(format: "%02X %02X", buffer[0], buffer[1]))")
                
                if let nextStart = findNextStartSequence() {
                    print("   🔍 Found next start sequence at offset \(nextStart)")
                    buffer.removeFirst(nextStart)
                } else {
                    // 시작 바이트를 찾을 수 없음, 버퍼 클리어
                    print("   ❌ No start sequence found, clearing buffer")
                    buffer.removeAll()
                }
                return nil
            }
            
            // 여기 도달하면 buffer.count >= 7이 보장됨
            // 데이터 타입 추출
            let dataType = buffer[2]
            
            // 데이터 크기 추출 (Big Endian)
            let sizeBytes = buffer.subdata(in: 3..<7)
            currentDataSize = Int(sizeBytes.withUnsafeBytes { bytes in
                bytes.load(as: UInt32.self).bigEndian
            })
            
            print("   📋 Frame header parsed: type=0x\(String(format: "%02X", dataType)), size=\(currentDataSize) bytes")
            
            isWaitingForHeader = false
        }
        
        // 전체 프레임이 수신되었는지 확인
        let totalFrameSize = HEADER_SIZE + currentDataSize + END_SIZE
        guard buffer.count >= totalFrameSize else { return nil }
        
        // 종료 바이트 확인 (안전한 인덱스 접근)
        let endIndex = HEADER_SIZE + currentDataSize
        
        // endIndex와 endIndex+1이 모두 유효한지 확인
        guard endIndex < buffer.count,
              endIndex + 1 < buffer.count,
              buffer[endIndex] == END_BYTE_1,
              buffer[endIndex + 1] == END_BYTE_2 else {
            // 잘못된 프레임, 리셋
            print("   ⚠️ Invalid end bytes at position \(endIndex), buffer size: \(buffer.count)")
            reset()
            return nil
        }
        
        // 데이터 추출
        let dataType = DataType(rawValue: buffer[2]) ?? .image
        let frameData = buffer.subdata(in: HEADER_SIZE..<endIndex)
        
        print("   ✅ Complete frame extracted: type=\(dataType), data size=\(frameData.count) bytes")
        
        // 프레임 생성
        let frame = ParsedFrame(
            type: dataType,
            data: frameData,
            timestamp: Date()
        )
        
        // 처리된 데이터 제거
        buffer.removeFirst(totalFrameSize)
        isWaitingForHeader = true
        currentDataSize = 0
        
        return frame
    }
    
    private func findNextStartSequence() -> Int? {
        for i in 1..<buffer.count-1 {
            if buffer[i] == START_BYTE_1 && buffer[i+1] == START_BYTE_2 {
                return i
            }
        }
        return nil
    }
}

// MARK: - Supporting Types

struct LiveViewInfo: Codable {
    struct AFFrame: Codable {
        let x: Int
        let y: Int
        let width: Int
        let height: Int
        let status: String?
        let selected: Bool?
    }
    
    struct Histogram: Codable {
        let y: [Int]?
        let r: [Int]?
        let g: [Int]?
        let b: [Int]?
    }
    
    struct Zoom: Codable {
        let magnification: Double?
        let positionX: Int?
        let positionY: Int?
        let positionWidth: Int?
        let positionHeight: Int?
    }
    
    let afFrame: [AFFrame]?
    let histogram: Histogram?
    let zoom: Zoom?
    let angle: [String: Double]?
}

// MARK: - Debug Extension

extension ChunkedStreamParser {
    func debugPrintBuffer() {
        print("Buffer size: \(buffer.count)")
        if buffer.count > 0 {
            let preview = buffer.prefix(20).map { String(format: "%02X", $0) }.joined(separator: " ")
            print("Buffer preview: \(preview)")
        }
    }
}
