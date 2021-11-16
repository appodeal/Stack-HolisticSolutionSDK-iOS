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
import StoreKit


@objc(HSAdjustConnector) public final
class AdjustConnector: NSObject, Service {
    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        return formatter
    }()
    
    fileprivate struct FallbackInfo {
        var event: EventKey
        var message: String
    }
    
    fileprivate enum EventKey: RawRepresentable {
        typealias RawValue = String
        
        case unknown
        case purchase
        case purchaseVerificationError
        case custom(String)
        
        init?(rawValue: String) {
            switch rawValue {
            case "hs_sdk_unknown": self = .unknown
            case "hs_sdk_purchase": self = .purchase
            case "hs_sdk_purchase_error": self = .purchaseVerificationError
            default: self = .custom(rawValue)
            }
        }
        
        var rawValue: String {
            switch self {
            case .purchase: return "hs_sdk_purchase"
            case .unknown: return "hs_sdk_unknown"
            case .purchaseVerificationError: return "hs_sdk_purchase_error"
            case .custom(let value): return value
            }
        }
    }
    
    struct Parameters {
        var appToken, environment: String
        var tracking: Bool
        private var events: [String: String]
        
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
        
        fileprivate func token(for event: EventKey) -> String? {
            return events[event.rawValue]
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
    
    public func set(partnerParameters: [String: String]) {
        App.log("Set partner parameters: \(partnerParameters) to service \(name)")
        partnerParameters.forEach {
            Adjust.addSessionCallbackParameter($0.key, value: $0.value)
            Adjust.addSessionPartnerParameter($0.key, value: $0.value)
        }
    }
}

// MARK: Protocols
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
    func collect(
        receiveAttributionId: @escaping ((String) -> Void),
        receiveData: @escaping (([AnyHashable : Any]?) -> Void)
    ) {
        Adjust.adid().map(receiveAttributionId)
        Adjust.attribution().flatMap { $0.dictionary() }.map(receiveData)
        onReceiveConversionData = receiveData
    }
    
    func validateAndTrackInAppPurchase(
        _ purchase: Purchase,
        partnerParameters: [String: String],
        success: (([AnyHashable : Any]) -> Void)?,
        failure: ((Error?, Any?) -> Void)?
    ) {
        guard let reciept = Bundle.main.receipt else {
            failure?(HSError.unknown("No app store receipt url was found").nserror, nil)
            return
        }
        
        guard
            let transaction = SKPaymentQueue
                .default()
                .transactions
                .first(where: { $0.transactionIdentifier == purchase.transactionId })
        else {
            failure?(HSError.unknown("Transaction was not found").nserror, nil)
            return
        }
        
        AdjustPurchase.verifyPurchase(
            reciept,
            forTransaction: transaction,
            productId: purchase.productId
        ) { [weak self] info in
            guard
                let info = info,
                info.verificationState == ADJPVerificationStatePassed
            else {
                self?.fallback(
                    .init(
                        event: .purchaseVerificationError,
                        message: "Purchase \(purchase.transactionId) for product \(purchase.productId) verificaition failed"
                    ),
                    partnerParameters: partnerParameters
                )
                failure?(HSError.service("Purchase was't passed verification"), nil)
                return
            }
            self?.trackInAppPurchase(
                purchase,
                partnerParameters: partnerParameters
            )
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


extension AdjustConnector: AnalyticsService {
    func trackEvent(
        _ event: String,
        customParameters: [String: Any]?,
        partnerParameters: [String: String]
    ) {
        guard parameters.tracking else { return }
        
        guard let token = parameters.token(for: .custom(event)) else {
            fallback(
                .init(
                    event: .custom(event),
                    message: "Token was not found"
                ),
                partnerParameters: partnerParameters
            )
            return
        }
        
        let adjEvent = ADJEvent(
            token: token,
            parameters: customParameters,
            partnerParameters: partnerParameters
        )
        
        Adjust.trackEvent(adjEvent)
    }
    
    func trackInAppPurchase(
        _ purchase: Purchase,
        partnerParameters: [String: String]
    ) {
        switch purchase.type {
        case .consumable, .nonConsumable:
            _trackInAppPurchase(
                purchase,
                partnerParameters: partnerParameters
            )
        case .autoRenewableSubscription, .nonRenewingSubscription:
            _trackSubscription(
                purchase,
                partnerParameters: partnerParameters
            )
        }
    }
    
    private func _trackInAppPurchase(
        _ purchase: Purchase,
        partnerParameters: [String: String]
    ) {
        guard let token = parameters.token(for: .purchase) else {
            fallback(
                .init(
                    event: .purchase,
                    message: "Token was not found"
                ),
                partnerParameters: partnerParameters
            )
            return
        }
        
        guard let receipt = Bundle.main.receipt else {
            fallback(
                .init(
                    event: .purchase,
                    message: "AppStore receipt was not found"
                ),
                partnerParameters: partnerParameters
            )
            return
        }
        
        guard let price = AdjustConnector.priceFormatter.number(from: purchase.price) as? NSDecimalNumber else {
            fallback(
                .init(
                    event: .purchase,
                    message: "Unable to serialize price \(purchase.price)"
                ),
                partnerParameters: partnerParameters
            )
            return
        }
        
        let event = ADJEvent(
            token: token,
            parameters: nil,
            partnerParameters: partnerParameters
        )
        
        event?.setRevenue(price.doubleValue, currency: purchase.currency)
        event?.setReceipt(receipt, transactionId: purchase.transactionId)
        
        Adjust.trackEvent(event)
    }
    
    private func _trackSubscription(
        _ purchase: Purchase,
        partnerParameters: [String: String]
    ) {
        guard let receipt = Bundle.main.receipt else {
            fallback(
                .init(
                    event: .purchase,
                    message: "AppStore receipt was not found"
                ),
                partnerParameters: partnerParameters
            )
            return
        }
        
        guard
            let price = AdjustConnector
                .priceFormatter
                .number(from: purchase.price) as? NSDecimalNumber
        else {
            fallback(
                .init(
                    event: .purchase,
                    message: "Unable to serialize price \(purchase.price)"
                ),
                partnerParameters: partnerParameters
            )
            return
        }
        
        guard let subscription = ADJSubscription(
            price: price,
            currency: purchase.currency,
            transactionId: purchase.transactionId,
            andReceipt: receipt
        ) else {
            fallback(
                .init(
                    event: .purchase,
                    message: "Unable to create subscription"
                ),
                partnerParameters: partnerParameters
            )
            return
        }
        
        Adjust.trackSubscription(subscription)
    }
    
    private func fallback(
        _ info: FallbackInfo,
        partnerParameters: [String: String]
    ) {
        guard let token = parameters.token(for: .unknown) else { return }
        let event = ADJEvent(
            token: token,
            fallbackInfo: info,
            partnerParameters: partnerParameters
        )
        Adjust.trackEvent(event)
    }
}


// MARK: Extensions
private extension Bundle {
    var receipt: Data? {
        return appStoreReceiptURL.flatMap { try? Data(contentsOf: $0) }
    }
}


private extension STKAd {
    static var isZeroIDFA: Bool {
        return "00000000-0000-0000-0000-000000000000" == advertisingIdentifier
    }
}


private extension ADJEvent {
    convenience init?(
        token: String,
        parameters: [String: Any]?,
        partnerParameters: [String: String]
    ) {
        self.init(eventToken: token)
        parameters?.forEach {
            if let value = $0.value as? String {
                addCallbackParameter($0.key, value: value)
                addPartnerParameter($0.key, value: value)
            }
        }
        partnerParameters.forEach {
            addCallbackParameter($0.key, value: $0.value)
            addPartnerParameter($0.key, value: $0.value)
        }
    }
    
    convenience init?(
        token: String,
        fallbackInfo: AdjustConnector.FallbackInfo,
        partnerParameters: [String: String]
    ) {
        self.init(
            token: token,
            parameters: [
                "event": fallbackInfo.event.rawValue,
                "reason": fallbackInfo.message
            ],
            partnerParameters: partnerParameters
        )
    }
}
