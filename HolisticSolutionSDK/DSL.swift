//
//  DSL.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 17.05.2021.
//  Copyright © 2021 com.appodeal. All rights reserved.
//

import Foundation
import UIKit
import Appodeal

@objc public
enum HSError: Int, Error {
    case integration = 0
    case timeout
    case service
    
    var nserror: NSError { NSError.from(self) }
}


@objc(HSPurchaseType) public
enum PurchaseType: Int {
    case consumable = 0
    case nonConsumable
    case autoRenewableSubscription
    case nonRenewingSubscription
    
}


@objc(HSDSL) public
protocol DSL {
    func register(connectors: [Service.Type])

    func initialize(
        application: UIApplication,
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
        configuration: AppConfiguration
    )
    
    func initialize(
        application: UIApplication,
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
        appKey: String
    )
    
    func validateAndTrackInAppPurchase(
        productId: String,
        type: PurchaseType,
        price: String,
        currency: String,
        transactionId: String,
        additionalParameters: [String: Any],
        success:(([AnyHashable: Any]) -> Void)?,
        failure:((Error?, Any?) -> Void)?
    )
    
    func trackEvent(
        _ eventName: String,
        customParameters: [String: Any]?
    )
}


@objc public
extension Appodeal {
    @objc static
    var hs: DSL { App.shared }
}


fileprivate extension NSError {
    static func from(_ error: HSError) -> NSError {
        let domain = "com.explorestack.hs"
        let userInfo: [String: Any]
        switch error {
        case .integration: userInfo = [ NSLocalizedDescriptionKey: "Some of input paramerers was invalid" ]
        case .service: userInfo = [ NSLocalizedDescriptionKey: "Error has been occurred while starting service" ]
        case .timeout: userInfo = [ NSLocalizedDescriptionKey: "HSApp timeout has been reached" ]
        }
        
        return NSError(
            domain: domain,
            code: error.rawValue,
            userInfo: userInfo
        )
    }
}
