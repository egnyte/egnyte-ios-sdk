//
//  OAuthHelperTests.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 26.10.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import XCTest
@testable import EgnyteSDK

class OAuthHelperTests: XCTestCase {
    var fixture: OAuthHelper?
    let request = URLRequest.init(url: URL.init(string: "https://test.egnyte.com/puboauth/token?client_id=testID&state=testState&scope=%20Egnyte.filesystem%20Egnyte.audit%20Egnyte.user&mobile=1&response_type=code&redirect_uri=https://egnyte.com")!)
    var checkCompletion: ((AuthResult) -> Void)?
    
    override func setUp() {
        self.fixture = OAuthHelper.init(urlRequest: self.request, sharedSecret: "AAA") { (result) in
            self.checkCompletion?(result)
        }
        super.setUp()
    }
    
    override func tearDown() {
        self.fixture = nil
        self.checkCompletion = nil
        super.tearDown()
    }
    
    func testRetrievingQueryValues() {
        let result1 = self.fixture!.queryValue(request.url!, key: "scope")
        let result2 = self.fixture!.queryValue(request.url!, key: "client_id")
        let result3 = self.fixture!.queryValue(request.url!, key: "state")
        let result4 = self.fixture!.queryValue(request.url!, key: "redirect_uri")
        
        XCTAssert(result1 == " Egnyte.filesystem Egnyte.audit Egnyte.user")
        XCTAssert(result2 == "testID")
        XCTAssert(result3 == "testState")
        XCTAssert(result4 == "https://egnyte.com")
        
    }
    
    func testRedirection() {
        XCTAssertFalse(self.fixture!.shouldRedirectForRequest(URLRequest.init(url: URL.init(string: "https://egnyte.com")!)))
        XCTAssert(self.fixture!.shouldRedirectForRequest(URLRequest.init(url: URL.init(string: "https://not.egnyte.com")!)))
    }
    
    func testAccessDeniedError(){
        self.checkCompletion = { result in
            do {
               _ = try result()
            }catch AuthError.accessDenied {
                XCTAssert(true)
            }catch _ {
                XCTFail()
            }
        }
        _ = self.fixture?.processIntermidateAuthResult(URLRequest.init(url: URL.init(string:"https://yourapp.com/oauth?error=access_denied&state=aaa")!))
    }
    
    func testInvalidResponseError(){
        self.checkCompletion = { result in
            do {
                _ = try result()
            }catch AuthError.invalidResponseStateParameter {
                XCTAssert(true)
            }catch _ {
                XCTFail()
            }
        }
        _ = self.fixture?.processIntermidateAuthResult(URLRequest.init(url: URL.init(string:"https://yourapp.com/oauth?code=OAUTH_CODE&state=wrongState")!))
    }
    
    func testNetworkError() {
        self.checkCompletion = { result in
            do {
                _ = try result()
            }catch is AuthError {
                XCTFail()
            }catch _ {
                XCTAssert(true)
            }
        }
        fixture?.processAuthResponse(data: nil, response: nil, error: NSError.init(), exchangeRequest: self.request)
    }
    
    func testUnexpectedResponseError_NoResponse() {
        self.checkCompletion = { result in
            do {
                _ = try result()
            }catch EgnyteError.unexpectedResponse(_){
                XCTAssert(true)
            }catch _ {
                XCTFail()
            }
        }
        fixture?.processAuthResponse(data: nil, response: nil, error: nil, exchangeRequest: self.request)
    }
    
    func testUnexpectedResponseError_WrongResponseFormat() {
        self.checkCompletion = { result in
            do {
                _ = try result()
            }catch EgnyteError.unexpectedResponse(let description){
                XCTAssert(true)
                XCTAssert(description == "kUnexpectedResponse")
            }catch _ {
                XCTFail()
            }
        }
        fixture?.processAuthResponse(data: nil, response: URLResponse.init(), error: nil, exchangeRequest: self.request)
    }
    
    func testHTTPError() {
        let response400 = HTTPURLResponse.init(url: URL.init(string: "egnyte.com")!,
                                               statusCode: 400,
                                               httpVersion: nil,
                                               headerFields: nil)
        
        let data = try!JSONSerialization.data(withJSONObject: ["message" : "What an error!"], options: [])
        self.checkCompletion = { result in
            do {
                _ = try result()
            }catch EgnyteError.httpError(let code, let description){
                XCTAssert(true)
                XCTAssert(description == "What an error!")
                XCTAssert(code == 400)
            }catch _ {
                XCTFail()
            }
        }
        fixture?.processAuthResponse(data: data, response: response400, error: nil, exchangeRequest: self.request)
        
    }
    
    func testCannotRetrieveToken() {
        let response200 = HTTPURLResponse.init(url: URL.init(string: "egnyte.com")!,
                                               statusCode: 200,
                                               httpVersion: nil,
                                               headerFields: nil)
        
        let data = try!JSONSerialization.data(withJSONObject: ["access_tokenono" : "12345"], options: [])
        self.checkCompletion = { result in
            do {
                _ = try result()
            }catch EgnyteError.unexpectedResponse(let description){
                XCTAssert(true)
                XCTAssert(description == "kUnexpectedResponse")

            }catch _ {
                XCTFail()
            }
        }
        fixture?.processAuthResponse(data: data, response: response200, error: nil, exchangeRequest: self.request)
    }
    
    func testSuccessRetrieveToken() {
        let response200 = HTTPURLResponse.init(url: URL.init(string: "egnyte.com")!,
                                               statusCode: 200,
                                               httpVersion: nil,
                                               headerFields: nil)
        
        let data = try!JSONSerialization.data(withJSONObject: ["access_token" : "12345"], options: [])
        self.checkCompletion = { result in
            do {
                let response = try result()
                XCTAssert(response.token == "12345")
                XCTAssert(response.egnyteDomainURL == URL.init(string: "https://test.egnyte.com"))
            }catch _ {
                XCTFail()
            }
        }
        fixture?.processAuthResponse(data: data, response: response200, error: nil, exchangeRequest: self.request)
    }
    
    func testCreatingExchangeRequest() {
        // TODO
    }
}
