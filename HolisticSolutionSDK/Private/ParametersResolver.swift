//
//  ParametersResolver.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 17.11.2021.
//  Copyright © 2021 com.appodeal. All rights reserved.
//

import Foundation


internal func merged<T>(
    _ valuesType: T.Type,
    _ parameters: [String: Any]? ...
) -> [String: T]? {
    let unwrapped = parameters.compactMap { $0 }
    guard unwrapped.count > 0 else { return nil }
    let rawParameters = unwrapped.reduce([:]) { result, next in
        return result.merging(next) { first, _ in return first }
    }
    
    return rawParameters.compactMapValues {
        return $0 as? T
    }
}
