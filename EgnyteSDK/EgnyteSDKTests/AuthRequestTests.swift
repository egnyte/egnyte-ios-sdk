//
//  AuthRequestTests.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 25.10.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import XCTest
@testable import EgnyteSDK

class AuthRequestTests: XCTestCase {
    
    func testConvinientRegionInitializer() {
        let fixture = AuthRequest.init(apiKey: "apiKey", sharedSecret: "sharedSecret")
        
        XCTAssert(fixture.apiKey == "apiKey")
        XCTAssert(fixture.sharedSecret == "sharedSecret")
        XCTAssert(fixture.region! == Region.us)
        XCTAssert(fixture.egnyteDomainURL == nil)
        XCTAssert(fixture.scope == nil)
        XCTAssert(fixture.state.data(using: .utf8)!.count * 8 == 160)
    }
    
    func testConvinientDomainInitializerProperDomain() {
        
        let fixture = AuthRequest.init(apiKey: "apiKey",
                                       sharedSecret: "sharedSecret",
                                       egnyteDomainURL:URL.init(string:"https://qaaa.egnyte.com")!)
        
        XCTAssert(fixture.apiKey == "apiKey")
        XCTAssert(fixture.sharedSecret == "sharedSecret")
        XCTAssert(fixture.region == nil)
        XCTAssert(fixture.egnyteDomainURL == URL.init(string:"https://qaaa.egnyte.com"))
        XCTAssert(fixture.scope == nil)
        XCTAssert(fixture.state.data(using: .utf8)!.count * 8 == 160)
    }
    
    func testScopeStringRepresentation() {
        XCTAssert(Scope.audit.toString() == "Egnyte.audit")
        XCTAssert(Scope.bookmark.toString() == "Egnyte.bookmark")
        XCTAssert(Scope.fileSystem.toString() == "Egnyte.filesystem")
        XCTAssert(Scope.user.toString() == "Egnyte.user")
        XCTAssert(Scope.group.toString() == "Egnyte.group")
        XCTAssert(Scope.permission.toString() == "Egnyte.permission")
        XCTAssert(Scope.link.toString() == "Egnyte.link")

    }

}
