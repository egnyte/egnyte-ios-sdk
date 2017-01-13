//
//  FileMetadataRequest.swift
//  EgnyteSDK
//
//  Created by MP0091 on 22.11.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

/// Request for file metadata
@objc public class EgnyteFileMetadataRequest: EgnyteBaseRequest {
    
    /// Initialize FileMetadataRequest.
    ///
    /// - Parameters:
    ///   - apiClient: EgnyteAPIClient which performs and authorize request.
    ///   - path: path to file.
    ///   - listVersions: A Boolean value indicating whether response contains file versions metadata.
    ///   - listCustomMetadata: A Boolean value indicating whether response contains file custom metadata.
    ///   - completion: Completion with closure returning EgnyteFolder or thorwing EgnyteError or ListError.
    ///
    /// - Warning: Do not use it to get file metadata. Completion will throw ListFolderError.
    public init(apiClient: EgnyteAPIClient,
                path: String,
                listVersions: Bool?,
                listCustomMetadata: Bool?,
                completion: @escaping (@escaping () throws -> EgnyteFile) -> Void)  {
        
        var parameters = [String: Any]()
        parameters["list_content"] = (listVersions ?? false) ? "true" : "false"
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
                                let entity = try FileMetadataRequest.parse(data: json)
                                completion({return entity})
                            }catch let error {
                                completion({throw error})
                            }
        }
    }
    
    public convenience init(apiClient: EgnyteAPIClient,
                            path: String,
                            completion: @escaping (@escaping () throws -> EgnyteFile) -> Void)  {
        
        self.init(apiClient: apiClient,
                  path: path,
                  listVersions: nil,
                  listCustomMetadata: nil,
                  completion: completion)
    }
    
    static func parse(data: Any?) throws -> EgnyteFile {
        guard let json = data as? [String: Any] else {
            throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponse", comment: "invalid response"))
        }
        
        guard let isFolder = json["is_folder"] as? Bool, isFolder == false else {
            throw ListFolderError.WrongQuery(descritpion: NSLocalizedString("kExpectedFileError", comment: "Expected file"))
        }
        
        return try EgnyteFile.init(json: json)
    }
}
