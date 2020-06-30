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
    private let devKey: String
    private let appId: String
    
    public var id: String? { return AppsFlyerTracker.shared().getAppsFlyerUID() }
    public var onReceiveData: (([AnyHashable : Any]) -> Void)?
    fileprivate var completion: ((HSAttributionPlatform) -> Void)?
    
    @objc public
    init(devKey: String,
         appId: String) {
        self.devKey = devKey
        self.appId = appId
        super.init()
    }
    
    @objc private
    func didBecomeActive(notification: Notification) {
        AppsFlyerTracker.shared().trackAppLaunch()
    }
}


extension HSAppsFlyerConnector: HSAttributionPlatform {
    public func initialise(completion: @escaping (HSAttributionPlatform) -> Void) {
        self.completion = completion
        
        AppsFlyerTracker.shared().appsFlyerDevKey = devKey
        AppsFlyerTracker.shared().appleAppID = appId
        AppsFlyerTracker.shared().delegate = self
        
        // Register notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive(notification:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
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
        onReceiveData?(conversionInfo)
        completion?(self)
        completion = nil
    }
    
    public
    func onConversionDataFail(_ error: Error) {
        completion?(self)
        completion = nil
    }
} 
