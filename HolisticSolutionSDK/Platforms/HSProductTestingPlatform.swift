//
//  HSProductTestingPlatform.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 25.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


@objc public protocol HSProductTestingPlatform: HSDebuggable {
    var onReceiveConfig: (([AnyHashable: Any]) -> Void)? { get set }
    
    func initialise(completion: @escaping (HSProductTestingPlatform) -> Void)
}
