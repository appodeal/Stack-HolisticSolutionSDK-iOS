//
//  HSAttributionConfigurationOperation.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 26.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


final class HSAttributionConfigurationOperation: HSCancellableAsynchronousOperation, HSAppOperation {
    private let attribution: [HSAttributionPlatform]
    private let advertising: [HSAdvertisingPlatform]
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
        attribution.forEach { platform in
            platform.setDebug(debug)
            platform.onReceiveData = { [weak self] in self?.syncConversionData($0) }
            group.enter()
            platform.initialise { [weak self] finishedPlatform in
                self?.syncAttributionId(finishedPlatform)
                self?.group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.finish()
        }
    }
    
    private func syncAttributionId(_ attribution: HSAttributionPlatform) {
        advertising.forEach { ad in
            attribution.id.map(ad.setAttributionId)
        }
    }
    
    private func syncConversionData(_ data: [AnyHashable: Any]) {
        advertising.forEach { ad in
            ad.setConversionData(data)
        }
    }
}
