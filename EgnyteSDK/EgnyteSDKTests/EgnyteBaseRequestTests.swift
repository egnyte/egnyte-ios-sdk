//
//  EgnyteBaseRequestTests.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 27.10.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import XCTest
@testable import EgnyteSDK

class EgnyteBaseRequestTests: XCTestCase {
    
    func testURLRequestCreationWithParams() {
        let result = try! EgnyteBaseRequest.requestWith(baseURL: URL.init(string: "http://test.egnyte.com")!,
                                                            endpoint: "fsi/v1",
                                                            filepath: nil,
                                                            parameters: ["Java_sucks": "true"],
                                                            method: "POST")
        
        XCTAssert(result.url == URL.init(string: "http://test.egnyte.com/fsi/v1"))
        let retrievedData = try! JSONSerialization.jsonObject(with: result.httpBody!, options: []) as! [String : String]
        XCTAssert(retrievedData == ["Java_sucks": "true"])
    }
    
    func testURLRequestCreationWithoutParams() {
        let result = try! EgnyteBaseRequest.requestWith(baseURL: URL.init(string: "http://test.egnyte.com")!,
                                                            endpoint: "fsi/v1",
                                                            filepath: nil,
                                                            parameters: nil,
                                                            method: "POST")
        
        XCTAssert(result.url == URL.init(string: "http://test.egnyte.com/fsi/v1"))
        XCTAssert(result.httpBody == nil)
    }
    
    func testURLRequestCreationWithInvalidParams() {
        do {
            _ = try EgnyteBaseRequest.requestWith(baseURL: URL.init(string: "http://test.egnyte.com")!,
                                                      endpoint: "fsi/v1",
                                                      filepath: nil,
                                                      parameters: ["Java_sucks": UIViewController.init() as AnyObject],
                                                      method: "POST")
        }catch let error {
            XCTAssert(error.localizedDescription == "kInvalidJSONparameters")
            XCTAssert((error as! CustomNSError ).errorCode == -2)
        }
        
    }
    
    func testURLRequestCreationWithFilePathPolish() {
        let result = try! EgnyteBaseRequest.requestWith(baseURL: URL.init(string: "http://test.egnyte.com")!,
                                                        endpoint: "fsi/v1",
                                                        filepath: "źdźbło/żółć/żółw a",
                                                        parameters: nil,
                                                        method: "POST")
        
        XCTAssert(result.url == URL.init(string: "http://test.egnyte.com/fsi/v1/%C5%BAd%C5%BAb%C5%82o/%C5%BC%C3%B3%C5%82%C4%87/%C5%BC%C3%B3%C5%82w%20a"))
        XCTAssert(result.httpBody == nil)
    }
    
    func testURLRequestCreationWithFilePathEnglish() {
        let result = try! EgnyteBaseRequest.requestWith(baseURL: URL.init(string: "http://test.egnyte.com")!,
                                                        endpoint: "fsi/v1",
                                                        filepath: "grass/yellow/turtle",
                                                        parameters: nil,
                                                        method: "POST")
        
        XCTAssert(result.url == URL.init(string: "http://test.egnyte.com/fsi/v1/grass/yellow/turtle"))
        XCTAssert(result.httpBody == nil)
    }
    
}
