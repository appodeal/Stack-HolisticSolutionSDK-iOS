//
//  AppsflyerConnector.swift
//  Sample
//
//  Created by Stas Kochkin on 04.05.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation
import AppsFlyerLib
import Appodeal



final class AppsFlyerConnector: NSObject, Connector {
    func initialise(completion: @escaping Completion) {
        // Configure AppsFlyer
        AppsFlyerTracker.shared().appsFlyerDevKey = servicesInfo.appsFlyer.devKey
        AppsFlyerTracker.shared().appleAppID = servicesInfo.appsFlyer.appId
        AppsFlyerTracker.shared().delegate = self
        // Set isDebug to true to see AppsFlyer debug logs
        AppsFlyerTracker.shared().isDebug = true
        // Register notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didLaunch),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        // Get AppsFlyer UID
        Appodeal.setExtras([
            kAPDAppsFlyerIdExtrasKey: AppsFlyerTracker.shared().getAppsFlyerUID()
        ])
        DispatchQueue.main.async(execute: completion)
    }
    
    @objc private func didLaunch() {
        AppsFlyerTracker.shared().trackAppLaunch()
    }
}


extension AppsFlyerConnector: AppsFlyerTrackerDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        Appodeal.setSegmentFilter(conversionInfo)
    }
    
    func onConversionDataFail(_ error: Error) {}
}
