//
//  EgnyteBaseRequestErrorHandler.swift
//  EgnyteSDK
//
//  Created by MP0091 on 27.10.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

@objc class EgnyteBaseRequestErrorHandler: NSObject, RequestErrorHandler {
    
    func handleResponse(data: Data?, response: URLResponse?, error: Error?) throws {
        
        guard let httpResponse = response as? HTTPURLResponse else {
            if error != nil {
                throw error!
            }
            
            throw EgnyteError.unexpectedResponse(description: self.errorDescriptionFrom(data: data)
                ?? NSLocalizedString("kUnexpectedResponse",
                                     comment: "Unexpected response from server"))
        }
        
        try self.checkForQPSerror(response: httpResponse)
        
        guard httpResponse.statusCode >= 200,
            httpResponse.statusCode < 300 else {
                throw EgnyteError.httpError(code: httpResponse.statusCode,
                                            description: self.errorDescriptionFrom(data: data) ?? httpResponse.description)
        }
        
        guard error == nil else {
            throw error!
        }
    }
    
    func checkForQPSerror(response: HTTPURLResponse) throws {
        if response.statusCode == 403,
            let errorDesc = response.allHeaderFields["X-Mashery-Error-Code"] as? String,
            let retryAfter = response.allHeaderFields["Retry-After"] as? String {
            
            if errorDesc == "ERR_403_DEVELOPER_OVER_QPS" {
                throw EgnyteError.developerOverQPS(retryAfter: Double(retryAfter)!)
            } else {
                throw EgnyteError.developerOverRate(retryAfter: Double(retryAfter)!)
            }
        }
    }
    
    func errorDescriptionFrom(data: Data?) -> String? {
        guard let dataToSerialize = data else {
            return nil
        }
        
        let serializedData = try? JSONSerialization.jsonObject(with: dataToSerialize, options:.allowFragments)
        
        guard let parsableData = serializedData as? [String : AnyObject] else {
            return nil
        }
        
        if let msg = parsableData["message"] as? String {
            return msg
        }
        
        return parsableData["errorMessage"] as? String
    }
    
}
