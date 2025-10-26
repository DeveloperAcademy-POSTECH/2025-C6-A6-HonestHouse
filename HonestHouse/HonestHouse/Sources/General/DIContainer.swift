//
//  DIContainer.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation

class DIContainer: ObservableObject {
    var services: ServiceType
    
    init(
        services: ServiceType
    ) {
        self.services = services
    }
}
