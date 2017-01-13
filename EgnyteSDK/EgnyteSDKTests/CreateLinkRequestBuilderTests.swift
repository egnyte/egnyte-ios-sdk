//
//  CreateLinkRequestBuilderTests.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 16.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import XCTest
@testable import EgnyteSDK

class CreateLinkRequestBuilderTests: XCTestCase {
    
    
    func testBuilderAllParams() {
        let apiClient = EgnyteAPIClient.init(domainURL: URL.init(string: "https://test.com")!,
                                             token: "testToken")
        
        let fixture = CreateLinkRequestBuilder.init(apiClient: apiClient,
                                                    path: "testPath",
                                                    type: .file,
                                                    accessibility: .password, completion: {result in})
        
        fixture.addFilename = true
        fixture.copyMe = false
        fixture.linkToCurrent = true
        fixture.linkExpiry = LinkDateExpiry.init(date: Date.init(timeIntervalSince1970: 60.0 * 60.0 * 24))
        fixture.folderPerRecipient = true
        fixture.recipients = ["aaa@aa.aa", "bbb@bb.bb", "ccc@.cc.cc"]
        fixture.message = "test message"
        fixture.notify = true
        fixture.sendEmail = true
        
        let request = fixture.buildCreateLinkRequest()
        let bodyData = request.request.httpBody
        let json = try! JSONSerialization.jsonObject(with: bodyData!, options: .allowFragments) as! [String: Any]
        
        XCTAssert(request.request.url?.absoluteString == "https://test.com/pubapi/v1/links")
        XCTAssert(json["path"] as! String == "testPath")
        XCTAssert(json["type"] as! String == "file")
        XCTAssert(json["accessibility"] as! String == "password")
        XCTAssert(json["send_email"] as! Bool == true)
        XCTAssert(json["recipients"] as! [String] == ["aaa@aa.aa", "bbb@bb.bb", "ccc@.cc.cc"])
        XCTAssert(json["message"] as! String == "test message")
        XCTAssert(json["copy_me"] as! Bool == false)
        XCTAssert(json["notify"] as! Bool == true)
        XCTAssert(json["link_to_current"] as! Bool == true)
        XCTAssert(json["expiry_date"] as! String == "1970-01-02")
        XCTAssert(json["expiry_clicks"] == nil)
        XCTAssert(json["add_file_name"] as! Bool == true)
        XCTAssert(json["folder_per_recipient"] as! Bool == true)


    }
    
}
