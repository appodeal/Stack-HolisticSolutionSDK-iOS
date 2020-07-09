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
    func collect(receiveAttributionId: @escaping ((String) -> Void),
                receiveData: @escaping (([AnyHashable: Any]?) -> Void))
    
    func validateAndTrackInAppPurchase(
        _ purchase: HSPurchase,
        success:(([AnyHashable: Any]) -> Void)?,
        failure:((Error?, Any?) -> Void)?
    )
}

protocol HSProductTestingService: HSService {
    func activateConfig(completion: @escaping (([AnyHashable: Any]?) -> Void))
}


protocol HSAnalyticsService: HSService {
    func trackEvent(_ event: String, customParameters: [String: Any]?)
}
