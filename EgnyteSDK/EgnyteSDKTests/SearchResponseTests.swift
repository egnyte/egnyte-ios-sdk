//
//  SearchResponseTests.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 21.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import XCTest
@testable import EgnyteSDK

class SearchResponseTests: XCTestCase {
    
    func testParsingProperResponse() {
        let data = self.properSharedData()
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        let fixture = try! SearchResponse.init(json: json as! [String : Any])
        
        XCTAssert(fixture.count == 9)
        XCTAssert(fixture.hasMore == false)
        XCTAssert(fixture.offset == 0)
        XCTAssert(fixture.totalCount == 9)
        XCTAssert(fixture.results.count == 9)
    }
    
    
    func testParsingMalformedResponse() {
        let data = self.properSharedData()
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        do{
            _ = try SearchResponse.init(json: json as! [String : Any])
        }catch let error {
            XCTAssert(error.localizedDescription == "kUnexpectedReponse")
        }
    }
    
    func properSharedData() -> Data {
        let bundle = Bundle(for:self.classForCoder)
        let path = bundle.path(forResource: "searchJSONproper", ofType: "json")!
        return try! NSData(contentsOfFile: path) as Data
    }
    
    func malformedSharedData() -> Data {
        let bundle = Bundle(for:self.classForCoder)
        let path = bundle.path(forResource: "searchJSONproper", ofType: "json")!
        return try! NSData(contentsOfFile: path) as Data
    }
    
}
