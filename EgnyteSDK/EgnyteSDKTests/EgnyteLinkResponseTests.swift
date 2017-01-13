//
//  EgnyteLinkResponseTests.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 16.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import XCTest
import EgnyteSDK

class EgnyteLinkResponseTests: XCTestCase {
    
    func testParsingProperData() {
        let data = self.properLinkData()
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        let fixture = try! EgnyteLinkResponse.init(json: json as! [String : Any])
        
        XCTAssert(fixture.links.count == 2)
        XCTAssert(fixture.links[0].id == "66ilRMjSCz")
        XCTAssert(fixture.links[1].id == "jmg1fdUFrg")
        XCTAssert(fixture.links[0].urlPath == "https://qaaa.egnyte.com/dl/66ilRMjSCz")
        XCTAssert(fixture.links[1].urlPath == "https://qaaa.egnyte.com/dl/jmg1fdUFrg")
        XCTAssert(fixture.links[0].recipients[0] == "test1@.op.pl")
        XCTAssert(fixture.links[1].recipients.isEmpty)
        XCTAssert(fixture.path == "/Shared/!!___Adam/aaaa.txt")
        XCTAssert(fixture.type == .file)
        XCTAssert(fixture.accessibility == .anyone)
        XCTAssert(fixture.notify == false)
        XCTAssert(fixture.creationTimestamp == 1479250800.0)
        XCTAssert(fixture.sendMail == false)
        XCTAssert(fixture.copyMe == false)
        XCTAssert((fixture.expiry as! LinkClicksExpiry).clicks == 8)
    }
    
    func testParsingmalformedData() {
        let data = self.malformedLinkData()
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        
        do {
            _ = try EgnyteLinkResponse.init(json: json as! [String : Any])
            XCTFail()
        }catch _ {
            XCTAssert(true)
        }
    }
    
    func properLinkData() -> Data {
        let bundle = Bundle(for:self.classForCoder)
        let path = bundle.path(forResource: "egnyteLinkJSONproper", ofType: "json")!
        return try! NSData(contentsOfFile: path) as Data
    }
    
    func malformedLinkData() -> Data {
        let bundle = Bundle(for:self.classForCoder)
        let path = bundle.path(forResource: "egnyteLinkJSONmalformed", ofType: "json")!
        return try! NSData(contentsOfFile: path) as Data
    }
}
