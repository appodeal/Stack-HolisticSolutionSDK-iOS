//
//  HSApp.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 25.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


public
enum HSError: Int, Error {
    case invalidParameters = 0
    case timeout
    case service
    case notInternetConnection
    
    var nserror: NSError {
        return NSError.from(self)
    }
}

/// Base class that provides initialisation
/// and synchronisation of whole components that used
/// for Holistic Solution
@objc final public class HSApp: NSObject {
    private static let shared = HSApp()
    
    fileprivate lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.explorestack.hsapp"
        queue.maxConcurrentOperationCount = 2
        queue.qualityOfService = .utility
        return queue
    }()
    
    @objc public
    static func configure(configuration: HSAppConfiguration,
                          completion: ((NSError?) -> Void)?) {
        HSApp.shared.configure(configuration: configuration,
                               completion: completion)
    }
}

private extension HSApp {
    func configure(configuration: HSAppConfiguration,
                   completion: ((NSError?) -> Void)?) {
        let attributionOperation = HSAttributionConfigurationOperation(configuration)
        let productTestingOperation = HSProductTestSyncOperation(configuration)
        let completionOperation = HSCompletionOperation(completion)
    
        completionOperation.addDependency(attributionOperation)
        completionOperation.addDependency(productTestingOperation)
        
        operationQueue.addOperation(attributionOperation)
        operationQueue.addOperation(productTestingOperation)
        operationQueue.addOperation(completionOperation)
    }
}

fileprivate extension NSError {
    static func from(_ error: HSError) -> NSError {
        let domain = "com.explorestack.hs"
        let userInfo: [String: Any]
        switch error {
        case .invalidParameters: userInfo = [NSLocalizedDescriptionKey: "Some of input paramerers was invalid"]
        case .notInternetConnection: userInfo = [ NSLocalizedDescriptionKey: "Application is in offline" ]
        case .service: userInfo = [ NSLocalizedDescriptionKey: "Error has been occurred while starting service" ]
        case .timeout: userInfo = [ NSLocalizedDescriptionKey: "HSApp timeout has been reached" ]
        }
        return NSError(domain: domain, code: error.rawValue, userInfo: userInfo)
    }
}

