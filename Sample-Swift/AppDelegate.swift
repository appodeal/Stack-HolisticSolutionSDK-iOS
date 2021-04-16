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
        static let adType: AppodealAdType = .banner
        static let consent: Bool = true
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        configureHolisticApp(application, launchOptions: launchOptions)
        return true
    }
    
    private func configureHolisticApp(
        _ app: UIApplication,
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        // Configure Appodeal before initialisation
        Appodeal.setLogLevel(.verbose)
        Appodeal.setTestingEnabled(true)
        
        // Facebook
        ApplicationDelegate.shared.application(app, didFinishLaunchingWithOptions: launchOptions)
        
        // Create service connectors
        let appsFlyer = try! HSAppsFlyerConnector(plist: .custom(path: "Services-Info"))
        let firebase = HSFirebaseConnector(keys: [], defaults: nil, expirationDuration: 60)
        let facebook = HSFacebookConnector()
        // Create advertising connector
        let appodeal = HSAppodealConnector()
        // Create HSApp configuration
        let services: [HSService] = [appsFlyer, firebase, facebook]
        let configuration = HSAppConfiguration(services: services,
                                               advertising: appodeal, 
                                               timeout: 30)
        // Configure
        HSApp.configure(configuration: configuration) { error in
            // Handle error
            error.map { print($0.localizedDescription) }
            print("HSApp \(HSApp.initialised ? "is" : "is not") initialised")
            // Initialise Appodeal
            Appodeal.initialize(
                withApiKey: servicesInfo.appodeal.apiKey,
                types: AppodealConstants.adType,
                hasConsent: AppodealConstants.consent
            )
            NotificationCenter.default.post(name: .AdDidInitialize, object: nil)
        }
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
    
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}


extension Notification.Name {
    static let AdDidInitialize = Notification.Name("AdDidInitialize")
}
