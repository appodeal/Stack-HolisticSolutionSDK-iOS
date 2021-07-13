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
import StackFoundation


@objc(HSAdjustConnector) public final
class AdjustConnector: NSObject, Service {
    struct Parameters {
        var appToken, environment: String
        var tracking: Bool
        var events: [String: String]
        
        init(
            appToken: String = "",
            environment: String = "sandbox",
            tracking: Bool = false,
            events: [String: String] = [:]
        ) {
            self.appToken = appToken
            self.environment = environment
            self.tracking = tracking
            self.events = events
        }
        
        init?(_ parameters: RawParameters) {
            guard
                let appToken = parameters["app_token"] as? String,
                let environment = parameters["environment"] as? String,
                let tracking = parameters["tracking"] as? Bool
            else { return nil }
            
            let events = parameters["events"] as? [String: String] ?? [:]
            
            self.init(
                appToken: appToken,
                environment: environment,
                tracking: tracking,
                events: events
            )
        }
    }
    
    public var name: String { "adjust" }
    public var sdkVersion: String { Adjust.sdkVersion() ?? "" }
    public var version: String { sdkVersion + ".1" }
    public var onReceiveConversionData: (([AnyHashable : Any]?) -> Void)?
   
    private var onCompleteInitialization: ((HSError?) -> ())?
    private var parameters = Parameters()
    private var debug: AppConfiguration.Debug = .system
    
    public func set(debug: AppConfiguration.Debug) {
        self.debug = debug
    }
}


extension AdjustConnector: RawParametersInitializable {
    func initialize(
        _ parameters: RawParameters,
        completion: @escaping (HSError?) -> ()
    ) {
        guard let parameters = Parameters(parameters) else {
            completion(.service("Unable to decode Adjust parameters"))
            return
        }
        
        self.parameters = parameters
        self.onCompleteInitialization = completion
        
        let config = ADJConfig(
            appToken: parameters.appToken,
            environment: parameters.environment
        )
        
        config?.delegate = self
        switch debug {
        case .enabled: config?.logLevel = ADJLogLevelVerbose
        case .disabled: config?.logLevel = ADJLogLevelSuppress
        default: break
        }
        
        if STKAd.isZeroIDFA {
            config?.externalDeviceId = STKAd.generatedAdvertisingIdentifier
        }
        
        Adjust.addSessionCallbackParameter("externalDeviceId", value: STKAd.generatedAdvertisingIdentifier)
        
        Adjust.appDidLaunch(config)

        let purchaseConfig = ADJPConfig(
            appToken: parameters.appToken,
            andEnvironment: parameters.environment
        )
        
        switch debug {
        case .enabled: purchaseConfig?.logLevel = ADJPLogLevelVerbose
        case .disabled: purchaseConfig?.logLevel = ADJPLogLevelNone
        default: break
        }
        
        AdjustPurchase.`init`(purchaseConfig)
        
        if let _ = Adjust.adid() {
            self.onCompleteInitialization = nil
            completion(nil)
        }
    }
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
        guard
            let recieptURL = Bundle.main.appStoreReceiptURL,
            let reciept = try? Data(contentsOf: recieptURL)
        else {
            failure?(HSError.unknown("No app store receipt url was found").nserror, nil)
            return
        }
        
        AdjustPurchase.verifyPurchase(
            reciept,
            forTransaction: purchase.productId,
            productId: purchase.productId
        ) { [weak self] info in
            guard
                let info = info,
                info.verificationState == ADJPVerificationStatePassed
            else {
                failure?(HSError.service("Purchase was't passed verification"), nil)
                return
            }
            self?.trackInAppPurchase(purchase)
            success?(["message": info.message].compactMapValues { $0 })
        }
    }
}

extension AdjustConnector: AdjustDelegate {
    public
    func adjustSessionTrackingSucceeded(_ sessionSuccessResponseData: ADJSessionSuccess?) {
        onCompleteInitialization?(nil)
        onCompleteInitialization = nil
    }
    
    public
    func adjustEventTrackingFailed(_ eventFailureResponseData: ADJEventFailure?) {
        let message = eventFailureResponseData?.message ?? "Unknown adjust initialization"
        onCompleteInitialization?(.service(message))
        onCompleteInitialization = nil
    }
    
    public
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        onCompleteInitialization?(nil)
        onCompleteInitialization = nil
        attribution
            .flatMap { $0.dictionary() }
            .map {
                onReceiveConversionData?($0)
                onReceiveConversionData = nil
            }
    }
}

private extension STKAd {
    static var isZeroIDFA: Bool {
        return "00000000-0000-0000-0000-000000000000" == advertisingIdentifier
    }
}

extension AdjustConnector {
    func trackEvent(_ event: String, customParameters: [String : Any]?) {
        guard
            parameters.tracking,
            let token = parameters.events[event]
        else { return }
        
        let adjEvent = ADJEvent(eventToken: token)
        Adjust.trackEvent(adjEvent)
    }
    
    //MARK: - Noop
    func trackInAppPurchase(_ purchase: Purchase) {}
}
