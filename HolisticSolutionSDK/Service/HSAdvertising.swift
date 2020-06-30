//
//  HSAdvertisingPlatform.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 25.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


@objc public protocol HSAdvertising: class {
    @objc func setAttributionId(_ attributionId: String)
    @objc func setConversionData(_ converstionData: [AnyHashable: Any])
    @objc func setProductTestData(_ productTestData: [AnyHashable: Any])
}

