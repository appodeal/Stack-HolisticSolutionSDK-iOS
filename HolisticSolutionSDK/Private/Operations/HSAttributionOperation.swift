//
//  HSAttributionConfigurationOperation.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 26.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


final class HSAttributionOperation: HSCancellableAsynchronousOperation, HSAppOperation {
    private let attribution: [HSAttributionService]
    private let advertising: [HSAdvertising]
    private let debug: HSAppConfiguration.Debug
    
    private lazy var group = DispatchGroup()
    
    init(_ configuration: HSAppConfiguration) {
        attribution = configuration.attribution
        advertising = configuration.connectors
        debug = configuration.debug
        super.init(timeout: configuration.timeout)
    }
    
    override func main() {
        super.main()
        debug.log("Start collecting of attribution data")
        attribution.forEach { service in            
            group.enter()
            service.collect(receiveAttributionId: syncAttributionId) { [weak self] conversionData in
                guard let self = self else { return }
                conversionData.map(self.syncConversionData)
                self.group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.debug.log("Finish collecting of attribution data")
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
