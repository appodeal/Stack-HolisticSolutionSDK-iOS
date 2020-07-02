//
//  FacebookConnector.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 01.07.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation
import FBSDKCoreKit


@objc public
final class HSFacebookConnector: NSObject {}


extension HSFacebookConnector: HSAnalyticsService {
    public func initialise(success: @escaping () -> Void,
                           failure: @escaping (HSError) -> Void) {
        success()
    }
    
    public func setDebug(_ debug: HSAppConfiguration.Debug) {
        
    }
    
    func trackEvent(_ event: String, customParameters: [String : Any]?) {
        let name = AppEvents.Name(event)
        if let params = customParameters {
            AppEvents.logEvent(name, parameters: params)
        } else {
            AppEvents.logEvent(name)
        }
    }
}
