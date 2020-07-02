//
//  HSInternalServices.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 01.07.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


struct HSPurchase {
    var productId, price, currency, transactionId: String
    var additionalParameters: [AnyHashable: Any]
}

protocol HSAttributionService: HSService {
    var onReceiveAttributionId: ((String) -> Void)? { get set }
    var onReceiveData: (([AnyHashable: Any]) -> Void)? { get set }
    
    func validateAndTrackInAppPurchase(
        _ purchase: HSPurchase,
        success:(([AnyHashable: Any]) -> Void)?,
        failure:((Error?, Any?) -> Void)?
    )
}

protocol HSProductTestingService: HSService {
    var onReceiveConfig: (([AnyHashable: Any]) -> Void)? { get set }
}


protocol HSAnalyticsService: HSService {
    func trackEvent(_ event: String, customParameters: [String: Any]?)
}
