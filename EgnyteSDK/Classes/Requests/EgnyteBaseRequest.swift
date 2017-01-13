//
//  EgnyteBaseRequest.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 27.10.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation

public typealias EgnyteResponse = () throws -> Data?

/// Represents requests that can be process by EgnyteAPIClient.
@objc protocol EgnyteRequest : class, Cancellable {
    func execute() -> Void
    func enqueue() -> Void
    func cancel() -> Void
}

/// Represents cancellable tasks.
@objc public protocol Cancellable: class  {
    func cancel() -> Void
}

/// Basic HTTPS request. Use it to perform tasks which do not have dedicated requests.
@objc public class EgnyteBaseRequest: NSObject, EgnyteRequest {
    /// URL session task created by EgnyteBaseRequest.
    var task: URLSessionTask?
    /// URL request of EgnyteBaseRequest.
    let request: URLRequest
    /// Error handler processing response.
    let errorRequestHandler: RequestErrorHandler
    /// Completion block with closure returning Data or throwing an error.
    let completion: (@escaping EgnyteResponse) -> Void
    /// EgnyteAPIClient which performs and authorize request.
    weak var apiClient: EgnyteAPIClient?
    
    /// Initialize EgnyteBaseRequest.
    ///
    /// - Parameters:
    ///   - apiClient: EgnyteAPIClient which performs and authorize request.
    ///   - endpoint: API endpoint.
    ///   - filepath: Path of file on which actions will be performed.
    ///   - method: HTTP method.
    ///   - parameters: Parameters of request.
    ///   - middleware: Use it to modify request, if you need to modify each request then use middleware in apiClient.
    ///   - errorHandler: Custom error handler.
    ///   - completion: Completion block with closure returning Data or throwing an error.
    /// - Throws: invalidQueryParameters or invalidJSONparameters if value passed in parameters parameter is invalid.
    public init(apiClient: EgnyteAPIClient,
                endpoint: String,
                filepath: String?,
                method: String,
                parameters: [String: Any]?,
                middleware: ((URLRequest) -> URLRequest)? = nil,
                errorHandler: RequestErrorHandler? = nil,
                completion: @escaping (@escaping EgnyteResponse) -> Void) throws {
        
        self.apiClient = apiClient
        var request = try EgnyteBaseRequest.requestWith(baseURL: apiClient.baseURL,
                                                        endpoint: endpoint,
                                                        filepath: filepath,
                                                        parameters: parameters,
                                                        method: method)
        
        request = apiClient.applyMiddlewareOperationsTo(request: request)
        if let middleware = middleware {
            request = middleware(request)
        }
        self.request = request
        self.errorRequestHandler = errorHandler ?? EgnyteBaseRequestErrorHandler.init()
        self.completion = completion
    }
    
    /// Enqueues request to be performed.
    public func enqueue() {
        self.apiClient?.enqueue(egnyteRequest: self)
    }
    
    /// Cancels request execution or removes it from requests queue.
    public func cancel() {
        self.task?.cancel()
        self.apiClient?.cancel(egnyteRequest: self)
    }
    
    func execute() {
        self.task = createTask()
        self.task?.resume()
    }
    
    func createTask() -> URLSessionTask? {
        
       return self.apiClient?.session.dataTask(with: request, completionHandler: { (data, response, error) in
            do {
                try self.errorRequestHandler.handleResponse(data: data, response: response, error: error)
            } catch  EgnyteError.developerOverQPS(let retryAfter) {
                self.apiClient?.retry(egnyteRequest: self, after: retryAfter)
                return
            } catch let error {
                self.apiClient?.callbackQueue.addOperation {
                    self.completion({throw error})
                }
                return
            }
            
            self.apiClient?.callbackQueue.addOperation {
                self.completion({ () -> Data? in
                    return data
                })
            }
        })
    }
    
    static func requestWith(baseURL: URL, endpoint: String, filepath: String?, parameters: [String: Any]?, method: String) throws -> URLRequest {
        var url = baseURL.appendingPathComponent(endpoint)
        if let filepath = filepath {
            url.appendPathComponent(filepath)
        }
        
        var result = URLRequest.init(url: url)
        result.httpMethod = method
        
        switch method {
        case "POST":
            result = try addJSON(parameters: parameters, request: result)
        default:
            result = try addQuery(parameters: parameters, request: result)
        }
        
        return result
    }
    
    static func addQuery(parameters:[String: Any]?, request: URLRequest) throws -> URLRequest {
        var result = request
        guard let params = parameters as? [String: String]? else {
            throw EgnyteError.invalidQueryParameters
        }
        
        if let params = params {
            var pathComponents = URLComponents.init(url: request.url!, resolvingAgainstBaseURL: false)
            pathComponents?.queryItems = []
            for (key, value) in params {
                pathComponents?.queryItems?.append(URLQueryItem.init(name: key, value: value))
            }
            result.url = pathComponents?.url
        }
        
        return result
    }
    
    static func addJSON(parameters:[String: Any]?, request: URLRequest) throws -> URLRequest {
        var result = request
        if let params = parameters {
            guard  JSONSerialization.isValidJSONObject(params) else {
                throw EgnyteError.invalidJSONparameters
            }
            let data = try JSONSerialization.data(withJSONObject: params, options: [])
            result.httpBody = data
        }
        
        if result.httpBody != nil {
            result.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return result
    }
}
