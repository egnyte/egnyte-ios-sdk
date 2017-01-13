//
//  ListFolderContentRequestBuilderTests.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 07.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import XCTest
@testable import EgnyteSDK

class ListFolderContentRequestBuilderTests: XCTestCase {
    
    func testBuilderAllParams() {
        let apiClient = EgnyteAPIClient.init(domainURL: URL.init(string: "https://test.com")!,
                                             token: "testToken")
        
        let builder = ListFolderContentRequestBuilder.init(apiClient: apiClient,
                                                           path: "test/path/to/folder") { result in

        }
        
        builder.allowedLinkTypes = true
        builder.count = 10
        builder.offset = 100
        builder.includePermissions = false
        builder.key = "testKey"
        builder.sortBy = "name"
        builder.sortDirection = "ascending"
        builder.listCustomMetadata = true

        let request = builder.buildListFileOrFolderRequest()
        XCTAssert(request.request.url?.absoluteString == "https://test.com/pubapi/v1/fs/test/path/to/folder?sort_by=name&list_content=true&offset=100&allowed_link_types=true&include_perm=false&perms=false&list_custom_metadata=true&count=10&sort_direction=ascending&key=testKey")
        
    }

    
    func testBuilderMinimumParams() {
        let apiClient = EgnyteAPIClient.init(domainURL: URL.init(string: "https://test.com")!,
                                             token: "testToken")
        
        let builder = ListFolderContentRequestBuilder.init(apiClient: apiClient,
                                                           path: "test/path/to/folder") { result in
                                                            
        }
        
        let request = builder.buildListFileOrFolderRequest()

        XCTAssert(request.request.url?.absoluteString == "https://test.com/pubapi/v1/fs/test/path/to/folder?offset=0&list_content=true&include_perm=false&allowed_link_types=false&list_custom_metadata=false&perms=false&count=0")
        
    }
    
}
