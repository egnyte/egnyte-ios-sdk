//
//  DeleteRequest.swift
//  EgnyteSDK
//
//  Created by MP0091 on 15.11.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

/// Request for deleting file or folder.
@objc public class EgnyteDeleteRequest: EgnyteBaseRequest {
    
    /// Initialize DeleteRequest.
    ///
    /// - Parameters:
    ///   - apiClient: EgnyteAPIClient which performs and authorize request.
    ///   - path: Path of file or folder to delete.
    ///   - completion: Completion block with closure returning boolean value indicating success or throwing an error.
    public init(apiClient: EgnyteAPIClient,
                path: String,
                completion: @escaping (@escaping () throws -> Bool) -> Void) {
        try! super.init(apiClient: apiClient, endpoint: "/pubapi/v1/fs/", filepath: path, method: "DELETE", parameters: nil, errorHandler: nil, completion: { result in
            do{
                _ = try result()
                completion({return true})
            }catch let error {
                completion({throw error})
            }
        })
    }
}
