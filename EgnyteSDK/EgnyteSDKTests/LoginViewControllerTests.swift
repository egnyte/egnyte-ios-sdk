//
//  LoginViewControllerTests.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 25.10.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import XCTest
@testable import EgnyteSDK
import WebKit

class OAuthHelperMock: OAuthWebDelegate {
    var didResignedSent: Bool = false
    var shouldRedirectSent: Bool = false
    
    func didResigned() {
        self.didResignedSent = true
    }
    
    func shouldRedirectForRequest(_ urlRequest: URLRequest) -> Bool {
        self.didResignedSent = true
        return true
    }
    
    func didReceive(error: Error) -> Void {
        
    }
}

class LoginViewControllerTests: XCTestCase {
    
    func testCancelAuthDelegation() {
        let mockAuthDelegate = OAuthHelperMock.init()
        let fixture = LoginViewController.init(urlRequest: URLRequest.init(url: URL.init(string: "test.com")!), oAuthDelegate: mockAuthDelegate)
        fixture.didCancelAuthProcess()
        XCTAssert(mockAuthDelegate.didResignedSent == true)
    }
}
