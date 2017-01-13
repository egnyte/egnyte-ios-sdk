//
//  EgnyteEntityTests.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 04.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import XCTest
@testable import EgnyteSDK

class EgnyteEntityTests: XCTestCase {
    
    func testFolderParsing() {
        let data = self.properFolderData()
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        let result = try! EgnyteFolder.init(json: json as! [String : Any])
        
        XCTAssert(result.name == "!!___Adam")
        XCTAssert(result.lastModified == 1477614023)
        XCTAssert(result.path == "/Shared/!!___Adam")
        XCTAssert(result.customMetadata == nil)
        XCTAssert(result.id == "f8e17cc8-fbff-4dfb-8214-cbc87044ac06")
        XCTAssert(result.permission == "Owner")
        XCTAssert(result.allowedFileLinkTypes! == [
            "anyone",
            "password",
            "domain",
            "recipients"
            ])
        XCTAssert(result.allowedFolderLinkTypes! == [
            "anyone",
            "password",
            "domain",
            "recipients"
            ])
        XCTAssert(result.allowUploadLinks!)  
    }
    
    func testFolderParsingError() {
        let data = self.malformedFolderData()
        do{
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            _ = try EgnyteFolder.init(json: json as! [String : Any])
            XCTFail()
        }catch _ {
            XCTAssert(true)
        }
    }
    
    func testFileParsing() {
        let data = self.properFileData()
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        let result = try! EgnyteFile.init(json: json as! [String : Any])
        
        XCTAssert(result.name == "Essay.pages")
        XCTAssert(result.path == "/Shared/!!___Adam/Essay.pages")
        XCTAssert(result.checksum == "266f72824cae9c41e94b3be8ded4f4c58012750246013f01fa171242405ebe13c72eba54dfa74cf98aa83ef7fbfd0683a02104b1d2a4af734cbcf0793aadfdcd")
        XCTAssert(result.customMetadata == nil)
        XCTAssert(result.entryId == "d366fb4c-3c22-4bfd-ba2c-c58940a7fcde")
        XCTAssert(result.groupId == "f08b2cce-1fc7-4073-8a4c-718d4a18436d")
        XCTAssert(result.lastModified == 1443620594)
        XCTAssert(result.locked == false)
        XCTAssert(result.versionsCount == 2)
        XCTAssert(result.uploadedBy == "asdf1")
        XCTAssert(result.versions!.count == 1)

    }
    
    func testFileParsingError() {
        let data = self.malformedFileData()
        do{
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            _ = try EgnyteFile.init(json: json as! [String : Any])
            XCTFail()
        }catch _ {
            XCTAssert(true)
        }
    }
    
    func properFolderData() -> Data {
        let bundle = Bundle(for:self.classForCoder)
        let path = bundle.path(forResource: "folderContentJSONproper", ofType: "json")!
        return try! NSData(contentsOfFile: path) as Data
    }
    
    func malformedFolderData() -> Data {
        let bundle = Bundle(for:self.classForCoder)
        let path = bundle.path(forResource: "folderContentJSONmalformed", ofType: "json")!
        return try! NSData(contentsOfFile: path) as Data
    }
    
    func properFileData() -> Data {
        let bundle = Bundle(for:self.classForCoder)
        let path = bundle.path(forResource: "fileJSONproper", ofType: "json")!
        return try! NSData(contentsOfFile: path) as Data
    }
    
    func malformedFileData() -> Data {
        let bundle = Bundle(for:self.classForCoder)
        let path = bundle.path(forResource: "fileJSONmalformed", ofType: "json")!
        return try! NSData(contentsOfFile: path) as Data
    }
}
