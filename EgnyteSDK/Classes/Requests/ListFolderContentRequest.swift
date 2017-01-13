//
//  ListFolderContentRequest.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 04.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation

/// Represents response on ListFolderContentRequest.
@objc public class FolderContentResponse: NSObject {
    /// Listed folder.
    public let parentFolder: EgnyteFolder
    /// Subfolders of listed folder.
    public let folders: [EgnyteFolder]
    /// Files contained in listed folder.
    public let files: [EgnyteFile]
    /// Request parameter. The maximum number of items to return.
    public let count: Int
    /// Request parameter. The 0-based index from which items where returned.
    public let offset: Int
    /// Number of files and folder contained in listed folder.
    public let totalCount: Int
    /// Boolean value indicating whether folder restricts move/delete operations.
    public let restrictsMoveDelete: Bool
    /// Allowed public links types.
    public let publicLinks: String
    
    public init(parentFolder: EgnyteFolder,
                folders: [EgnyteFolder],
                files: [EgnyteFile],
                count: Int,
                offset: Int,
                totalCount: Int,
                restrictsMoveDelete: Bool,
                publicLinks: String) {
        self.parentFolder = parentFolder
        self.folders = folders
        self.files = files
        self.count = count
        self.offset = offset
        self.totalCount = totalCount
        self.restrictsMoveDelete = restrictsMoveDelete
        self.publicLinks = publicLinks
    }
}

public extension FolderContentResponse {
    convenience init(json: [String: Any]) throws {
        guard let isFolder = json["is_folder"] as? Bool, isFolder == true else {
            throw ListFolderError.WrongQuery(descritpion: NSLocalizedString("kExpectedFolderError", comment: "Expected folder"))
        }
        
        guard let parentFolder = try? EgnyteFolder.init(json: json),
            let count = json["count"] as? Int,
            let offset = json["offset"] as? Int,
            let totalCount = json["total_count"] as? Int,
            let restrictsMoveDelete = json["restrict_move_delete"] as? Bool,
            let publicLinks = json["public_links"] as? String
            else {
                throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponse", comment: "invalid response"))
        }
        
        var tmpFolders = [EgnyteFolder]()
        if let foldersJSON = json["folders"] as? [[String: Any]] {
            for data in foldersJSON {
                if let f = try? EgnyteFolder.init(json: data){
                    tmpFolders.append(f)
                }
            }
        }
        
        var tmpFiles = [EgnyteFile]()
        if let filesJSON = json["files"] as? [[String: Any]] {
            for data in filesJSON {
                if let f = try? EgnyteFile.init(json: data){
                    tmpFiles.append(f)
                }
            }
        }
        
        self.init(parentFolder: parentFolder,
                  folders: tmpFolders,
                  files: tmpFiles,
                  count: count,
                  offset: offset,
                  totalCount: totalCount,
                  restrictsMoveDelete: restrictsMoveDelete,
                  publicLinks: publicLinks)
    }
}
public typealias ListFolderContentResponse = () throws -> FolderContentResponse

/// Request for listing folder content.
public class ListFolderContentRequest: EgnyteBaseRequest {
    
    /// Initialize ListFolderContentRequest.
    ///
    /// - Parameters:
    ///   - apiClient: EgnyteAPIClient which performs and authorize request.
    ///   - path: Path to folder.
    ///   - count: The maximum number of items to return.
    ///   - offset: The zero-based index from which to start returning items.
    ///   - allowedLinkTypes: Boolean value indicating whether response contains information about allowed link types.
    ///   - sortBy: Value describing how to sort results.
    ///   - key: The custom metadata field to sort by.
    ///   - sortDirection: The direction of the sort.
    ///   - userPermissions: Boolean value indicating whether response contains information about current user's permission level on the folder and subfolders.
    ///   - includePermissions: Boolean value indicating whether response contains information about different users and groups who have permissions along with their permission level.
    ///   - listCustomMetadata: Boolean value indicating whether response contains file custom metadata.
    ///   - completion: Completion with closure returning EgnyteFolder or thorwing EgnyteError.
    public init(apiClient: EgnyteAPIClient,
                path: String,
                count: Int?,
                offset: Int?,
                allowedLinkTypes: Bool?,
                sortBy: String?,
                key: String?,
                sortDirection: String?,
                userPermissions: Bool?,
                includePermissions: Bool?,
                listCustomMetadata: Bool?,
                completion: @escaping (@escaping ListFolderContentResponse) -> Void)  {
        
        var parameters = [String: Any]()
        parameters["list_content"] = "true"
        parameters["count"] =  String(describing: count ?? 0)
        parameters["offset"] = String(describing: offset ?? 0)
        parameters["allowed_link_types"] = (allowedLinkTypes ?? false) ? "true" : "false"
        parameters["sort_by"] = sortBy
        parameters["key"] = key
        parameters["sort_direction"] = sortDirection
        parameters["perms"] = (userPermissions ?? false) ? "true" : "false"
        parameters["include_perm"] = (includePermissions ?? false) ? "true" : "false"
        parameters["list_custom_metadata"] = (listCustomMetadata ?? false) ? "true" : "false"
        
        try! super.init(apiClient: apiClient,
                        endpoint: "pubapi/v1/fs",
                        filepath: path,
                        method: "GET",
                        parameters: parameters,
                        errorHandler: nil) { result in
                            do {
                                let data = try result()
                                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                                let contentResponse = try ListFolderContentRequest.parse(data: json)
                                completion({return contentResponse})
                            }catch let error {
                                completion({throw error})
                            }
        }
    }
    
    public convenience init(apiClient: EgnyteAPIClient,
                            path: String,
                            completion: @escaping (ListFolderContentResponse) -> Void)  {
        
        self.init(apiClient: apiClient,
                  path: path,
                  count: nil,
                  offset: nil,
                  allowedLinkTypes: nil,
                  sortBy: nil,
                  key: nil,
                  sortDirection: nil,
                  userPermissions: nil,
                  includePermissions: nil,
                  listCustomMetadata: nil,
                  completion: completion)
    }
    
    static func parse(data: Any?) throws -> FolderContentResponse {
        guard let json = data as? [String: Any] else {
            throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponse", comment: "invalid response"))
        }
        
        return try FolderContentResponse.init(json: json)
    }
}
