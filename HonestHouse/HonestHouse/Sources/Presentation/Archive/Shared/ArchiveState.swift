//
//  ArchiveState.swift
//  HonestHouse
//
//  Created by 이현주 on 10/27/25.
//

import Foundation

enum ArchiveState<Success: Equatable, Failure: Error & Equatable>: Equatable {
    case idle
    case loading
    case success(Success)
    case failure(Failure)
}
