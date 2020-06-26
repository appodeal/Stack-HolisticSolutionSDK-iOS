//
//  HSServiceConnector.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 25.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


@objc public
protocol HSAttributionPlatform: class {
    var id: String? { get }
    var onReceiveData: (([AnyHashable: Any]) -> Void)? { get set }
    
    func initialise(completion: @escaping (HSAttributionPlatform) -> Void)
}
