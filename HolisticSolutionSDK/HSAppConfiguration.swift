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
       
    let attribution: [HSAttributionService]
    let productTesting: [HSProductTestingService]
    let advertising: [HSAdvertising]
    let timeout: TimeInterval
    let debug: Debug
    
    @objc public
    init(attributionPlatforms: [HSAttributionService] = [],
         productTestingPlatforms: [HSProductTestingService] = [],
         advertisingPlatforms: [HSAdvertising] = [],
         timeout: TimeInterval = kHSAppDefaultTimeout,
         debug: Debug = .system) {
        self.attribution    = attributionPlatforms
        self.productTesting = productTestingPlatforms
        self.advertising    = advertisingPlatforms
        self.timeout        = timeout
        self.debug          = debug
        super.init()
    }
}



