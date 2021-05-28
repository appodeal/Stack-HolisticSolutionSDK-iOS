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


@objc(HSFirebaseConnector) public
final class FirebaseConnector: NSObject, Service {
    struct Parameters {
        static let id: String = "firebase"
        
        var configKeys: [String]
        var expirationDuration: TimeInterval
        var tracking: Bool
    }

    
    public var name: String { Parameters.id }
    public var sdkVersion: String { FirebaseVersion() }
    public var version: String { sdkVersion + ".1" }
//    public typealias Completion = (([AnyHashable : Any]?) -> Void)
//    public typealias Success = () -> Void
//    public typealias Failure = (HSError) -> Void
    
//    public var onReceiveConfig: (([AnyHashable : Any]) -> Void)?
    
//    let parameters: FirebaseParameters
    
//    private lazy var config: RemoteConfig = {
//        // Setup settings
//        let settings = RemoteConfigSettings()
//        settings.minimumFetchInterval = 0
//        // Config
//        let config = RemoteConfig.remoteConfig()
//        config.configSettings = settings
//        return config
//    }()
    
//    @objc public convenience
//    init(
//        keys: [String] = [],
//        expirationDuration: TimeInterval = 60,
//        tracking: Bool = true
//    ) {
//        let parameters: FirebaseParameters = .init(
//            configKeys: keys,
//            expirationDuration: expirationDuration,
//            tracking: tracking
//        )
//        self.init(parameters: parameters)
//    }
//
//    init(parameters: FirebaseParameters) {
//        self.parameters = parameters
//        super.init()
//    }
}

extension FirebaseConnector {//: ProductTestingService {
//    public func initialise(success: @escaping Success,
//                           failure: @escaping Failure) {
//        // Check if need to configure FIRApp
//        guard FirebaseApp.allApps == nil else {
//            success()
//            return
//        }
//
//        DispatchQueue.main.async {
//            FirebaseApp.configure()
//            success()
//        }
//    }
//
//    func activateConfig(completion: @escaping (([AnyHashable : Any]?) -> Void)) {
//        config.fetch(withExpirationDuration: parameters.expirationDuration) { [weak self] status, error in
//            guard let self = self else { return }
//            // Fallback on fetch failed
//            guard status == .success, error == nil else {
//                completion(nil)
//                return
//            }
//            self.activate(completion)
//        }
//    }
//
//    public func setDebug(_ debug: AppConfiguration.Debug) {
//        // TODO: Implement me
//    }
//
//    private func activate(_ completion: @escaping Completion) {
//        // Activate config
//        config.activate { [weak self] _, _ in
//            guard let self = self else { return }
//            // Transform config to Appodeal extras
//            let config = self.getConfig()
//            DispatchQueue.main.async { completion(config) }
//        }
//    }
//
//    private func getConfig() -> [AnyHashable: Any] {
//        let keys = parameters.configKeys.count > 0 ? parameters.configKeys : config.allKeys(from: .remote)
//        return keys.reduce([:]) { result, key in
//            var result = result
//            if let value = config.configValue(forKey: key).stringValue {
//                result[key] = value
//            }
//            return result
//        }
//    }
}

extension FirebaseConnector {//: AnalyticsService {
    func trackEvent(_ event: String, customParameters: [String : Any]?) {
//        guard parameters.tracking else { return }
//        Analytics.logEvent(event, parameters: customParameters)
    }
    
    //MARK: - Noop
    func trackInAppPurchase(_ purchase: Purchase) {}
}
