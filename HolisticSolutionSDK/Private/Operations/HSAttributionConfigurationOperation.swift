//
//  HSAttributionConfigurationOperation.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 26.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


final class HSAttributionConfigurationOperation: HSAsynchronousOperation {
    private let attribution: [HSAttributionPlatform]
    private let advertising: [HSAdvertisingPlatform]
    
    init(attribution: [HSAttributionPlatform],
         advertising: [HSAdvertisingPlatform]) {
        self.attribution = attribution
        self.advertising = advertising
        super.init()
    }
    
    override func main() {
        super.main()
        let group = DispatchGroup()
        attribution.forEach { platform in
            platform.onReceiveData = { [unowned self] in self.syncConversionData($0) }
            group.enter()
            platform.initialise { [unowned self] finishedPlatform in
                self.syncAttributionId(finishedPlatform)
                group.leave()
            }
        }
        group.notify(queue: .main) { [unowned self] in
            self.finish()
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
