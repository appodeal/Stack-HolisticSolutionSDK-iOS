//
//  FacebookConnector.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 01.07.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation
import FBSDKCoreKit


@objc(HSFacebookConnector) public final
class FacebookConnector: NSObject, Service {
    struct Parameters {
        static let id: String = "facebook"
        
        var tracking: Bool
    }

    
    public var name: String { Parameters.id }
    public var sdkVersion: String { FBSDK_VERSION_STRING }
    public var version: String { sdkVersion + ".1" }
//    let parameters: FacebookParameters
//
//    @objc public convenience
//    init(tracking: Bool = true) {
//        let parameters: FacebookParameters = .init(tracking: tracking)
//        self.init(parameters: parameters)
//    }
//
//    init(parameters: FacebookParameters) {
//        self.parameters = parameters
//        super.init()
//    }
}


extension FacebookConnector {//: AnalyticsService {
//    public func initialise(
//        success: @escaping () -> Void,
//        failure: @escaping (HSError) -> Void
//    ) {
//        if checkPlist() {
//            success()
//        } else {
//            failure(.integration)
//        }
//    }
//
//    func trackEvent(_ event: String, customParameters: [String : Any]?) {
//        guard parameters.tracking else { return }
//        let name = AppEvents.Name(event)
//        if let params = customParameters {
//            AppEvents.logEvent(name, parameters: params)
//        } else {
//            AppEvents.logEvent(name)
//        }
//    }
//
//    private func checkPlist() -> Bool {
//        let bundle = Bundle(for: type(of: self))
//        let appId = bundle.object(forInfoDictionaryKey:"FacebookAppID") as? String
//        return appId != nil
//    }
//
//    //MARK: - Noop
//    func trackInAppPurchase(_ purchase: Purchase) {}
//    public func setDebug(_ debug: AppConfiguration.Debug) {}
}
