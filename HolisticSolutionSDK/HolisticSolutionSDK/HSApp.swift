//
//  HSApp.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 25.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


/// Base class that provides initialisation
/// and synchronisation of whole components that used
/// for Holistic Solution
@objc final public class HSApp: NSObject {
    private typealias Completion = () -> Void
    
    private static let shared = HSApp()
    
    fileprivate lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.explorestack.hsapp"
        queue.qualityOfService = .utility
        return queue
    }()
    
    @objc public
    static func configure(configuration: HSAppConfiguration,
                          completion: (() -> Void)?) throws {
        HSApp.shared.configure(configuration: configuration,
                               completion: completion)
    }
}

private extension HSApp {
    func configure(configuration: HSAppConfiguration,
                   completion: (() -> Void)?) {
        let attributionOperation = HSAttributionConfigurationOperation(
            attribution: configuration.attribution,
            advertising: configuration.advertising
        )
        
        let productTestingOperation = HSProductTestSyncOperation(
            productTesting: configuration.productTesting,
            advertising: configuration.advertising
        )
        
        let completionOperation = BlockOperation {
            DispatchQueue.main.async { completion?() }
        }
        
        completionOperation.addDependency(attributionOperation)
        completionOperation.addDependency(productTestingOperation)
        
        operationQueue.addOperation(attributionOperation)
        operationQueue.addOperation(productTestingOperation)
        operationQueue.addOperation(completionOperation)
    }
}

