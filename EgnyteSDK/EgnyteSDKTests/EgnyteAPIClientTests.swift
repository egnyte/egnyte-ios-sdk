//
//  EgnyteAPIClientTests.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 28.10.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import XCTest
@testable import EgnyteSDK

class mockMiddleware: RequestMiddleware {
    
    func processRequest(_ request: URLRequest) -> URLRequest {
        var result = request
        
        result.httpShouldHandleCookies = true
        result.addValue("Hello", forHTTPHeaderField: "MyField")
        return result
    }
}

class EgnyteAPIClientTests: XCTestCase {
    
    func testCustomMiddleware() {
        let fixture = EgnyteAPIClient.init(domainURL: URL.init(string: "test.com")!,
                                           token: "mockToken",
                                           middleware: [mockMiddleware.init()],
                                           session: nil,
                                           callbackQueue: nil,
                                           queriesPerSecond: nil)
        
        let request = URLRequest.init(url: URL.init(string: "test.com")!)
        
        let result = fixture.applyMiddlewareOperationsTo(request: request)
        
        XCTAssert(result.value(forHTTPHeaderField: "Authorization") == "Bearer mockToken")
        XCTAssert(result.value(forHTTPHeaderField: "MyField") == "Hello")
        XCTAssert(result.httpShouldHandleCookies == true)
    }
    
    func testDefaultMiddleware() {
        let fixture = EgnyteAPIClient.init(domainURL: URL.init(string: "test.com")!,
                                           token: "mockToken")
        
        let request = URLRequest.init(url: URL.init(string: "test.com")!)
        let result = fixture.applyMiddlewareOperationsTo(request: request)
        
        XCTAssert(result.value(forHTTPHeaderField: "Authorization") == "Bearer mockToken")
    }
    
}
