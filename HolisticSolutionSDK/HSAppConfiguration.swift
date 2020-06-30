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
       
    let attribution: [HSAttributionPlatform]
    let productTesting: [HSProductTestingPlatform]
    let advertising: [HSAdvertisingPlatform]
    let timeout: TimeInterval
    let debug: Debug
    
    @objc public
    init(attributionPlatforms: [HSAttributionPlatform] = [],
         productTestingPlatforms: [HSProductTestingPlatform] = [],
         advertisingPlatforms: [HSAdvertisingPlatform] = [],
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

@objc public protocol HSDebuggable: class {
    func setDebug(_ debug: HSAppConfiguration.Debug)
}




