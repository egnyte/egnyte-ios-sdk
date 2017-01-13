//
//  FolderContentResponseTests.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 06.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import XCTest
@testable import EgnyteSDK

class FolderContentResponseTests: XCTestCase {
    
    func testFolderContentParsing() {
        let data = self.properFolderContentData()
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        let result = try! FolderContentResponse.init(json: json as! [String : Any])
        
        XCTAssert(result.count == 0)
        XCTAssert(result.files.count == 10)
        XCTAssert(result.folders.count == 5)
        XCTAssert(result.offset == 0)
        XCTAssert(result.parentFolder.name == "!!___Adam")
        XCTAssert(result.publicLinks == "files_folders")
        XCTAssert(result.totalCount == 15)
    }
    
    func properFolderContentData() -> Data {
        let bundle = Bundle(for:self.classForCoder)
        let path = bundle.path(forResource: "folderContentJSONproper", ofType: "json")!
        return try! NSData(contentsOfFile: path) as Data
    }
}
