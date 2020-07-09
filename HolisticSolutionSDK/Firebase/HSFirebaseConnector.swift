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
import FirebaseAnalytics


@objc public
final class HSFirebaseConnector: NSObject {
    public typealias Completion = (([AnyHashable : Any]?) -> Void)
    public typealias Success = () -> Void
    public typealias Failure = (HSError) -> Void
    
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

extension HSFirebaseConnector: HSProductTestingService {
    public func initialise(success: @escaping Success,
                           failure: @escaping Failure) {
        // Check if need to configure FIRApp
        if FirebaseApp.allApps == nil {
            FirebaseApp.configure()
        }
        success()
    }
    
    func activateConfig(completion: @escaping (([AnyHashable : Any]?) -> Void)) {
        config.fetch(withExpirationDuration: expirationDuration) { [weak self] status, error in
            guard let self = self else { return }
            // Fallback on fetch failed
            guard status == .success, error == nil else {
                completion(nil)
                return
            }
            self.activate(completion)
        }
    }
    
    public func setDebug(_ debug: HSAppConfiguration.Debug) {
        // TODO: Implement me
    }
    
    private func activate(_ completion: @escaping Completion) {
        // Activate config
        config.activate { [weak self] _ ,error in
            guard let self = self else { return }
            // Transform config to Appodeal extras
            let config = self.getConfig()
            completion(config)
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

extension HSFirebaseConnector: HSAnalyticsService {
    func trackEvent(_ event: String, customParameters: [String : Any]?) {
        Analytics.logEvent(event, parameters: customParameters)
    }
}
