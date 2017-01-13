//
//  RequestErrorHandler.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 27.10.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation

@objc public protocol RequestErrorHandler {
    func handleResponse(data: Data?, response: URLResponse?, error: Error?) throws -> Void
}
