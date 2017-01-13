//
//  SearchRequest.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 18.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation

/// Represents which item types should be searched.
@objc public enum SearchType: Int {
    case file
    case folder
    
    public func toString() -> String {
        switch self {
        case .file:
            return "FILE"
        case .folder:
            return "FOLDER"
        }
    }

}
/// Request for searching files or folders. The Search API allows you to find content stored in Egnyte based on filenames, metadata, and text content. Searches are performed in the context of the user token being passed. Accordingly, a user will only see results for contents they have permission to access.
@objc public class SearchRequest: EgnyteBaseRequest {
    
    /// Initialize SearchRequest
    ///
    /// - Parameters:
    ///   - apiClient: EgnyteAPIClient which performs and authorize request.
    ///   - query: The search string you want to find. Must contain at lest 3 characters.
    ///   - offset: The 0-based index of the initial record being requested.
    ///   - count: The maximum number of returned results.
    ///   - searchInFolderAtPath: Limit the result set to only items contained in the specified folder.
    ///   - modifiedBefore: Limit to results before the specified ISO-8601 timestamp.
    ///   - modifiedAfter: Limit to results after the specified ISO-8601 timestamp.
    ///   - type: Which item types should be searched. Can be "FILE" or "FOLDER".
    ///   - completion: Completion block with closure returning SearchResponse or throwing an error.
    public init(apiClient: EgnyteAPIClient,
                query: String,
                offset: UInt? = nil,
                count: UInt? = nil,
                searchInFolderAtPath: String? = nil,
                modifiedBefore: Date? = nil,
                modifiedAfter: Date? = nil,
                type: SearchType? = nil,
                completion: @escaping(@escaping () throws -> SearchResponse) -> Void) {
        
        var params = ["query": query]
        params["folder"] = searchInFolderAtPath
        params["type"] = type?.toString()
        
        if let offset = offset {
            params["offset"] = String(describing: offset)
        }
        if let count = count {
            params["count"] = String(describing: count)
        }
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        if let modifiedBefore = modifiedBefore {
            params["modified_before"] = dateFormatter.string(from: modifiedBefore)
        }
        
        if let modifiedAfter = modifiedAfter {
            params["modified_after"] = dateFormatter.string(from: modifiedAfter)
        }
        
        try! super.init(apiClient: apiClient,
                        endpoint: "/pubapi/v1/search",
                        filepath: nil,
                        method: "GET",
                        parameters: params){ result in
                            do {
                                let data = try result()                                
                                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                                let searchResult = try SearchRequest.parse(data: json)
                                completion({return searchResult})
                            }catch let error {
                                completion({throw error})
                            }
        }
    }
    
    static func parse(data: Any?) throws -> SearchResponse {
        guard let json = data as? [String: Any] else {
            throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponse", comment: "invalid response"))
        }
        
        return try SearchResponse.init(json: json)
    }
    
}
