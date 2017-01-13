//
//  ListFolderContentRequestBuilder.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 03.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation

/// Builder for ListFolderContentRequest
public class ListFolderContentRequestBuilder {
    /// EgnyteAPIClient which performs and authorize request.
    weak var apiClient: EgnyteAPIClient?
    /// Path to folder.
    let path: String
    /// Completion with closure returning EgnyteFolder or thorwing EgnyteError.
    let completion: (ListFolderContentResponse) -> Void
    /// The maximum number of items to return.
    public var count: Int?
    /// The zero-based index from which to start returning items.
    public var offset: Int?
    /// Boolean value indicating whether response contains information about allowed link types.
    public var allowedLinkTypes: Bool?
    /// Value describing how to sort results.
    public var sortBy: String?
    /// The custom metadata field to sort by.
    public var key: String?
    /// The direction of the sort.
    public var sortDirection: String?
    /// Boolean value indicating whether response contains information about current user's permission level on the folder and subfolders.
    public var userPermissions: Bool?
    /// Boolean value indicating whether response contains information about different users and groups who have permissions along with their permission level.
    public var includePermissions: Bool?
    /// Boolean value indicating whether response contains file custom metadata.
    public var listCustomMetadata: Bool?
    
    /// Initialize ListFolderContentRequestBuilder with required parameters.
    ///
    /// - Parameters:
    ///   - apiClient: EgnyteAPIClient which performs and authorize request
    ///   - path: Path to folder.
    ///   - completion: Completion with closure returning EgnyteFolder or thorwing EgnyteError.
    public init(apiClient: EgnyteAPIClient, path: String, completion:@escaping (ListFolderContentResponse) -> Void) {
        self.apiClient = apiClient
        self.path = path
        self.completion = completion
    }
    
    /// Builds ListFolderContentRequest with previoslu setted parameters.
    ///
    /// - Returns: ListFolderContentRequest
    public func buildListFileOrFolderRequest() -> ListFolderContentRequest {
        return ListFolderContentRequest.init(apiClient: apiClient!,
                                            path: path,
                                            count: count,
                                            offset: offset,
                                            allowedLinkTypes: allowedLinkTypes,
                                            sortBy: sortBy,
                                            key: key,
                                            sortDirection: sortDirection,
                                            userPermissions: userPermissions,
                                            includePermissions: includePermissions,
                                            listCustomMetadata: listCustomMetadata,
                                            completion: completion)
    }
}
