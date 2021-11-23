//
//  HolisticSolutionSDKTests.swift
//  HolisticSolutionSDKTests
//
//  Created by Stas Kochkin on 17.11.2021.
//  Copyright © 2021 com.appodeal. All rights reserved.
//

import XCTest
@testable import HolisticSolutionSDK


class HolisticSolutionSDKTests: XCTestCase {
    func testParametersMerging1() {
        let customParams: [String: Any]? = [
            "key_1": "value_1",
            "key_2": "value_2",
            "key_3": 3
        ]
        let partnerParameters: PartnerParameters? = [
            "key_4": "value_4",
            "key_5": "value_5"
        ]
        
        let result = merged(String.self, customParams, partnerParameters)!
        
        XCTAssertEqual(result["key_1"], "value_1")
        XCTAssertEqual(result["key_2"], "value_2")
        XCTAssertNil(result["key_3"])
        XCTAssertEqual(result["key_4"], "value_4")
        XCTAssertEqual(result["key_5"], "value_5")
    }
    
    func testParametersMerging2() {
        let customParams: [String: Any]? = nil
        let partnerParameters: PartnerParameters? = [
            "key_4": "value_4",
            "key_5": "value_5"
        ]
        
        let result = merged(String.self, customParams, partnerParameters)!
        
        XCTAssertNil(result["key_1"])
        XCTAssertNil(result["key_2"])
        XCTAssertNil(result["key_3"])
        XCTAssertEqual(result["key_4"], "value_4")
        XCTAssertEqual(result["key_5"], "value_5")
    }
    
    func testParametersMerging3() {
        let customParams: [String: Any]? = [
            "key_1": "value_1",
            "key_2": "value_2",
            "key_3": 3
        ]
        let partnerParameters: PartnerParameters? = nil
        
        let result = merged(AnyHashable.self, customParams, partnerParameters)!
        
        XCTAssertEqual(result["key_1"], "value_1")
        XCTAssertEqual(result["key_2"], "value_2")
        XCTAssertEqual(result["key_3"], 3)
        XCTAssertNil(result["key_4"])
        XCTAssertNil(result["key_5"])
    }
}
