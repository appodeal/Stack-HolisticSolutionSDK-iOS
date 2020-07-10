//
//  AppsFlyerConnector.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 25.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation
import UIKit
import AppsFlyerLib


@objc public
final class HSAppsFlyerConnector: NSObject {
    public typealias Success = () -> Void
    public typealias Failure = (HSError) -> Void
    
    private let devKey: String
    private let appId: String
    private let keys: [String]
    
    public var id: String { return AppsFlyerTracker.shared().getAppsFlyerUID() }
    public var onReceiveData: (([AnyHashable : Any]?) -> Void)?

    @objc public weak var delegate: AppsFlyerTrackerDelegate?
    
    @objc public
    init(devKey: String,
         appId: String,
         keys: [String] = []) {
        self.devKey = devKey
        self.appId = appId
        self.keys = keys
        super.init()
    }
    
    @objc private
    func didBecomeActive(notification: Notification) {
        AppsFlyerTracker.shared().trackAppLaunch()
    }
}


extension HSAppsFlyerConnector: HSAttributionService {
    public func initialise(success: @escaping Success,
                           failure: @escaping Failure) {
        
        AppsFlyerTracker.shared().appsFlyerDevKey = devKey
        AppsFlyerTracker.shared().appleAppID = appId
        AppsFlyerTracker.shared().delegate = self

        success()
    }
    
    public func setDebug(_ debug: HSAppConfiguration.Debug) {
        // Set isDebug to true to see AppsFlyer debug logs
        switch debug {
        case .disabled:
            AppsFlyerTracker.shared().isDebug = false
        case .enabled:
            AppsFlyerTracker.shared().isDebug = true
        case .system:
            #if DEBUG
                AppsFlyerTracker.shared().isDebug = true
            #endif
        }
    }
    
    func collect(receiveAttributionId: @escaping ((String) -> Void),
                 receiveData: @escaping (([AnyHashable : Any]?) -> Void)) {
        // Register notifications
        self.onReceiveData = receiveData
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive(notification:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        // Force to track launch
        AppsFlyerTracker.shared().trackAppLaunch()
        // Return attribution id
        DispatchQueue.main.async { [unowned self] in receiveAttributionId(self.id) }
    }
    
    func validateAndTrackInAppPurchase(
        _ purchase: HSPurchase,
        success: (([AnyHashable : Any]) -> Void)?,
        failure: ((Error?, Any?) -> Void)?
    ) {
        AppsFlyerTracker.shared().validateAndTrack(
            inAppPurchase: purchase.productId,
            price: purchase.price,
            currency: purchase.currency,
            transactionId: purchase.transactionId,
            additionalParameters: purchase.additionalParameters,
            success: success,
            failure: failure
        )
    }
}

extension HSAppsFlyerConnector: HSPlistDecodableExtended {
    public convenience init(plistName: String) throws {
        let decoder = PropertyListDecoder()
        let config = try decoder.decodeConfiguration(fromPlist: plistName).appsFlyer
        self.init(devKey: config.devKey, appId: config.appId)
    }
}

extension HSAppsFlyerConnector: AppsFlyerTrackerDelegate {
    public
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        let data = keys.count > 0 ?
            conversionInfo.filter { pair in (pair.key as? String).map(keys.contains) ?? false } :
            conversionInfo
        DispatchQueue.main.async { [unowned self] in
            self.onReceiveData?(data)
            self.onReceiveData = nil
        }
        delegate?.onConversionDataSuccess(conversionInfo)
    }
    
    public
    func onConversionDataFail(_ error: Error) {
        DispatchQueue.main.async { [unowned self] in
            self.onReceiveData?(nil)
            self.onReceiveData = nil
        }
        delegate?.onConversionDataFail(error)
    }
    
    // MARK: Optional
    public
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        delegate?.onAppOpenAttribution?(attributionData)
    }
    
    public
    func onAppOpenAttributionFailure(_ error: Error) {
        delegate?.onAppOpenAttributionFailure?(error)
    }
    
    public
    func allHTTPHeaderFields(forResolveDeepLinkURL URL: URL) -> [String : String]? {
        return delegate?.allHTTPHeaderFields?(forResolveDeepLinkURL: URL)
    }
} 

extension HSAppsFlyerConnector: HSAnalyticsService {
    func trackEvent(_ event: String, customParameters: [String : Any]?) {
        AppsFlyerTracker.shared().trackEvent(event, withValues: customParameters)
    }
}
