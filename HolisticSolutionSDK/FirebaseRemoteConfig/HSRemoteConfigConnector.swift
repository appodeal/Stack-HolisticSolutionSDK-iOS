//
//  HSRemoteConfigConnector.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 26.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseRemoteConfig


@objc public
final class HSRemoteConfigConnector: NSObject { //, HSAttributionPlatform {
    public var onReceiveConfig: (([AnyHashable : Any]) -> Void)?
    private let defaults: [String: NSObject]?
    private let keys: [String]
    private let expirationDuration: TimeInterval
    
    private lazy var config: RemoteConfig = {
        // Setup settings
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        // Config
        let config = RemoteConfig.remoteConfig()
        config.configSettings = settings
        defaults.map(config.setDefaults)
        return config
    }()
    
    @objc public
    init(keys: [String] = [],
         defaults: [String: NSObject]? = nil,
         expirationDuration: TimeInterval = 60) {
        self.keys = keys
        self.defaults = defaults
        self.expirationDuration = expirationDuration
        super.init()
    }
}

extension HSRemoteConfigConnector: HSProductTestingPlatform {
    public func initialise(completion: @escaping (HSProductTestingPlatform) -> Void) {
        // Check if need to configure FIRApp
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        config.fetch(withExpirationDuration: expirationDuration) { [unowned self] status, error in
            // Fallback on fetch failed
            guard status == .success, error == nil else {
                completion(self)
                return
            }
            self.activate(completion: completion)
        }
    }
    
    private func activate(completion: @escaping (HSProductTestingPlatform) -> Void) {
        // Activate config
        config.activate { [unowned self] error in
            // Transform config to Appodeal extras
            let config = self.getConfig()
            self.onReceiveConfig?(config)
            completion(self)
        }
    }
    
    private func getConfig() -> [AnyHashable: Any] {
        let keys = self.keys.count > 0 ? self.keys : config.allKeys(from: .remote)
        return keys.reduce([:]) { result, key in
            var result = result
            if let value = config.configValue(forKey: key).stringValue {
                result[key] = value
            }
            return result
        }
    }
}
