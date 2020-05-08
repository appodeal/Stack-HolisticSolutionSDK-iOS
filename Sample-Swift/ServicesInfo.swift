//
//  ServicesInfo.swift
//  Sample-Swift
//
//  Created by Stas Kochkin on 08.05.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

import Foundation


let servicesInfo: ServicesInfo = {
    let xml: Data! = Bundle.main
        .path(forResource: "Services-Info", ofType: "plist")
        .flatMap(FileManager.default.contents)
    let decoder = PropertyListDecoder()
    return try! decoder.decode(
        ServicesInfo.self,
        from: xml
    )
}()


struct ServicesInfo: Decodable {
    enum Keys: String, CodingKey {
        case appodeal = "Appodeal"
        case appsFlyer = "AppsFlyer"
    }
    
    struct Appodeal: Decodable {
        enum Keys: String, CodingKey {
            case apiKey = "ApiKey"
        }
        
        var apiKey: String
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            apiKey = try container.decode(String.self, forKey: .apiKey)
        }
    }
    
    struct AppsFlyer: Decodable {
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
    
    var appodeal: Appodeal
    var appsFlyer: AppsFlyer
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        appodeal = try container.decode(ServicesInfo.Appodeal.self, forKey: .appodeal)
        appsFlyer = try container.decode(ServicesInfo.AppsFlyer.self, forKey: .appsFlyer)
    }
}
