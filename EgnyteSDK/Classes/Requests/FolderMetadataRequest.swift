//
//  FolderMetadataRequest.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 03.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation

/// Request for folder metadata.
@objc public class FolderMetadataRequest: EgnyteBaseRequest {
    
    /// Initialize FolderMetadataRequest.
    ///
    /// - Parameters:
    ///   - apiClient: EgnyteAPIClient which performs and authorize request.
    ///   - path: path to folder.
    ///   - allowedLinkTypes: Boolean value indicating whether response contains information about allowed link types.
    ///   - userPermissions: Boolean value indicating whether response contains information about current user's permission level on the folder and subfolders.
    ///   - includePermissions: Boolean value indicating whether response contains information about different users and groups who have permissions along with their permission level.
    ///   - listCustomMetadata: Boolean value indicating whether response contains custom metadata.
    ///   - completion: Completion with closure returning EgnyteFolder or thorwing EgnyteError or ListFolderError.
    ///
    /// - Warning: Do not use it to get file metadata. Completion will throw ListFolderError.
    public init(apiClient: EgnyteAPIClient,
         path: String,
         allowedLinkTypes: Bool?,
         userPermissions: Bool?,
         includePermissions: Bool?,
         listCustomMetadata: Bool?,
         completion: @escaping (@escaping () throws -> EgnyteFolder) -> Void)  {
        
        var parameters = [String: Any]()
        parameters["list_content"] = "false"
        parameters["allowed_link_types"] = (allowedLinkTypes ?? false) ? "true" : "false"
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
                                let item = try FolderMetadataRequest.parse(data: json)
                                completion({return item})
                            }catch let error {
                                completion({throw error})
                            }
        }
    }
    
    public convenience init(apiClient: EgnyteAPIClient,
                            path: String,
                            completion: @escaping (() throws -> EgnyteFolder) -> Void)  {
        
        self.init(apiClient: apiClient,
                  path: path,
                  allowedLinkTypes: nil,
                  userPermissions: nil,
                  includePermissions: nil,
                  listCustomMetadata: nil,
                  completion: completion)
    }
    
    static func parse(data: Any?) throws -> EgnyteFolder {
        guard let json = data as? [String: Any] else {
            throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponse", comment: "invalid response"))
        }
        
        guard let isFolder = json["is_folder"] as? Bool, isFolder == true else {
            throw ListFolderError.WrongQuery(descritpion: NSLocalizedString("kExpectedFolderError", comment: "Expected folder"))
        }
    
        return try EgnyteFolder.init(json: json)
    }
}



