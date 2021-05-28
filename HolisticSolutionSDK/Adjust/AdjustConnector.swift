//
//  AdjustConnector.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 13.05.2021.
//  Copyright © 2021 com.appodeal. All rights reserved.
//

import Foundation
import UIKit
import Adjust
import AdjustPurchase


@objc(HSAdjustConnector) public final
class AdjustConnector: NSObject, Service {
    struct Parameters {
        var appToken, environment: String
        var tracking: Bool
        
        init?(_ parameters: RawParameters) {
            guard
                let appToken = parameters["app_token"] as? String,
                let environment = parameters["environment"] as? String,
                let tracking = parameters["tracking"] as? Bool
            else { return nil }
            
            self.appToken = appToken
            self.environment = environment
            self.tracking = tracking
        }
    }
    
    public var name: String { "adjust" }
    public var sdkVersion: String { Adjust.sdkVersion() ?? "" }
    public var version: String { sdkVersion + ".1" }
    
    public var onReceiveConversionData: (([AnyHashable : Any]?) -> Void)?
}


extension AdjustConnector: RawParametersInitializable {//: AttributionService {
    func initialize(
        _ parameters: RawParameters,
        completion: @escaping (HSError?) -> ()
    ) {
        guard let parameters = Parameters(parameters) else {
            completion(.service)
            return
        }
        
        let config = ADJConfig(
            appToken: parameters.appToken,
            environment: parameters.environment
        )
        config?.delegate = self
        Adjust.appDidLaunch(config)
        
        let purchaseConfig = ADJPConfig(
            appToken: parameters.appToken,
            andEnvironment: parameters.environment
        )
        AdjustPurchase.`init`(purchaseConfig)
        
        completion(nil)
    }
    //
    //    func validateAndTrackInAppPurchase(
    //        _ purchase: Purchase,
    //        success: (([AnyHashable : Any]) -> Void)?,
    //        failure: ((Error?, Any?) -> Void)?
    //    ) {
    //        guard
    //            let recieptURL = Bundle.main.appStoreReceiptURL,
    //            let reciept = try? Data(contentsOf: recieptURL)
    //        else {
    //            failure?(HSError.service.nserror, nil)
    //            return
    //        }
    //
    //        AdjustPurchase.verifyPurchase(
    //            reciept,
    //            forTransaction: purchase.productId,
    //            productId: purchase.productId
    //        ) { [weak self] info in
    //            guard
    //                let info = info,
    //                info.verificationState == ADJPVerificationStatePassed
    //            else {
    //                failure?(HSError.service.nserror, nil)
    //                return
    //            }
    //            self?.trackInAppPurchase(purchase)
    //            #warning("Success")
    //        }
    //    }
}

extension AdjustConnector: AttributionService {
    func collect(receiveAttributionId: @escaping ((String) -> Void), receiveData: @escaping (([AnyHashable : Any]?) -> Void)) {
        Adjust.adid().map(receiveAttributionId)
        Adjust.attribution().flatMap { $0.dictionary() }.map(receiveData)
        onReceiveConversionData = receiveData
    }
    
    func validateAndTrackInAppPurchase(
        _ purchase: Purchase,
        success: (([AnyHashable : Any]) -> Void)?,
        failure: ((Error?, Any?) -> Void)?
    ) {
        
    }
}

extension AdjustConnector: AdjustDelegate {
    public
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        attribution.flatMap { $0.dictionary() }.map { onReceiveConversionData?($0) }
    }
}


extension AdjustConnector {//: AnalyticsService {
    func trackEvent(_ event: String, customParameters: [String : Any]?) {}
    
    //MARK: - Noop
    func trackInAppPurchase(_ purchase: Purchase) {}
}
