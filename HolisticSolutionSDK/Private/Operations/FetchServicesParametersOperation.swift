//
//  FetchServicesParametersOperation.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 19.05.2021.
//  Copyright © 2021 com.appodeal. All rights reserved.
//

import Foundation


final class FetchServicesParametersOperation: AsynchronousOperation {
    private let appKey: String
    private let trackId: String
    
    var services: [Service] = []
    
    private(set) var response: [String: AnyHashable]?
    
    private var connector: API!
    
    init(appKey: String, trackId: String) {
        self.appKey = appKey
        self.trackId = trackId
    }
    
    override func main() {
        super.main()
        
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.connector = .init(
                appKey: self.appKey,
                trackId: self.trackId,
                services: self.services
            )
            semaphore.signal()
        }
        semaphore.wait()
        
        App.log("Fetch parameters for services")
        connector.fetch(
            success: { [weak self] response in
                self?.response = response
                self?.finish()
            },
            failure: { [weak self] _ in
                self?.finish()
            }
        )
    }
}
