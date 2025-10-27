//
//  SavingState.swift
//  HonestHouse
//
//  Created by Rama on 10/27/25.
//

import Foundation

enum SavingState: Equatable {
    case idle
    case saving
    case success
    case failure(String)
}
