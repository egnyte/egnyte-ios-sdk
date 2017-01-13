//
//  LinkExpiry.swift
//  EgnyteSDK
//
//  Created by MP0091 on 22.11.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

@objc public enum LinkExpiryType: Int {
    case date
    case clicks
}

@objc public protocol LinkExpiry {
    var type: LinkExpiryType {get}
}

/// Represents date after which link is expired.
@objc public class LinkDateExpiry: NSObject, LinkExpiry {
    public let type = LinkExpiryType.date
    public let date: Date
    
    /// Initialize LinkDateExpiry
    ///
    /// - Parameter date: Date after link is expired.
    public init(date: Date) {
        self.date = date
    }
}

/// Represents number of clicks after which link is expired. Value of the clicks must be between 1 and 10, inclusive.
@objc public class LinkClicksExpiry: NSObject, LinkExpiry {
    public let type = LinkExpiryType.clicks
    public let clicks: UInt
    
    /// Initialize LinkClicksExpiry
    ///
    /// - Parameter date: Number of clicks after which link is expired. Value of the clicks must be between 1 and 10, inclusive.
    public init(clicks: UInt) {
        self.clicks = clicks
    }
}
