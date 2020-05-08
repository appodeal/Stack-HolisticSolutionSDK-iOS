//
//  RemoteConfigConnector.swift
//  Sample
//
//  Created by Stas Kochkin on 04.05.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation
import Firebase
import Appodeal


final class RemoteConfigConnector: Connector {
    private let expirationDuration: TimeInterval = 60
    
    enum Keys: String, CaseIterable {
        case firstFeatureEnabled = "first_feature_enabled"
        case secondFeatureEnabled = "second_feature_enabled"
    }
    
    private lazy var config: RemoteConfig = {
        // Setup settings
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        // Config
        let config = RemoteConfig.remoteConfig()
        config.configSettings = settings
        config.setDefaults([
            Keys.firstFeatureEnabled.rawValue: "true" as NSString,
            Keys.secondFeatureEnabled.rawValue: "true" as NSString
        ])
        return config
    }()
    
    
    func initialise(completion: @escaping Completion) {
        // Configure app
        FirebaseApp.configure()
        // Get token for testing
        /*
         InstanceID.instanceID().instanceID { result, error in
         result.map { $0.token }.map { print("Device token is \($0)") }
         }
         */
        // Fetch Remote Config
        config.fetch(withExpirationDuration: expirationDuration) { [weak self] status, error in
            // Fallback on fetch failed
            guard let self = self, status == .success, error == nil else {
                print("Remote config fetch error")
                completion()
                return
            }
            self.activate(completion: completion)
        }
    }
    
    private func activate(completion: @escaping Completion) {
        // Activate config
        self.config.activate { [weak self] error in
            guard let self = self else {
                completion()
                return
            }
            print("Remote config is activated with error: \(error.debugDescription)")
            // Transform config to Appodeal extras
            let keywords = self.remoteConfigKeywords()
            let extras: [String: String] = [
                "keywords": keywords
            ]
            // Set extras
            DispatchQueue.main.async {
                Appodeal.setExtras(extras)
                completion()
            }
        }
    }
    
    private func remoteConfigKeywords() -> String {
        let values = Keys.allCases
            .map { $0.rawValue }
            .compactMap { config.configValue(forKey: $0).stringValue }
        return values.joined(separator: ",")
    }
}



