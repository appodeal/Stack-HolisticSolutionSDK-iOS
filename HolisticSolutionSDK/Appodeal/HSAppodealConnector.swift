//
//  HSAppodealConnector.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 26.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation
import Appodeal


@objc public
extension HSAppConfiguration {
    @objc convenience
    init(services: [HSService],
         advertising: HSAdvertising = HSAppodealConnector(),
         timeout: TimeInterval = kHSAppDefaultTimeout) {
        self.init(services: services, connectors: [advertising], timeout: timeout)
    }
}


@objc public
final class HSAppodealConnector: NSObject {
    public typealias Success = () -> Void
    public typealias Failure = (HSError) -> Void
    
    public var trackingEnabled: Bool = true
}

extension HSAppodealConnector: HSAdvertising {
    public func setAttributionId(_ attributionId: String) {
        Appodeal.setExtras(["attribution_id": attributionId])
    }
    
    public func setConversionData(_ converstionData: [AnyHashable : Any]) {
        Appodeal.setCustomState(converstionData)
    }
    
    public func setProductTestData(_ productTestData: [AnyHashable : Any]) {
        let keywords = productTestData.values.compactMap { $0 as? String }.joined(separator: ",")
        Appodeal.setExtras(["keywords": keywords])
    }
}

extension HSAppodealConnector: HSAnalyticsService {
    func trackEvent(_ event: String, customParameters: [String : Any]?) {
        Appodeal.setExtras([event : customParameters ?? [:]])
    }
    
    func trackInAppPurchase(_ purchase: HSPurchase) {
        guard trackingEnabled else { return }
        DispatchQueue.main.async {
            Appodeal.track(inAppPurchase: NSNumber(value: purchase.price.convertPrice()),
                           currency: purchase.currency)
        }
    }
    
    //MARK: - Noop
    public func initialise(success: @escaping Success,
                           failure: @escaping Failure) {}
    public func setDebug(_ debug: HSAppConfiguration.Debug) {}
}

fileprivate extension String {
    func convertPrice() -> Double {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        if let number = formatter.number(from: self) {
            return number.doubleValue
        } else {
            let pattern = #"(\d.)+"#
            // Remove spaces and replace comma with dot
            let withoutSpaces = self
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: ",", with: ".")
            // Search numbers
            guard let range = withoutSpaces.range(of:pattern, options: .regularExpression)
            else { return 0 }
            // Search whole and fractional parts
            let result = String(withoutSpaces[range]).components(separatedBy: ".")
            let fractionalPart = result.last ?? "00"
            let wholePart  = result.dropLast().joined()
            let raw = wholePart.appending(".").appending(fractionalPart)
            // Try to parse it again
            let number = formatter.number(from: raw)
            return number?.doubleValue ?? 0
        }
    }
}
