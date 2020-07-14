//
//  HSProductTestSyncOperation.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 26.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


final class HSProductTestSyncOperation: HSCancellableAsynchronousOperation, HSAppOperation {
    private let productTesting: [HSProductTestingService]
    private let advertising: [HSAdvertising]
    private let debug: HSAppConfiguration.Debug

    private lazy var group = DispatchGroup()

    init(_ configuration: HSAppConfiguration) {
        productTesting = configuration.productTesting
        advertising = configuration.connectors
        debug = configuration.debug
        super.init(timeout: configuration.timeout)
    }
    
    override func main() {
        super.main()
        debug.log("Start activating of remote configs")
        productTesting.forEach { service in
            service.activateConfig { [weak self] config in
                guard let self = self else { return }
                config.map(self.syncProductTestingData)
                self.group.enter()
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.debug.log("[HSApp] Finish activating of remote configs")
            self?.finish()
        }
    }
    
    private func syncProductTestingData(_ data: [AnyHashable: Any]) {
        advertising.forEach { ad in ad.setProductTestData(data) }
    }
}
