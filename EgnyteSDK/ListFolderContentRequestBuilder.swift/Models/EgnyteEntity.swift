//
//  EgnyteEntity.swift
//  EgnyteSDK
//
//  Created by MP0091 on 03.11.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

/// Represents data returned from file and folder listing.
@objc public protocol EgnyteEntity   {
    /// Name of the entity.
    var name: String {get}
    /// Date of last entity modification as Unix timestamp.
    var lastModified: TimeInterval {get}
    /// Path of the entity.
    var path: String {get}
    /// Custom metadata of the entity.
    var customMetadata: [String : Any]? {get}
}

/// Represents Egnyte file.
@objc public class EgnyteFile:NSObject, EgnyteEntity {
    /// Name of the file.
    public let name: String
    /// Date of last file modification as Unix timestamp.
    public let lastModified: TimeInterval
    /// Path of the file.
    public let path: String
    /// Custom metadata of the file.
    public let customMetadata: [String: Any]?
    /// Checksum of the file.
    public let checksum: String
    /// Size of the file in bytes.
    public let size: UInt
    /// Describes if file is locked for modificaiton.
    public let locked: Bool
    /// Version identifier of the file.
    public let entryId: String
    /// Identifier of all file versions.
    public let groupId: String
    /// Uploader of the file.
    public let uploadedBy: String
    /// Number of the flie versions.
    public let versionsCount: Int
    /// Versions of the file.
    public let versions: [EgnyteFileVersion]?
    
    public init(name: String,
         lastModified: TimeInterval,
         path: String,
         customMetadata: [String: Any]?,
         checksum: String,
         size: UInt,
         locked: Bool,
         entryId: String,
         groupId: String,
         uploadedBy: String,
         versionsCount: Int,
         versions: [EgnyteFileVersion]?) {
        self.name = name
        self.lastModified = lastModified
        self.path = path
        self.customMetadata = customMetadata
        self.checksum = checksum
        self.size = size
        self.locked = locked
        self.entryId = entryId
        self.groupId = groupId
        self.uploadedBy = uploadedBy
        self.versionsCount = versionsCount
        self.versions = versions
    }
}

/// Represents version of Egnyte file.
@objc public class EgnyteFileVersion: NSObject {
    /// Checksum of the file version.
    public let checksum: String
    /// Size of the file version in bytes.
    public let size: UInt
    /// Identifier of the file versions.
    public let entryId: String
    /// Date of last file version modification as Unix timestamp.
    public let lastModified: TimeInterval
    /// Uploader of the file version.
    public let uploadedBy: String
    
    public init(checksum: String, size: UInt, entryId: String, lastModified: TimeInterval, uploadedBy: String) {
        self.checksum = checksum
        self.size = size
        self.entryId = entryId
        self.lastModified = lastModified
        self.uploadedBy = uploadedBy
    }
}

/// Represents Egnyte folder.
@objc public class EgnyteFolder: NSObject, EgnyteEntity {
    /// Name of the folder.
    public let name: String
    /// Date of last folder modification as Unix timestamp.
    public let lastModified: TimeInterval
    /// Path of folder.
    public let path: String
    /// Custom metadata of folder.
    public let customMetadata: [String: Any]?
    /// Identifier of the folder.
    public let id: String
    /// Describes the current user's permission level on the folder and subfolders
    public let permission: String?
    /// Lists the different users and groups who have permissions along with their permission level.
    public let userPermissions: [String: Any]?
    /// Lists allowed file link types.
    public let allowedFileLinkTypes: [String]?
    /// Lists allowed folder link types.
    public let allowedFolderLinkTypes: [String]?
    /// Can user create upload link to folder.
    public let allowUploadLinks: Bool?
    
