//
//  AuthResponse.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 18.10.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

@objc public class AuthResponse: NSObject {
    /// Token returned by server, use it to authorize your API calls.
    public let token: String
    /// Egnyte domain url associated with returned token.
    public let egnyteDomainURL: URL
    
    init(token: String, egnyteDomainURL: URL) {
        self.token = token
        self.egnyteDomainURL = egnyteDomainURL
    }
}
