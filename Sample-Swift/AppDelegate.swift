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
    private struct AppodealConstants {
        static let appKey = "dee74c5129f53fc629a44a690a02296694e3eef99f2d3a5f"
        static let adType: AppodealAdType = .banner
        static let consent: Bool = true
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Appodeal.hs.register(connectors: [
                                AppsFlyerConnector.self,
                                AdjustConnector.self,
                                FirebaseConnector.self,
                                FacebookConnector.self
        ])
        
        Appodeal.hs.initialize(
            application: application,
            launchOptions: launchOptions,
            appKey: AppodealConstants.appKey
        )
        
        return true
    }
    
//    private func configureHolisticApp(
//        _ app: UIApplication,
//        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//    ) {
//        // Configure Appodeal before initialisation
//        Appodeal.setLogLevel(.verbose)
//        Appodeal.setTestingEnabled(true)
//
//        // Facebook
//        ApplicationDelegate.shared.application(app, didFinishLaunchingWithOptions: launchOptions)
//
//        // Create service connectors
//        let appsFlyer = try! AppsFlyerConnector(plist: .custom(path: "Services-Info"))
//        let firebase = FirebaseConnector(keys: [], defaults: nil, expirationDuration: 60)
//        let facebook = FacebookConnector()
//        // Create advertising connector
//        let appodeal = AppodealConnector()
//        // Create HSApp configuration
//        let services: [Service] = [appsFlyer, firebase, facebook]
//        let configuration = AppConfiguration(
//            services: services,
//            advertising: appodeal,
//            timeout: 30
//        )
//        // Configure
//        App.configure(configuration: configuration) { error in
//            // Handle error
//            error.map { print($0.localizedDescription) }
//            print("HSApp \(App.initialised ? "is" : "is not") initialised")
//            // Initialise Appodeal
//            Appodeal.initialize(
//                withApiKey: servicesInfo.appodeal.apiKey,
//                types: AppodealConstants.adType,
//                hasConsent: AppodealConstants.consent
//            )
//            NotificationCenter.default.post(name: .AdDidInitialize, object: nil)
//        }
//    }
    
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
    
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}


extension Notification.Name {
    static let AdDidInitialize = Notification.Name("AdDidInitialize")
}
