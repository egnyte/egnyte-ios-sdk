//
//  RequestErrorHandler.swift
//  EgnyteSDK
//
//  Created by MP0091 on 27.10.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

@objc public protocol EgnyteRequestErrorHandler {
    func handleResponse(data: Data?, response: URLResponse?, error: Error?) throws -> Void
}
