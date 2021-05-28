//
//  APIConnnector.swift
//  HolisticSolutionSDK
//
//  Created by Stas Kochkin on 25.05.2021.
//  Copyright © 2021 com.appodeal. All rights reserved.
//

import Foundation
import StackFoundation


final class API {
    fileprivate struct Services: Encodable {
        private struct ServiceParameters: Encodable {
            var version, sdk: String
        }
        
        var services: [Service]
        
        init(services: [Service]) {
            self.services = services
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: DynamicCodingKey.self)
            try services.forEach {
                guard let key = DynamicCodingKey(stringValue: $0.name) else { return }
                let parameters = ServiceParameters(version: $0.version, sdk: $0.sdkVersion)
                try container.encode(parameters, forKey: key)
            }
        }
    }
    
    fileprivate struct Request: Encodable {
        var appKey: String
        var trackId: String
        var services: Services

        var sdkVersion = App.sdkVersion
        var package = Bundle.main.bundleIdentifier
        var installer = Installer.current()
        var connection = Connnection.current()
        var timezone = STKDevice.timezone
        var ifa = STKAd.advertisingIdentifier
        var idfv = STKAd.vendorIdentifier
        var httpAllowed = STKDevice.isHTTPSupport
        var manufacturer = "apple"
        var osv = STKDevice.osv
        var os = STKDevice.os
        var locale = STKDevice.languageCode
        var localTime = UInt(Date().timeIntervalSince1970)
        var trackingAuthorizationStatus = STKAd.trackingAuthorizationStatus
        var advertisingTracking = STKAd.advertisingTrackingEnabled
        var deviceType = DeviceType.current()
        var model = UIDevice.current.model
        var userAgent = STKDevice.userAgent
        
        init(
            appKey: String,
            trackId: String,
            services: [Service]
        ) {
            self.appKey = appKey
            self.trackId = trackId
            self.services = Services(services: services)
        }
    }
    
    private let url = URL(string: "http://herokuapp.appodeal.com/hs_init")!//  URL(string: "https://a.appbaqend.com/hs/init")!
    private let request: Request
    
    init(
        appKey: String,
        trackId: String,
        services: [Service]
    ) {
        request = Request(
            appKey: appKey,
            trackId: trackId,
            services: services
        )
    }
    
    func fetch(
        success: @escaping ([String: AnyHashable]) -> Void,
        failure: @escaping (HSError) -> Void
    ) {
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringCacheData,
            timeoutInterval: 10
        )
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(self.request)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession
            .shared
            .dataTask(with: request) { data, _, _ in
                guard let response: RawParameters = STKJSONSerialization.jsonObject(data) else {
                    failure(.service)
                    return
                }
                success(response)
            }
            .resume()
    }
    
    func setDebug(_ debug: AppConfiguration.Debug) {}
}


extension API.Request {
    enum Installer: String, Codable {
        case unknown
        case debug
        case test
        case appstore
        
        static func current() -> Installer {
            guard !STKDevice.isDebug else { return .debug }
            guard let receiptPath = Bundle.main.appStoreReceiptURL else { return .unknown }
            if receiptPath.lastPathComponent == "sandboxReceipt" { return .test }
            guard
                receiptPath.lastPathComponent == "receipt",
                FileManager.default.fileExists(atPath: receiptPath.path)
            else { return .unknown }
            return .appstore
        }
    }
    
    enum Connnection: String, Codable {
        case other
        case wifi
        case mobile
        
        static func current() -> Connnection {
            switch STKConnection.status {
            case .WWAN: return .mobile
            case .wiFi: return .wifi
            default: return .other
            }
        }
    }
    
    enum DeviceType: String, Codable {
        case phone
        case pad = "tablet"
        case other
        
        static func current() -> DeviceType {
            switch UIDevice.current.userInterfaceIdiom {
            case .phone: return .phone
            case .pad: return .pad
            default: return .other
            }
        }
    }
}


extension STKAd.AuthorizationStatus: Codable {}


private extension STKJSONSerialization {
    static func jsonObject<T>(_ data: Data?, options: JSONSerialization.ReadingOptions = []) -> T? {
        return data
            .flatMap { try? jsonObject(with:$0, options:options) }
            .flatMap { $0 as? T}
    }
}


private extension UIDevice {
    var model: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

private struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(intValue: Int) {
        return nil
    }
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
}
