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
        productTesting.forEach { service in
            service.onReceiveConfig = { [weak self] in self?.syncProductTestingData($0) }
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
    
    private func syncProductTestingData(_ data: [AnyHashable: Any]) {
        advertising.forEach { ad in ad.setProductTestData(data) }
    }
}
