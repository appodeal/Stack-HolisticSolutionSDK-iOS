//
//  HSAppServicesPlist.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 25.06.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


internal struct HSPlatformConfiguration: Decodable {
    enum Keys: String, CodingKey {
        case appsFlyer = "AppsFlyer"
    }
    
    struct AppsFlyerData: Decodable {
        enum Keys: String, CodingKey {
            case devKey = "DevKey"
            case appId = "AppId"
        }
        
        var devKey: String
        var appId: String
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            devKey = try container.decode(String.self, forKey: .devKey)
            appId = try container.decode(String.self, forKey: .appId)
        }
    }
    
    let appsFlyer: AppsFlyerData
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        appsFlyer = try container.decode(HSPlatformConfiguration.AppsFlyerData.self, forKey: .appsFlyer)
    }
}

internal extension PropertyListDecoder {
    enum HSDecodeError: Error {
        case notFound
    }
    
    func decodeConfiguration(fromPlist: String) throws -> HSPlatformConfiguration {
        let xmlData: Data? = Bundle.main
            .path(forResource: fromPlist, ofType: "plist")
            .flatMap(FileManager.default.contents)
        guard let xml = xmlData else { throw HSDecodeError.notFound }
        return try decode(HSPlatformConfiguration.self, from: xml)
    }
}
