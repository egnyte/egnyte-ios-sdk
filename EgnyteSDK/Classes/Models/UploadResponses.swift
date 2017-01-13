//
//  UploadResponses.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 18.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation

///Represents chunked upload response.
@objc public class ChunkedUploadResponse: NSObject {
    /// Upload identifier returned after first chunk is uploaded.
    public let uploadId: String?
    /// Upload identifier returned after chunk is uploaded. Not returned after last chunk is uploaded.
    public let chunkNumber: UInt?
    /// Checksum of the uploaded chunk.
    public let checksum: String
    
    init(uploadId: String?, chunkNumber: UInt?, checksum: String) {
        self.uploadId = uploadId
        self.chunkNumber = chunkNumber
        self.checksum = checksum
    }
}

///Represents upload response.
@objc public class EgnyteUploadResponse: NSObject {
    /// Checksum of the uploaded file.
    public let checksum: String
    /// Identifier of the uploaded file.
    public let entryId: String
    /// Identifier of all versions of the uploaded file
    public let groupId: String
    /// Date of last file version as Unix timestamp.
    public let lastModified: TimeInterval
    
    init(checksum: String, entryId: String, groupId: String, lastModified: TimeInterval) {
        self.checksum = checksum
        self.entryId = entryId
        self.groupId = groupId
        self.lastModified = lastModified
    }
}

