//
//  HSApp.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 25.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


@objc public
enum HSError: Int, Error {
    case integration = 0
    case timeout
    case service
    
    var nserror: NSError {
        return NSError.from(self)
    }
}

/// Base class that provides initialisation
/// and synchronisation of whole components that used
/// for Holistic Solution
@objc final public class HSApp: NSObject {
    private static let shared = HSApp()
    private var configuration: HSAppConfiguration?
    private var initialised: Bool = false
    
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
    
    @objc public
    static var initialised: Bool { HSApp.shared.initialised }
    
    @objc public
    static func validateAndTrackInAppPurchase(
        productId: String,
        price: String,
        currency: String,
        transactionId: String,
        additionalParameters: [AnyHashable: Any],
        success:(([AnyHashable: Any]) -> Void)?,
        failure:((Error?, Any?) -> Void)?
    ) {
        let purchase = HSPurchase(
            productId: productId,
            price: price,
            currency: currency,
            transactionId: transactionId,
            additionalParameters: additionalParameters
        )
        HSApp.shared.validateAndTrackInAppPurchase(
            purchase: purchase,
            success: success,
            failure: failure
        )
    }
    
    @objc public
    static func trackEvent(_ eventName: String,
                           customParameters: [String: Any]? = nil) {
        HSApp.shared.trackEvent(eventName,
                                customParameters: customParameters)
    }
}

private extension HSApp {
    func configure(configuration: HSAppConfiguration,
                   completion: ((NSError?) -> Void)?) {
        self.configuration = configuration
        
        let attributionOperation = HSAttributionConfigurationOperation(configuration)
        let productTestingOperation = HSProductTestSyncOperation(configuration)
        let completionOperation = HSCompletionOperation(completion)
        
        let blockOperation = BlockOperation { [weak self] in self?.initialised = true }
        
        completionOperation.addDependency(attributionOperation)
        completionOperation.addDependency(productTestingOperation)
        blockOperation.addDependency(attributionOperation)
        blockOperation.addDependency(productTestingOperation)
        
        operationQueue.addOperation(attributionOperation)
        operationQueue.addOperation(productTestingOperation)
        operationQueue.addOperation(blockOperation)
        operationQueue.addOperation(completionOperation)
    }
    
    func validateAndTrackInAppPurchase(
        purchase: HSPurchase,
        success:(([AnyHashable: Any]) -> Void)?,
        failure:((Error?, Any?) -> Void)?
    ) {
        guard let configuration = configuration else {
            failure?(HSError.integration, nil)
            return
        }
        let operation = HSValidateAndTrackPurchaseOperation(
            configuration: configuration,
            purchase: purchase,
            success: success,
            failure: failure
        )
        operationQueue.addOperation(operation)
    }
    
    func trackEvent(_ eventName: String,
                    customParameters: [String: Any]?) {
        guard let configuration = configuration else { return }
        let operation = HSTrackEventOperation(configuration: configuration,
                                              event: eventName,
                                              params: customParameters)
        operationQueue.addOperation(operation)
    }
}

fileprivate extension NSError {
    static func from(_ error: HSError) -> NSError {
        let domain = "com.explorestack.hs"
        let userInfo: [String: Any]
        switch error {
        case .integration: userInfo = [ NSLocalizedDescriptionKey: "Some of input paramerers was invalid" ]
        case .service: userInfo = [ NSLocalizedDescriptionKey: "Error has been occurred while starting service" ]
        case .timeout: userInfo = [ NSLocalizedDescriptionKey: "HSApp timeout has been reached" ]
        }
        return NSError(domain: domain,
                       code: error.rawValue,
                       userInfo: userInfo)
    }
}

