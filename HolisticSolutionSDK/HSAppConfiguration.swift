//
//  HSAppConfiguration.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 25.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


public let kHSAppDefaultTimeout: TimeInterval = 60.0

@objc public
final class HSAppConfiguration: NSObject {
    let attribution: [HSAttributionPlatform]
    let productTesting: [HSProductTestingPlatform]
    let advertising: [HSAdvertisingPlatform]
    let timeout: TimeInterval
    
    @objc public
    init(attributionPlatforms: [HSAttributionPlatform] = [],
         productTestingPlatforms: [HSProductTestingPlatform] = [],
         advertisingPlatforms: [HSAdvertisingPlatform] = [],
         timeout: TimeInterval = kHSAppDefaultTimeout) {
        self.attribution    = attributionPlatforms
        self.productTesting = productTestingPlatforms
        self.advertising    = advertisingPlatforms
        self.timeout        = timeout
        super.init()
    }
}




