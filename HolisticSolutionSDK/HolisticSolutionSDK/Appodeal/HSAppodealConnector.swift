//
//  HSAppodealConnector.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 26.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation
import Appodeal


@objc public
extension HSAppConfiguration {
    @objc convenience
    init(attribution: HSAttributionPlatform,
         productTesting: HSProductTestingPlatform,
         advertising: HSAdvertisingPlatform = HSAppodealConnector()) {
        self.init([attribution], [productTesting], [advertising])
    }
}


@objc public
final class HSAppodealConnector: NSObject {}

extension HSAppodealConnector: HSAdvertisingPlatform {
    public func setAttributionId(_ attributionId: String) {
        Appodeal.setExtras(["attribution_id": attributionId])
    }
    
    public func setConversionData(_ converstionData: [AnyHashable : Any]) {
        Appodeal.setSegmentFilter(converstionData)
    }
    
    public func setProductTestData(_ productTestData: [AnyHashable : Any]) {
        let keywords = productTestData.values.compactMap { $0 as? String }.joined(separator: ",")
        Appodeal.setExtras(["keywords": keywords])
    }
}
