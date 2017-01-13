//
//  EgnyteAuthMiddleware.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 28.10.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation

@objc class EgnyteAuthMiddleware: NSObject, RequestMiddleware {
    let token: String
    
    required init(token: String) {
        self.token = token
    }
    
    func processRequest(_ request: URLRequest) -> URLRequest {
        var result = request
        result.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        return result;
    }
}
