//
//  CreateFolderRequest.swift
//  EgnyteSDK
//
//  Created by MP0091 on 07.11.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

/// Request for creating new folder.
@objc public class CreateFolderRequest: EgnyteBaseRequest {
    
   /// Initialize CreateFolderRequest
   ///
   /// - Parameters:
   ///   - apiClient: EgnyteAPIClient which performs and authorize request.
   ///   - path: Path containig new folder.
   ///   - completion: Completion with closure returning a boolean value or thorwing EgnyteError.
   public init(apiClient: EgnyteAPIClient,
               path: String,
               completion: @escaping (@escaping () throws -> Bool) -> Void) {
        try! super.init(apiClient: apiClient,
                        endpoint: "pubapi/v1/fs",
                        filepath: path,
                        method: "POST",
                        parameters: ["action": "add_folder"],
                        errorHandler: nil) { result in
                            
                            do{
                                _ = try result()
                                completion({return true})
                            }catch let error {
                                completion({throw error})
                            }
        }
    }
}
