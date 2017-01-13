//
//  FileUploadTest.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 14.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import XCTest
@testable import EgnyteSDK

class FileUploadTest: XCTestCase {
       let egnyteClient = EgnyteAPIClient.init(domainURL: URL.init(string: TEST_DOMAIN)!, token: TEST_TOKEN)

    func testFileUploadWithDataInit() {
        let fixture = UploadRequest.init(apiClient: egnyteClient, data: Data.init(bytes: [1, 2, 3]), uploadFilepath: "Test/Testfile.txt", completion: { _ in })
        
        XCTAssert(fixture.data == Data.init(bytes: [1,2,3]))
        XCTAssert(fixture.request.value(forHTTPHeaderField: "Content-Type") == "application/octet-stream")
        XCTAssert(fixture.request.value(forHTTPHeaderField: "Content-Disposition") == "form-data; name=\"file\"; filename=\"Test/Testfile.txt\"")
        XCTAssert(fixture.request.httpMethod == "POST")
        XCTAssert(fixture.request.url!.absoluteString == "\(TEST_DOMAIN)/pubapi/v1/fs-content/Test/Testfile.txt")
    }
    
    func testFileUploadFromDiskInit() {
        let fixture = FileUploadFromDiskRequest.init(apiClient: egnyteClient,
                                                     fileURL: URL.init(string: "https://test.com")!,
                                                     uploadFilepath: "Test/Testfile.txt",
                                                     completion: { _ in })
        
        XCTAssert(fixture.request.value(forHTTPHeaderField: "Content-Type") == "application/octet-stream")
        XCTAssert(fixture.request.value(forHTTPHeaderField: "Content-Disposition") == "form-data; name=\"file\"; filename=\"Test/Testfile.txt\"")
        XCTAssert(fixture.request.httpMethod == "POST")
        XCTAssert(fixture.request.url!.absoluteString == "\(TEST_DOMAIN)/pubapi/v1/fs-content/Test/Testfile.txt")
    }
    
    func testChunkFileUploadInit() {
        let fixture = ChunkedUploadRequest.init(apiClient: egnyteClient,
                                                data: Data.init(),
                                                uploadFilepath: "Test/Testfile.txt",
                                                chunkNumber: 2 ,
                                                lastChunk: true,
                                                uploadId: "testUploadId",
                                                lastModified: nil,
                                                checksum: "testCheckSum",
                                                progressHandler: nil){ _ in }
        
        XCTAssert(fixture.request.value(forHTTPHeaderField: "Content-Type") == "application/octet-stream")
        XCTAssert(fixture.request.value(forHTTPHeaderField: "Last-Modified") == nil)
        XCTAssert(fixture.request.value(forHTTPHeaderField: "X-Sha512-Checksum") == "testchecksum")
        XCTAssert(fixture.request.value(forHTTPHeaderField: "X-Egnyte-Upload-Id") == "testUploadId")
        XCTAssert(fixture.request.value(forHTTPHeaderField: "X-Egnyte-Last-Chunk") == "true")

        XCTAssert(fixture.request.httpMethod == "POST")
        XCTAssert(fixture.request.url!.absoluteString == "\(TEST_DOMAIN)/pubapi/v1/fs-content-chunked/Test/Testfile.txt")
    }

}
