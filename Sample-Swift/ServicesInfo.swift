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
    
    var appodeal: Appodeal
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        appodeal = try container.decode(ServicesInfo.Appodeal.self, forKey: .appodeal)
    }
}
