//
//  AppDelegate.swift
//  Sample
//
//  Created by Stas Kochkin on 04.05.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import UIKit
import Appodeal


protocol Connector {
    typealias Completion = () -> Void
    func initialise(completion: @escaping Completion)
}


extension Notification.Name {
    static let AdDidInitialize = Notification.Name("AdDidInitialize")
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private struct AppodealConstants {
        static let adType: AppodealAdType = .banner
        static let consent: Bool = true
    }
    
    /// Services connectors
    private let connectors: [Connector] = [
        RemoteConfigConnector(),
        AppsFlyerConnector()
    ]
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Appodeal.setLogLevel(.verbose)
        // Activate Firebase and AppsFlyer first.
        // Appodeal should be initialised after
        connect {
            Appodeal.setTestingEnabled(true)
            Appodeal.initialize(
                withApiKey: servicesInfo.appodeal.apiKey,
                types: AppodealConstants.adType,
                hasConsent: AppodealConstants.consent
            )
            // Notify application that advertising is available
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


private extension AppDelegate {
    func connect(completion: @escaping Connector.Completion) {
        // Wait for all connectors activation completion.
        let group = DispatchGroup()
        connectors.forEach { connector in
            group.enter()
            connector.initialise(completion: group.leave)
        }
        group.notify(queue: .main, execute: completion) 
    }
}


