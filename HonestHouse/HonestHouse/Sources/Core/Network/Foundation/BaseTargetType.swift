//
//  BaseTargetType.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation
import Moya

protocol BaseTargetType: TargetType {}

extension BaseTargetType {
    public var baseURL: URL {
        return URL(string: BaseAPI.base.apiDesc)!
    }
    
    public var headers: [String : String]? {
        return APIConstants.baseHeader
    }
}
