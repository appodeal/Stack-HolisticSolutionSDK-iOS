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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private struct AppodealConstants {
        static let adType: AppodealAdType = .banner
        static let consent: Bool = true
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Appodeal.setLogLevel(.verbose)
        let appsFlyer = try! HSAppsFlyerConnector(plist: .custom(path: "Services-Info"))
        let remoteConfig = HSRemoteConfigConnector()
        let configuration = HSAppConfiguration(attribution: appsFlyer,
                                               productTesting: remoteConfig)
        try? HSApp.configure(configuration: configuration) {
            Appodeal.setTestingEnabled(true)
            Appodeal.initialize(
                withApiKey: servicesInfo.appodeal.apiKey,
                types: AppodealConstants.adType,
                hasConsent: AppodealConstants.consent
            )
            NotificationCenter.default.post(name: .AdDidInitialize, object: nil)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}


extension Notification.Name {
    static let AdDidInitialize = Notification.Name("AdDidInitialize")
}
