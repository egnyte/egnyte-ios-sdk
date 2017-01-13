//
//  SearchResponse.swift
//  EgnyteSDK
//
//  Created by MP0091 on 18.11.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

/// Represents response of search request
@objc public class SearchResponse: NSObject {
    /// The number of results returned.
    public let count: UInt
    /// The 0-based index of the first result in the current set of results.
    public let offset: UInt
    /// Array of searched entities
    public let results: [EgnyteSearchedEntity]
    /// States if there are more results to fetch.
    public let hasMore: Bool
    /// Total count of results.
    public let totalCount: UInt
    
    public init(count: UInt, offset: UInt, results: [EgnyteSearchedEntity], hasMore: Bool, totalCount: UInt) {
        self.count = count
        self.offset = offset
        self.results = results
        self.hasMore = hasMore
        self.totalCount = totalCount
    }
}

public extension SearchResponse {
    
    public convenience init(json:[String: Any]) throws {
        guard let count = json["count"] as? UInt,
            let offset = json["offset"] as? UInt,
            let resultsData = json["results"] as? [[String: Any]],
            let hasMore = json["hasMore"] as? Bool,
            let totalCount = json["total_count"] as? UInt else {
                
                throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponse", comment: "invalid response"))
        }
        
        var results = [EgnyteSearchedEntity]()
        
        for entityData in resultsData {
            if entityData["is_folder"] as? Bool == true{
                results.append(try EgnyteSearchedFolder.init(json: entityData))
            }else {
                results.append(try EgnyteSearchedFile.init(json: entityData))
            }
        }
        
        self.init(count: count,
                  offset: offset,
                  results: results,
                  hasMore: hasMore,
                  totalCount: totalCount)
    }
}
