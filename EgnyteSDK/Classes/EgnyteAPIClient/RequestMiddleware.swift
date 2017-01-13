//
//  RequestMiddleware.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 28.10.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation

/// Implement this protocol to alter network requests in EgnyteAPIClient.
@objc public protocol RequestMiddleware {
    func processRequest(_ request:URLRequest) -> URLRequest
}
