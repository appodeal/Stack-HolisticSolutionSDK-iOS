//
//  AppDelegate.swift
//  Sample
//
//  Created by Stas Kochkin on 04.05.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import UIKit
import Appodeal
import HolisticSolutionSDK
import FBSDKCoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let complete: Notification.Name = .init("HSAppCompleteNotification")
    
    struct AppodealConstants {
        static let appKey = "dee74c5129f53fc629a44a690a02296694e3eef99f2d3a5f"
        static let adType: AppodealAdType = .banner
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        Appodeal.swizzle()
        
        let connectors: [Service.Type] = [
            AppsFlyerConnector.self,
            AdjustConnector.self,
            FirebaseConnector.self,
            FacebookConnector.self
        ]
        
        Appodeal.setTestingEnabled(true)
        Appodeal.hs.register(connectors: connectors)
        Appodeal.hs.initialize(
            application: application,
            launchOptions: launchOptions,
            configuration: .init(
                appKey: AppodealConstants.appKey,
                timeout: 10,
                debug: .enabled,
                adTypes: AppodealConstants.adType
            )
        )
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
    
    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}
}


private extension Appodeal {
    static func swizzle() {
        guard
            let method1 = class_getClassMethod(Appodeal.self, #selector(initialize(withApiKey:types:consentReport:))),
            let swizzled1 = class_getClassMethod(Appodeal.self, #selector(_initialize(withApiKey:types:consentReport:))),
            let method2 = class_getClassMethod(Appodeal.self, #selector(initialize(withApiKey:types:))),
            let swizzled2 = class_getClassMethod(Appodeal.self, #selector(_initialize(withApiKey:types:)))
        else { return }
        
        method_exchangeImplementations(method1, swizzled1)
        method_exchangeImplementations(method2, swizzled2)
    }
    
    @objc class
    func _initialize(withApiKey: String, types: AppodealAdType, consentReport: STKConsent) {
        _initialize(withApiKey: withApiKey, types: types, consentReport: consentReport)
        NotificationCenter.default.post(name: AppDelegate.complete, object: nil)
    }
    
    @objc class
    func _initialize(withApiKey: String, types: AppodealAdType) {
        _initialize(withApiKey: withApiKey, types: types)
        NotificationCenter.default.post(name: AppDelegate.complete, object: nil)
    }
}
