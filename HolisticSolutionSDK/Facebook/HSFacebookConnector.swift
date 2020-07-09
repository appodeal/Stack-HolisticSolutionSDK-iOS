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
        checkPlist()
        success()
    }
    
    public func setDebug(_ debug: HSAppConfiguration.Debug) {}
    
    func trackEvent(_ event: String, customParameters: [String : Any]?) {
        let name = AppEvents.Name(event)
        if let params = customParameters {
            AppEvents.logEvent(name, parameters: params)
        } else {
            AppEvents.logEvent(name)
        }
    }
    
    private func checkPlist() {
        let bundle = Bundle(for: type(of: self))
        let appId = bundle.object(forInfoDictionaryKey:"FacebookAppID") as? String
        assert(appId != nil, "Info.plist doesn't contain FacebookAppID. See https://developers.facebook.com/docs/app-events/getting-started-app-events-ios")
    }
}
