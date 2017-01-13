//
//  AuthRequest.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 17.10.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

///By default, any OAuth token you create will be permitted to access all available Egnyte APIs. You should restrict a given token to a subset of APIs by passing the scope parameter in the token request call. For example, in order to restrict a token to only be able to call the File System API, pass the parameter *Scope.fileSystem*.
@objc public enum Scope: Int {
    /// File system scope
    case fileSystem
    /// User management scope
    case user
    /// Group management scope
    case group
    /// Audit reporting scope
    case audit
    /// Links scope
    case link
    /// Permissions scope
    case permission
    /// Bookmarks scope
    case bookmark
    
    public func toString() -> String {
        switch self {
        case .fileSystem:
            return "Egnyte.filesystem"
        case .user:
            return "Egnyte.user"
        case .group:
            return "Egnyte.group"
        case .audit:
            return "Egnyte.audit"
        case .link:
            return "Egnyte.link"
        case .permission:
            return "Egnyte.permission"
        case .bookmark:
            return "Egnyte.bookmark"
        }
    }
}

/// Represents region where your services are available.
@objc public enum Region: Int {
    case us
    case eu
}

/// Object containig necessary data to perform auth.
@objc public class AuthRequest: NSObject {
    /// The API key that was provided to you when you registered your application.
    let clientID: String
    /// The secret key that was provided with your key to you when you registered your application. If your application key was requested prior to January 2015, please register for a new key to get one with a client secret.
    let clientSecret: String
    /// Egnyte domain url.
    let egnyteDomainURL: URL?
    /// Services region.
    let region: Region?
    /// Scope restricts a token to a subset of APIs. By default, any OAuth token you create will be permitted to access all available Egnyte APIs. You should restrict a given token to a subset of APIs.
    let scope: [Scope]?
    /// As described in the OAuth 2.0 spec, this optional parameter is an opaque value used by the client to maintain state between the request and callback. The authorization server includes this value when redirecting the user-agent back to the client. The parameter can be used for preventing cross-site request forgery and passing the Egnyte domain as part of the response from the authorization server.
    let state: String
    
    /// Initialize AuthRequest.
    ///
    /// - Parameters:
    ///   - clientID: The API key that was provided to you when you registered your application.
    ///   - clientSecret: The secret key that was provided with your key to you when you registered your application. If your application key was requested prior to January 2015, please register for a new key to get one with a client secret.
    ///   - egnyteDomainURL: Egnyte domain url.
    ///   - scope: Scope restricts a token to a subset of APIs. By default, any OAuth token you create will be permitted to access all available Egnyte APIs. You should restrict a given token to a subset of APIs.
    ///   - state: As described in the OAuth 2.0 spec, this optional parameter is an opaque value used by the client to maintain state between the request and callback. The authorization server includes this value when redirecting the user-agent back to the client. The parameter can be used for preventing cross-site request forgery and passing the Egnyte domain as part of the response from the authorization server.
    public init(clientID: String, clientSecret: String, egnyteDomainURL: URL, scope: [Scope]?, state: String?) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.egnyteDomainURL = egnyteDomainURL
        self.region = nil;
        self.scope = scope
        self.state = state ?? AuthRequest.randomAlphaNumericState(160)
        super.init()
    }
    
    /// Initialize AuthRequest.
    ///
    /// - Parameters:
    ///   - clientID: The API key that was provided to you when you registered your application.
    ///   - clientSecret: The secret key that was provided with your key to you when you registered your application. If your application key was requested prior to January 2015, please register for a new key to get one with a client secret.
    ///   - region: Services region. If you do not know where your services are placed you may specify any as it is used for optimization purpose.
    ///   - scope: Scope restricts a token to a subset of APIs. By default, any OAuth token you create will be permitted to access all available Egnyte APIs. You should restrict a given token to a subset of APIs.
    ///   - state: As described in the OAuth 2.0 spec, this optional parameter is an opaque value used by the client to maintain state between the request and callback. The authorization server includes this value when redirecting the user-agent back to the client. The parameter can be used for preventing cross-site request forgery and passing the Egnyte domain as part of the response from the authorization server.
    public init(clientID: String, clientSecret: String, region: Region, scope: [Scope]?, state: String?) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.egnyteDomainURL = nil;
        self.region = region
        self.scope = scope
        self.state = state ?? AuthRequest.randomAlphaNumericState(160)
        super.init()
    }
    
    /// Initialize AuthRequest.
    ///
    /// - Parameters:
    ///   - clientID: The API key that was provided to you when you registered your application.
    ///   - clientSecret: The secret key that was provided with your key to you when you registered your application. If your application key was requested prior to January 2015, please register for a new key to get one with a client secret.
    public convenience init(clientID:String, clientSecret: String) {
        self.init(clientID: clientID, clientSecret: clientSecret, region: Region.us, scope: nil, state: nil)
    }
    
    /// Initialize AuthRequest.
    ///
    /// - Parameters:
    ///   - clientID: The API key that was provided to you when you registered your application.
    ///   - clientSecret: The secret key that was provided with your key to you when you registered your application. If your application key was requested prior to January 2015, please register for a new key to get one with a client secret.
    /// Egnyte domain url.
    public convenience init(clientID:String, clientSecret: String, egnyteDomainURL:URL) {
         self.init(clientID: clientID, clientSecret:clientSecret, egnyteDomainURL: egnyteDomainURL, scope: nil, state: nil)
    }
    
    static func randomAlphaNumericState(_ bytes: Int) -> String {
        
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        while randomString.utf8.count * 8 < bytes {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
}
