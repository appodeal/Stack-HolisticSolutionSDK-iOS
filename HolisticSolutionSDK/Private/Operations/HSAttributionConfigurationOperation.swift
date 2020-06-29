//
//  HSAttributionConfigurationOperation.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 26.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


final class HSAttributionConfigurationOperation: HSCancellableAsynchronousOperation {
    private let attribution: [HSAttributionPlatform]
    private let advertising: [HSAdvertisingPlatform]
    
    private lazy var group = DispatchGroup()
    
    init(attribution: [HSAttributionPlatform],
         advertising: [HSAdvertisingPlatform],
         timeout: TimeInterval) {
        self.attribution = attribution
        self.advertising = advertising
        super.init(timeout: timeout)
    }
    
    override func main() {
        super.main()
        attribution.forEach { platform in
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
