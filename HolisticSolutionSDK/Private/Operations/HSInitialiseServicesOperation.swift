//
//  HSInitialiseServicesOperation.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 09.07.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation

final class HSInitialiseServicesOperation: HSCancellableAsynchronousOperation, HSAppOperation {
    private let services: [HSService]
    private let debug: HSAppConfiguration.Debug

    private lazy var group = DispatchGroup()
    
    init(_ configuration: HSAppConfiguration) {
        services = configuration.services
        debug = configuration.debug
        super.init(timeout: configuration.timeout)
    }
    
    override func main() {
        super.main()
        debug.log("Start initialising of services")
        services.forEach { service in
            service.setDebug(debug)
            
            group.enter()
            service.initialise(
                success: { [weak self] in self?.group.leave() },
                failure: { [weak self] _ in self?.group.leave() }
            )
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.debug.log("Finish initialising of services")
            self?.finish()
        }
    }
}
