//
//  APIConstants.swift
//  HonestHouse
//
//  Created by Subeen on 10/23/25.
//

import Foundation

struct APIConstants {
    static let contentType = "Content-Type"
    static let applicationJson = "application/json"
}

extension APIConstants {
    static var baseHeader: Dictionary<String, String> {
        [
            contentType : applicationJson
        ]
    }
}
