//
//  EgnyteAPIClient.swift
//  EgnyteSDK
//
//  Created by MP0091 on 27.10.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

/// EgnyteAPIClient manage request authentication and throttling.
@objc public class EgnyteAPIClient: NSObject {
    /// Egnyte domain url
    let baseURL: URL
    /// Network session. Default is shared URLSession.
    let session: URLSession
    /// Array of middleware objects used to altering network requests.
    let middleware: [RequestMiddleware]
    /// Callback queue for requests. Default is main operation queue.
    let callbackQueue: OperationQueue
    /// Object used to throttle request according to queries per second value.
    let requestThrottler: RequestThrottler
    
    /// Initialize EgnyteAPIClient.
    ///
    /// - Parameters:
    ///   - domainURL: Egnyte domain url.
    ///   - token: OAuth token.
    ///   - middleware: Custom array of middleware objects used to altering network requests.
    ///   - session: Network session. Default is shared URLSession.
    ///   - callbackQueue: Callback queue for requests. Default is main operation queue.
    ///   - queriesPerSecond: Calls per second value from developer account. Pass nil to disable throttling.
    required public init(domainURL: URL,
                         token: String,
                         middleware: [RequestMiddleware]?,
                         session: URLSession?,
                         callbackQueue: OperationQueue?,
                         queriesPerSecond: Double?) {
        self.baseURL = domainURL
        self.middleware = [EgnyteAuthMiddleware.init(token: token)] + (middleware ?? [])
        self.session = session ?? URLSession.shared
        self.callbackQueue = callbackQueue ?? OperationQueue.main
        self.requestThrottler = RequestThrottler.init(queriesPerSecond: queriesPerSecond)
    }
    
    /// Initialize EgnyteAPIClient in default configuration.
    ///
    /// - Parameters:
    ///   - domainURL: Egnyte domain url.
    ///   - token: OAuth token.
    public convenience init(domainURL: URL, token: String) {
        self.init(domainURL:domainURL,
                  token: token,
                  middleware:nil,
                  session: nil,
                  callbackQueue: nil,
                  queriesPerSecond: nil)
    }
    
    func applyMiddlewareOperationsTo(request: URLRequest) -> URLRequest {
        var result = request
        for reqMiddleware in self.middleware {
            result = reqMiddleware.processRequest(result)
        }
        return result
    }
    
    func retry(egnyteRequest: EgnyteRequest, after: TimeInterval) {
        self.requestThrottler.retry(egnyteRequest: egnyteRequest, after: after)
    }
    
    func enqueue(egnyteRequest: EgnyteRequest) {
        self.requestThrottler.enqueue(egnyteRequest: egnyteRequest)
    }
    
    func cancel(egnyteRequest: EgnyteRequest) {
        self.requestThrottler.cancel(egnyteRequest: egnyteRequest)
    }
}
