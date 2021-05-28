//
//  HSService.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 30.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


@objc(HSService) public
protocol Service {
    var name: String { get }
    var sdkVersion: String { get }
    var version: String { get }
    
    init()
}


protocol Initializable: Service {
    associatedtype Parameters
    
    func initialize(
        _ parameters: Parameters,
        completion: @escaping (HSError?) -> ()
    )
}

protocol RawParametersInitializable: Service {
    func initialize(
        _ parameters: RawParameters,
        completion: @escaping (HSError?) -> ()
    )
}


typealias RawParameters = [String: AnyHashable]
