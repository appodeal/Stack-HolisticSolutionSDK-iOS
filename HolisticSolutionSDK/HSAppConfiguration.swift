//
//  HSAppConfiguration.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 25.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


public let kHSAppDefaultTimeout: TimeInterval = 30.0

@objc public
final class HSAppConfiguration: NSObject {
    @objc public
    enum Debug: Int {
        case system
        case enabled
        case disabled
    }
    
    private let services: [HSService]
    
    internal let connectors: [HSAdvertising]
    internal let timeout: TimeInterval
    internal let debug: Debug
    
    internal var productTesting: [HSProductTestingService] {
        services.compactMap { $0 as? HSProductTestingService }
    }
    
    internal var attribution: [HSAttributionService] {
        services.compactMap { $0 as? HSAttributionService }
    }
    
    internal var analytics: [HSAnalyticsService] {
        services.compactMap { $0 as? HSAnalyticsService }
    }
    
    @objc public
    init(services: [HSService] = [],
         connectors: [HSAdvertising] = [],
         timeout: TimeInterval = kHSAppDefaultTimeout,
         debug: Debug = .system) {
        self.services       = services
        self.connectors     = connectors
        self.timeout        = timeout
        self.debug          = debug
        super.init()
    }
}



