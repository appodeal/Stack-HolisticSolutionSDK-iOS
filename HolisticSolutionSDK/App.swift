//
//  HSApp.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 25.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation
import UIKit



/// Base class that provides initialisation
/// and synchronisation of whole components that used
/// for Holistic Solution
@objc(HSApp) final public
class App: NSObject {
    @objc static let sdkVersion: String = "2.0.0"
    @objc static let shared = App()
    
    private var configuration: AppConfiguration!
    private var registry: ConnnectorsRegistry = .init()
    
    fileprivate lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.explorestack.hsapp.control-queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .default
        return queue
    }()

    private func synchronizeConsent() {
        let parameters = ConsentManagerConnector.Parameters(
            appKey: configuration.appKey,
            trackId: configuration.id
        )
        
        let privacy = InitializeServiceOperation<ConsentManagerConnector>(
            parameters: parameters
        )
        
        let adapter = BlockOperation { [unowned self, unowned privacy] in
            privacy.connector = self.registry.types(of: ConsentManagerConnector.self).first?.init()
        }
                
        privacy.addDependency(adapter)
    
        queue.addOperations([adapter, privacy], waitUntilFinished: false)
    }
    
    private func initializeServices() {
        let initialize = BlockOperation { [unowned self] in
            self.registry.types.forEach { self.registry.store($0.init()) }
        }
        
        let request = FetchServicesParametersOperation(
            appKey: configuration.appKey,
            trackId: configuration.id
        )
        
        let requestAdapter = BlockOperation { [unowned self, unowned request] in
            request.services = self.registry.all()
        }

        let connectors = InitializeServicesOperation()
        let connectorsAdapter = BlockOperation { [unowned connectors, unowned request] in
            connectors.parameters = request.response
            connectors.connector = { [unowned self] name in
                return self.registry.initalizable(name)
            }
        }
        
        requestAdapter.addDependency(initialize)
        request.addDependency(requestAdapter)
        connectors.addDependency(connectorsAdapter)
        connectorsAdapter.addDependency(request)
        
        queue.addOperations([initialize, requestAdapter, request, connectorsAdapter, connectors], waitUntilFinished: false)
    }
    
    private func collectAttributionData() {
        let attribution = AttributionOperation(timeout: configuration.timeout)
        let adapter = BlockOperation { [unowned attribution, unowned self] in
            attribution.advertising = self.registry.ad
            attribution.connectors = self.registry.all()
        }
        attribution.addDependency(adapter)
        
        queue.addOperations([adapter, attribution], waitUntilFinished: false)
    }
}


internal extension App {
    static func log(_ message: String) {
        shared.configuration?.debug.log(message)
    }
}


private extension App {
    func validateAndTrackInAppPurchase(
        purchase: Purchase,
        success:(([AnyHashable: Any]) -> Void)?,
        failure:((Error?, Any?) -> Void)?
    ) {
        guard let configuration = configuration else {
            failure?(HSError.integration, nil)
            return
        }
        let operation = ValidateAndTrackPurchaseOperation(
            configuration: configuration,
            purchase: purchase,
            success: success,
            failure: failure
        )
        queue.addOperation(operation)
    }
}

extension App: DSL {
    @objc public
    func register(connectors: [Service.Type]) {
        registry.register(connectors: connectors)
    }
    
    @objc public
    func initialize(
        application: UIApplication,
        launchOptions: [UIApplication.LaunchOptionsKey : Any]?,
        configuration: AppConfiguration
    ) {
        self.configuration = configuration
        synchronizeConsent()
        initializeServices()
        collectAttributionData()
    }
    
    @objc public
    func initialize(
        application: UIApplication,
        launchOptions: [UIApplication.LaunchOptionsKey : Any]?,
        appKey: String
    ) {
        initialize(
            application: application,
            launchOptions: launchOptions,
            configuration: .init(appKey: appKey)
        )
    }
    
    @objc public
    func validateAndTrackInAppPurchase(
        productId: String,
        type: PurchaseType,
        price: String,
        currency: String,
        transactionId: String,
        additionalParameters: [String: Any],
        success:(([AnyHashable: Any]) -> Void)?,
        failure:((Error?, Any?) -> Void)?
    ) {
        
    }
    
    @objc public
    func trackEvent(
        _ eventName: String,
        customParameters: [String : Any]?
    ) {
        
    }
}
