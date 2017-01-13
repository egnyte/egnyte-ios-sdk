//
//  RequestMiddleware.swift
//  EgnyteSDK
//
//  Created by MP0091 on 28.10.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

/// Implement this protocol to alter network requests in EgnyteAPIClient.
@objc public protocol RequestMiddleware {
    func processRequest(_ request:URLRequest) -> URLRequest
}
