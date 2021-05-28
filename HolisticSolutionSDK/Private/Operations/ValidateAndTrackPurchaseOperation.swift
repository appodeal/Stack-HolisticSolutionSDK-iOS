//
//  HSValidateAndTrackPurchaseOperation.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 01.07.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


final class ValidateAndTrackPurchaseOperation: AsynchronousOperation {
    private typealias FailedResponse = (Error?, Any?)
    
//    private let attribution: [AttributionService]
//    private let analytics: [AnalyticsService]
    private let purchase: Purchase
    private let debug: AppConfiguration.Debug
    
    private let success:(([AnyHashable: Any]) -> Void)?
    private let failure:((Error?, Any?) -> Void)?
    
    private var error: FailedResponse?
    private var response: [AnyHashable: Any] = [:]
    
    private lazy var group = DispatchGroup()
    
    init(
        configuration: AppConfiguration,
        purchase: Purchase,
        success:(([AnyHashable: Any]) -> Void)?,
        failure:((Error?, Any?) -> Void)?
    ) {
        //        self.attribution = configuration.attribution
        //        self.analytics = configuration.analytics
        self.purchase = purchase
        self.debug = configuration.debug
        self.success = success
        self.failure = failure
        super.init()
    }
    
    override func main() {
        super.main()
        debug.log("Validate and track in-app purchase")
//        attribution.forEach { service in
//            group.enter()
//            service.validateAndTrackInAppPurchase(
//                purchase,
//                success: { [weak self] response in
//                    self?.response.merge(response) { current, _ in current }
//                    self?.group.leave()
//                },
//                failure: { [weak self] error, id in
//                    self?.error = (error, id)
//                    self?.group.leave()
//                }
//            )
//        }
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            if let error = self.error {
                self.failure?(error.0, error.1)
            } else {
//                self.analytics.forEach { $0.trackInAppPurchase(self.purchase) }
//                self.success?(self.response)
            }
            self.finish()
        }
    }
}
