//
//  EgnyteErrors.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 07.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation

public enum EgnyteError: CustomNSError, LocalizedError{
    case httpError(code:Int, description: String)
    case unexpectedResponse (description:String)
    case invalidJSONparameters
    case invalidQueryParameters
    case developerOverRate (retryAfter: Double)
    case developerOverQPS (retryAfter: Double)
    
    public static var errorDomain: String { return "EgnyteError"}
    public var errorCode: Int {
        switch self {
        case .httpError(let code, _) : return code
        case .unexpectedResponse(_): return -1
        case .invalidJSONparameters: return -2
        case .invalidQueryParameters: return -3
        case .developerOverRate: return -4
        case .developerOverQPS: return -5
        }
    }
    
    public var errorUserInfo: [String : Any]  {
        return [NSLocalizedDescriptionKey : self.errorDescription!]
    }
    
    public var errorDescription: String? {
        switch self {
        case .httpError(_, let description):
            return description
        case .unexpectedResponse(let description):
            return description
        case .invalidJSONparameters:
            return NSLocalizedString("kInvalidJSONparameters", comment: "One or more parameters passed to request are not valid json parameters")
        case .invalidQueryParameters:
            return NSLocalizedString("kInvalidQueryparameters", comment: "One or more parameters passed to request are not valid query parameters. Key and value should be strings")
        case .developerOverRate (let retryAfter):
            return String(format: NSLocalizedString("kDeveloperOverRate", comment: "Exceeded daily quota"), retryAfter)
        case .developerOverQPS (let retryAfter):
            return String(format: NSLocalizedString("kDeveloperOverQPS", comment: "Exceeded per second throttle"), retryAfter)
        }
    }
}

public enum ListFolderError: CustomNSError, LocalizedError {
    case WrongQuery(descritpion: String)
    
    
    public static var errorDomain: String { return "EgnyteEntityRequestError"}
    
    public var errorCode: Int {
        return -1
    }
    
    public var errorUserInfo: [String : Any]  {
        return [NSLocalizedDescriptionKey : self.errorDescription!]
    }
    
    public var errorDescription: String? {
        switch self {
        case .WrongQuery(let description):
            return description
        }
    }
}
