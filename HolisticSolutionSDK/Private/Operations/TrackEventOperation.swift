//
//  HSTrackEventOperation.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 01.07.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


final class TrackEventOperation: AsynchronousOperation {
    private let event: String
    private let params: [String: Any]?
    
    var analytics: [AnalyticsService] = []
    var advertising: Advertising?
    
    init(
        event: String,
        params: [String: Any]?
    ) {
        self.event = event
        self.params = params
        super.init()
    }
    
    override func main() {
        super.main()
        App.log("""
Track event \(event), \
parameters: \(params?.description ?? "-"), \
partner parameters: \(advertising?.partnerParameters.description ?? "-")
""")
        analytics.forEach {
            $0.trackEvent(
                event,
                customParameters: params,
                partnerParameters: advertising?.partnerParameters
            )
        }
        finish()
    }
}