    public init(name: String,
        lastModified: TimeInterval,
        path: String,
        customMetadata: [String: Any]?,
        id: String,
        permission: String?,
        userPermissions: [String: Any]?,
        allowedFileLinkTypes: [String]?,
        allowedFolderLinkTypes: [String]?,
        allowUploadLinks: Bool?) {
        
        self.name = name
        self.lastModified = lastModified
        self.path = path
        self.customMetadata = customMetadata
        self.id = id
        self.permission = permission
        self.userPermissions = userPermissions
        self.allowedFileLinkTypes = allowedFileLinkTypes
        self.allowedFolderLinkTypes = allowedFolderLinkTypes
        self.allowUploadLinks = allowUploadLinks
    }
    

    /// - Returns: Representation of root folder.
    public static func rootFolder() -> EgnyteFolder {
        return  EgnyteFolder.init(name: "/",
                                  lastModified: 0,
                                  path: "/",
                                  customMetadata: nil,
                                  id: "",
                                  permission: nil,
                                  userPermissions: nil,
                                  allowedFileLinkTypes: nil,
                                  allowedFolderLinkTypes: nil,
                                  allowUploadLinks: nil)
    }
}

public extension EgnyteFile {
    
    convenience init(json: [String: Any]) throws {
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale.init(identifier: "en_US")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        
        guard let name = json["name"] as? String,
            let lastModified = json["last_modified"] as? String,
            let path = json["path"] as? String,
            let checksum = json["checksum"] as? String,
            let size = json["size"] as? UInt,
            let locked = json["locked"] as? Bool,
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
        let customMetadata = json["custom_metadata"] as? [String: Any]
        
        var versions: [EgnyteFileVersion]?
        if let versionsData = json["versions"] as? [[String: Any]] {
            versions = []
            for data in versionsData {
                versions!.append(try EgnyteFileVersion.init(json: data))
            }
        }
        
        self.init(name:name,
                  lastModified: timestamp,
                  path: path,
                  customMetadata: customMetadata,
                  checksum: checksum,
                  size: size,
                  locked: locked,
                  entryId: entryId,
                  groupId: groupId,
                  uploadedBy: uploadedBy,
                  versionsCount: versionsCount,
                  versions: versions)
    }
}

public extension EgnyteFileVersion {
    
    convenience init(json: [String: Any]) throws {
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale.init(identifier: "en_US")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        
        guard let lastModified = json["last_modified"] as? String,
            let checksum = json["checksum"] as? String,
            let entryId = json["entry_id"] as? String,
            let size = json["size"] as? UInt,
            let uploadedBy = json["uploaded_by"] as? String
            else {
                throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponse", comment: "invalid response"))
        }
        
        guard let date = dateFormatter.date(from: lastModified) else {
            throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponseDateFormat", comment: "invalid date format in response"))
        }
        
        let timestamp = date.timeIntervalSince1970
        
        self.init(checksum: checksum,
                  size: size,
                  entryId: entryId,
                  lastModified: timestamp,
                  uploadedBy: uploadedBy)
    }
}

public extension EgnyteFolder {
    
    convenience init(json: [String: Any]) throws {
        guard let name = json["name"] as? String,
            let lastModified = json["lastModified"] as? TimeInterval,
            let path = json["path"] as? String,
            let id = json["folder_id"] as? String
            else {
                throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponse", comment: "invalid response"))
        }
        
        let customMetadata = json["custom_metadata"] as? [String: Any]
        let permission = json["permission"] as? String
        let allowedFileLinkTypes = json["allowed_file_link_types"] as? [String]
        let allowedFolderLinkTypes = json["allowed_folder_link_types"] as? [String]
        let allowUploadLinks = json["allow_upload_links"] as? Bool
        let userPermissions = json["permissions"] as? [String: Any]
        
        self.init(name:name,
                  lastModified: lastModified/1000,
                  path: path,
                  customMetadata: customMetadata,
                  id: id,
                  permission: permission,
                  userPermissions: userPermissions,
                  allowedFileLinkTypes: allowedFileLinkTypes,
                  allowedFolderLinkTypes: allowedFolderLinkTypes,
                  allowUploadLinks: allowUploadLinks)
    }
}
