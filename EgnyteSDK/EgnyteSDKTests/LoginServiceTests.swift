//
//  LoginServiceTests.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 25.10.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import XCTest
@testable import EgnyteSDK

class LoginServiceTests: XCTestCase {
    var fixture = LoginService.init(presentingViewController: UIViewController.init()) as LoginService?
    
    override func setUp() {
        fixture = LoginService.init(presentingViewController: UIViewController.init())
        super.setUp()
    }
    
    override func tearDown() {
        fixture = nil
        super.tearDown()
    }
    
    func testKnownDomainRequestCreation() {
        let authRequest = AuthRequest.init(apiKey: "testID",
                                                sharedSecret: "testSecret",
                                                egnyteDomainURL: URL.init(string: "https://test.egnyte.com")!,
                                                scope: [.fileSystem, .audit, .user],
                                                state: "testState")
        
        let request = fixture?.createURLRequest(authRequest)
        
        XCTAssert(request?.url?.absoluteString == "https://test.egnyte.com/puboauth/token?client_id=testID&state=testState&scope=%20Egnyte.filesystem%20Egnyte.audit%20Egnyte.user&mobile=1&response_type=code&redirect_uri=https://egnyte.com")
    }
    
    func testConvinientDomainInitializerNoHTTPSScheme() {
        let request =  AuthRequest.init(apiKey: "apiKey",
                                        sharedSecret: "sharedSecret",
                                        egnyteDomainURL:URL.init(string:"qaaa.egnyte.com")!)
        fixture?.performAuthRequest(request){ result in
            do{
                _ = try result()
                XCTFail()
            }
            catch DomainUrlError.forbiddenQuery {
                XCTFail()
            }catch DomainUrlError.httpsSchemeRequired {
                XCTAssert(true)
            }catch _ {
                XCTFail()
            }
        }
    }
    
    func testConvinientDomainInitializerForbiddenQuery() {
        let request =  AuthRequest.init(apiKey: "apiKey",
                                        sharedSecret: "sharedSecret",
                                        egnyteDomainURL:URL.init(string:"https://qaaa.egnyte.com/?aa=bb")!)
        fixture?.performAuthRequest(request){ result in
            do{
                let _ = try result()
                    XCTFail()
            }catch DomainUrlError.httpsSchemeRequired {
                XCTFail()
            }catch DomainUrlError.forbiddenQuery {
                XCTAssert(true)
            }catch _ {
                XCTFail()
            }
        }
    }
    
    func testUnknownDomainRequestCreation() {
        let authRequest =  AuthRequest.init(apiKey: "testID",
                                            sharedSecret: "testSecret",
                                            region: .us,
                                            scope: [.fileSystem, .audit, .user],
                                            state: "testState")
        
        let request = fixture?.createURLRequest(authRequest)
        
        XCTAssert(request?.url?.absoluteString == "https://us-partner-integrations.egnyte.com/services/oauth/code?client_id=testID&state=testState&scope=%20Egnyte.filesystem%20Egnyte.audit%20Egnyte.user&mobile=1&response_type=code&redirect_uri=https://egnyte.com")
    }
    
    
}
