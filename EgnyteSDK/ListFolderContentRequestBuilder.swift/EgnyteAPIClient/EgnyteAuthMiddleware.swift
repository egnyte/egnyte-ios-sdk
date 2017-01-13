//
//  EgnyteAuthMiddleware.swift
//  EgnyteSDK
//
//  Created by MP0091 on 28.10.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
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
