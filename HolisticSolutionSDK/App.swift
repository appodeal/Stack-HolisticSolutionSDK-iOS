//
//  HSApp.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 25.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation
import UIKit
import Appodeal

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
    
    private func initializeServices(
        app: UIApplication,
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        let initialize = BlockOperation { [unowned self, unowned app] in
            self.registry.types.forEach {
                let service = $0.init()
                service.set?(app, launchOptions: launchOptions)
                self.registry.store($0.init())
            }
        }
        
        let trackId = BlockOperation { [unowned self] in
            self.registry.ad.setTrackId(self.configuration.id)
        }
        
        let debug = BlockOperation { [unowned self] in
            (self.registry.all() as [Service]).forEach { $0.set?(debug: self.configuration.debug) }
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
        
        let removeUnused = BlockOperation { [unowned request, unowned self] in
            let keys: [String] = request.response.flatMap { Array($0.keys) } ?? []
            self.registry.filter { $0 is AppodealConnector || keys.contains($0.name) }
        }
        
        removeUnused.addDependency(request)
        requestAdapter.addDependency(initialize)
        trackId.addDependency(initialize)
        debug.addDependency(initialize)
        request.addDependency(requestAdapter)
        connectors.addDependency(connectorsAdapter)
        connectorsAdapter.addDependency(request)
        
        queue.addOperations(
            [
                initialize,
                trackId,
                debug,
                requestAdapter,
                request,
                removeUnused,
                connectorsAdapter,
                connectors
            ],
            waitUntilFinished: false
        )
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
    
    private func activateRemoteConfiguration() {
        let testing = ProductTestSyncOperation(timeout: configuration.timeout)
        let adapter = BlockOperation { [unowned testing, unowned self] in
            testing.advertising = self.registry.ad
            testing.productTesting = self.registry.all()
        }
        
        testing.addDependency(adapter)
        queue.addOperations([adapter, testing], waitUntilFinished: false)
    }
    
    private func initializeAdvertising() {
        let advertising = InitializeServiceOperation<AppodealConnector>(
            parameters: self.configuration
        )
        
        let adapter = BlockOperation { [unowned self, unowned advertising] in
            advertising.connector = self.registry.types(of: AppodealConnector.self).first?.init()
        }
                
        advertising.addDependency(adapter)
    
        queue.addOperations([adapter, advertising], waitUntilFinished: false)
    }
}


internal extension App {
    static func log(_ message: String) {
        shared.configuration?.debug.log(message)
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
        initializeServices(app: application, launchOptions: launchOptions)
        collectAttributionData()
        activateRemoteConfiguration()
        initializeAdvertising()
    }
    
    @objc public
    func initialize(
        application: UIApplication,
        launchOptions: [UIApplication.LaunchOptionsKey : Any]?,
        appKey: String,
        adTypes: AppodealAdType
    ) {
        let configuration = AppConfiguration(appKey: appKey, adTypes: adTypes)
        initialize(
            application: application,
            launchOptions: launchOptions,
            configuration: configuration
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
        let purchase = Purchase(
            productId: productId,
            price: price,
            currency: currency,
            transactionId: transactionId,
            type: type,
            additionalParameters: additionalParameters
        )
        
        let operation = ValidateAndTrackPurchaseOperation(
            purchase: purchase,
            success: success,
            failure: failure
        )
        
        let adapter = BlockOperation { [unowned self, unowned operation] in
            operation.analytics = self.registry.all()
            operation.attribution = self.registry.all()
        }
        
        operation.addDependency(adapter)
        queue.addOperations([adapter, operation], waitUntilFinished: false)
    }
    
    @objc public
    func trackEvent(
        _ eventName: String,
        customParameters: [String : Any]?
    ) {
        let trackEvent = TrackEventOperation(event: eventName, params: customParameters)
        let adapter = BlockOperation { [unowned self, unowned trackEvent] in
            trackEvent.analytics = self.registry.all()
        }
        
        trackEvent.addDependency(adapter)
        
        queue.addOperations([adapter, trackEvent], waitUntilFinished: false)
    }
}
