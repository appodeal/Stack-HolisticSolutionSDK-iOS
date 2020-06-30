//
//  HSAttributionConfigurationOperation.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 26.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


final class HSAttributionConfigurationOperation: HSCancellableAsynchronousOperation, HSAppOperation {
    private let attribution: [HSAttributionService]
    private let advertising: [HSAdvertising]
    private let debug: HSAppConfiguration.Debug
    
    private lazy var group = DispatchGroup()
    
    init(_ configuration: HSAppConfiguration) {
        attribution = configuration.attribution
        advertising = configuration.advertising
        debug = configuration.debug
        super.init(timeout: configuration.timeout)
    }
    
    override func main() {
        super.main()
        attribution.forEach { service in
            service.setDebug(debug)
            service.onReceiveData = { [weak self] in self?.syncConversionData($0) }
            service.onReceiveAttributionId = { [weak self] in self?.syncAttributionId($0) }
            
            group.enter()
            service.initialise(
                success: { [weak self] in self?.group.leave() },
                failure: { [weak self] error in self?.group.leave() }
            )
        }
        group.notify(queue: .main) { [weak self] in
            self?.finish()
        }
    }
    
    private func syncAttributionId(_ id: String) {
        advertising.forEach { $0.setAttributionId(id) }
    }
    
    private func syncConversionData(_ data: [AnyHashable: Any]) {
        advertising.forEach { ad in
            ad.setConversionData(data)
        }
    }
}
