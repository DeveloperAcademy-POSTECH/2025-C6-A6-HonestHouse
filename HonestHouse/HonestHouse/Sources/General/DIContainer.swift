//
//  DIContainer.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation

class DIContainer: ObservableObject {
    var services: ServiceType
    var managers: ManagersType
    
    init(
        services: ServiceType
        managers: ManagersType,
    ) {
        self.services = services
        self.managers = managers
    }
}
