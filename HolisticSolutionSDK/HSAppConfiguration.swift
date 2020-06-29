//
//  HSAppConfiguration.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 25.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


@objc public
final class HSAppConfiguration: NSObject {
    let attribution: [HSAttributionPlatform]
    let productTesting: [HSProductTestingPlatform]
    let advertising: [HSAdvertisingPlatform]
    
    @objc public
    init(_ attributionPlatforms: [HSAttributionPlatform] = [],
         _ productTestingPlatforms: [HSProductTestingPlatform] = [],
         _ advertisingPlatforms: [HSAdvertisingPlatform] = []) {
        self.attribution    = attributionPlatforms
        self.productTesting = productTestingPlatforms
        self.advertising    = advertisingPlatforms
        super.init()
    }
}




