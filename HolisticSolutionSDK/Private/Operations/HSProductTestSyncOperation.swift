//
//  HSProductTestSyncOperation.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 26.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


final class HSProductTestSyncOperation: HSAsynchronousOperation {
    private let productTesting: [HSProductTestingPlatform]
    private let advertising: [HSAdvertisingPlatform]
    
    init(productTesting: [HSProductTestingPlatform],
         advertising: [HSAdvertisingPlatform]) {
        self.productTesting = productTesting
        self.advertising = advertising
        super.init()
    }
    
    override func main() {
        super.main()
        let group = DispatchGroup()
        productTesting.forEach { platform in
            platform.onReceiveConfig = { [unowned self] in self.syncProductTestingData($0) }
            group.enter()
            platform.initialise { _ in group.leave() }
        }
        group.notify(queue: .main) { [unowned self] in
            self.finish()
        }
    }
    
    private func syncProductTestingData(_ data: [AnyHashable: Any]) {
        advertising.forEach { ad in ad.setProductTestData(data) }
    }
}
