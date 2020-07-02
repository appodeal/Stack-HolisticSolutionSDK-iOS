//
//  HSTrackEventOperation.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 01.07.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation

final class HSTrackEventOperation: Operation {
    private let analytics: [HSAnalyticsService]
    private let event: String
    private let params: [String: Any]?
    
    init(configuration: HSAppConfiguration,
         event: String,
         params: [String: Any]?) {
        self.analytics = configuration.analytics
        self.event = event
        self.params = params
        super.init()
    }
    
    override func start() {
        guard !isCancelled else { return }
        analytics.forEach { $0.trackEvent(event, customParameters: params) }
    }
}
