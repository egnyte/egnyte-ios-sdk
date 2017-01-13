//
//  EgnyteSearchEntity.swift
//  EgnyteSDK
//
//  Created by MP0091 on 21.11.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

/// Represents data returned from file and folder search.
@objc public protocol EgnyteSearchedEntity: class {
    /// Name of searched entity.
    var name: String {get}
    /// Path of searched entity.
    var path: String {get}
}

/// Represents search result of file.
@objc public class EgnyteSearchedFile: NSObject, EgnyteSearchedEntity {
    /// Name of searched file.
    public let name: String
    /// Date of last searched file version modification as Unix timestamp.
    public let lastModified: TimeInterval
    /// Path of searched file.
    public let path: String
    /// Custom metadata of the searched file.
    public let customMetadata: [String: Any]?
    /// Size of the searched file in bytes.
    public let size: Int
    /// A plain text snippet of the text containing the matched content.
    public let snippet: String
    /// Version identifier of the searched file.
    public let entryId: String
    /// Identifier of all searched file versions.
    public let groupId: String
    /// Uploader of the searched file.
    public let uploadedBy: String
    /// Number of the searched flie versions.
    public let versionsCount: Int
    
    public init(name: String,
                lastModified: TimeInterval,
                path: String,
                customMetadata: [String: Any]?,
                size: Int,
                snippet: String,
                entryId: String,
                groupId: String,
                uploadedBy: String,
                versionsCount: Int) {
        self.name = name
        self.lastModified = lastModified
        self.path = path
        self.customMetadata = customMetadata
        self.size = size
        self.snippet = snippet
        self.entryId = entryId
        self.groupId = groupId
        self.uploadedBy = uploadedBy
        self.versionsCount = versionsCount
    }

}

/// Represents search result of folder.
@objc public class EgnyteSearchedFolder: NSObject, EgnyteSearchedEntity {
    /// Name of searched folder.
    public let name: String
    /// Path of searched folder.
    public let path: String
    
    public init(name: String, path: String) {
        self.name = name
        self.path = path
    }
}

public extension EgnyteSearchedFile {
    
    convenience init(json: [String: Any]) throws {
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        guard let name = json["name"] as? String,
            let lastModified = json["last_modified"] as? String,
            let path = json["path"] as? String,
            let size = json["size"] as? Int,
            let snippet = json["snippet"] as? String,
            let entryId = json["entry_id"] as? String,
            let groupId = json["group_id"] as? String,
            let uploadedBy = json["uploaded_by"] as? String,
            let versionsCount = json["num_versions"] as? Int
            else {
                throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponse", comment: "invalid response"))
        }
        
        guard let date = dateFormatter.date(from: lastModified) else {
            throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponseDateFormat", comment: "invalid date format in response"))
        }
        
        let timestamp = date.timeIntervalSince1970
        let customMetadata = json["custom_properties"] as? [String: Any]
        
        self.init(name:name,
                  lastModified: timestamp,
                  path: path,
                  customMetadata: customMetadata,
                  size: size,
                  snippet: snippet,
                  entryId: entryId,
                  groupId: groupId,
                  uploadedBy: uploadedBy,
                  versionsCount: versionsCount)
    }
}

public extension EgnyteSearchedFolder {
    
    convenience init(json: [String: Any]) throws {
        guard let name = json["name"] as? String,
            let path = json["path"] as? String
            else {
                throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponse", comment: "invalid response"))
        }
    
        self.init(name:name,
                  path: path)
    }
}
