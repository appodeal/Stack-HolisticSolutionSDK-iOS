//
//  HSPlistDecodable.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 26.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


public
enum HSPlist {
    case main
    case custom(path: String)
}

@objc public
protocol HSPlistDecodable: class {
    @objc
    init(plistName: String) throws
    
}

public
protocol HSPlistDecodableExtended: HSPlistDecodable {}

public
extension HSPlistDecodableExtended {
    init(plist: HSPlist) throws {
        switch plist {
        case .main: try self.init(plistName: "Info")
        case .custom(let name): try self.init(plistName: name)
        }
    }
}
