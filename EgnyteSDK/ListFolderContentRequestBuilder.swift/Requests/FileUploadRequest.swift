//
//  UploadRequest.swift
//  EgnyteSDK
//
//  Created by MP0091 on 14.11.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

@objc protocol EgnyteUploadRequest: EgnyteRequest, UploadProgressTracking {
    var errorRequestHandler: RequestErrorHandler {get}
    var apiClient: EgnyteAPIClient? {get}
    var task: URLSessionTask? {set get}
    func handleResponse(data: Data?, response: URLResponse?, error: Error?)
    func createTask() -> URLSessionTask?
}

extension EgnyteUploadRequest {
    
    func parse(data: Data?, response: HTTPURLResponse) throws -> EgnyteUploadResponse {
        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        
        guard let dataDictionary = json as? [String: Any] else {
            throw EgnyteError.unexpectedResponse(description:NSLocalizedString("kInvalidResponse", comment: "invalid response"))
        }
        guard let checksum = dataDictionary["checksum"] as? String,
            let groupId = dataDictionary["group_id"] as? String,
            let entryId = dataDictionary["entry_id"] as? String,
            let lastModifiedString = response.allHeaderFields["Last-Modified"] as? String
            else {
                throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponse", comment: "invalid response"))
        }
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale.init(identifier: "en_US")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        
        guard let lastModified = dateFormatter.date(from: lastModifiedString) else {
            throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponseDateFormat", comment: "invalid date format in response"))
        }
        
        return EgnyteUploadResponse.init(checksum: checksum,
                                         entryId: entryId,
                                         groupId: groupId,
                                         lastModified: lastModified.timeIntervalSince1970)
    }
    
}

/// Request for upload file from Data. To upload it directly from file use FileUploadFromDiskRequest.
public class FileUploadRequest: EgnyteUploadRequest {
    /// URL session task created by UploadRequest.
    var task: URLSessionTask?
    /// URL request of UploadRequest.
    let request: URLRequest
    /// Data to upload.
    let data: Data
    /// Object responsible for tracking dowbload progress.
    var progressObserver: ValueObserver?
    /// Closure called whenever progress value changes.
    let progressHandler: ((Progress) -> Void)?
    /// Error handler processing response.
    let errorRequestHandler = EgnyteBaseRequestErrorHandler.init() as RequestErrorHandler
    /// Completion block with closure returning EgnyteUploadResponse or throwing an error.
    let completion: (@escaping () throws -> EgnyteUploadResponse) -> Void
    /// EgnyteAPIClient which performs and authorize request.
    weak var apiClient: EgnyteAPIClient?
    
    /// Initialize UploadRequest.
    ///
    /// - Parameters:
    ///   - apiClient: EgnyteAPIClient which performs and authorize request.
    ///   - data: Data to upload.
    ///   - uploadFilepath: Upload file destination.
    ///   - lastModified: Last modification date metadata.
    ///   - checksum: Checksum of data to upload.
    ///   - progressHandler: Closure called whenever progress value changes.
    ///   - middleware: Use it to modify request, if you need to modify each request then use middleware in apiClient.
    ///   - completion: Completion block with closure returning EgnyteUploadResponse or throwing an error.
    public init(apiClient: EgnyteAPIClient,
                data: Data,
                uploadFilepath: String,
                lastModified: String? = nil,
                checksum: String? = nil,
                progressHandler: ((Progress) -> Void)? = nil,
                middleware: ((URLRequest) -> URLRequest)? = nil,
                completion: @escaping (@escaping () throws -> EgnyteUploadResponse) -> Void) {
        
        self.apiClient = apiClient
        let url = apiClient.baseURL.appendingPathComponent("/pubapi/v1/fs-content/").appendingPathComponent(uploadFilepath)
        var request = URLRequest.init(url: url)
        request = apiClient.applyMiddlewareOperationsTo(request: request)
        request.setValue("form-data; name=\"file\"; filename=\"\(uploadFilepath)\"", forHTTPHeaderField: "Content-Disposition")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(lastModified, forHTTPHeaderField: "Last-Modified")
        request.setValue(checksum?.lowercased(), forHTTPHeaderField: "X-Sha512-Checksum")
        request.httpMethod = "POST"
        if let middleware = middleware {
            request = middleware(request)
        }
        self.request = request
        self.completion = completion
        self.data = data
        self.progressHandler = progressHandler
    }
    
    func createTask() -> URLSessionTask? {
        let task = self.apiClient?.session.uploadTask(with: self.request, from: self.data, completionHandler: { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error)
        })
        return task
    }
    
    func handleResponse(data: Data?, response: URLResponse?, error: Error?) {
        do {
            try self.errorRequestHandler.handleResponse(data: data, response: response, error: error)
            
        } catch EgnyteError.developerOverQPS(let retryAfter) {
            self.apiClient?.retry(egnyteRequest: self, after: retryAfter)
            
        } catch let error {
            self.apiClient?.callbackQueue.addOperation {
                self.completion({throw error})
            }
            return
        }
        
        apiClient?.callbackQueue.addOperation {
            self.completion({
                return try self.parse(data: data, response: response as! HTTPURLResponse) })
        }
    }
    
    /// Enqueues request to be performed.
    public func enqueue() {
        self.apiClient?.enqueue(egnyteRequest: self)
    }
    
    /// Cancels request execution or removes it from requests queue.
    public func cancel() {
        self.task?.cancel()
        self.progressObserver = nil
        self.apiClient?.cancel(egnyteRequest: self)
    }
    
    func execute() {
        self.task = createTask()
        self.trackProgress(task: self.task!)
        self.task!.resume()
    }

}

/// Request for upload file from file on disk. To upload it from data use UploadRequest.
public class FileUploadFromDiskRequest: EgnyteUploadRequest {
    /// URL session task created by FileUploadFromDiskRequest.
    var task: URLSessionTask?
    /// URL request of FileUploadFromDiskRequest.
    let request: URLRequest
    /// URL of file to upload.
    let fileURL: URL
    /// Object responsible for tracking dowbload progress.
    var progressObserver: ValueObserver?
    /// Closure called whenever progress value changes.
    let progressHandler: ((Progress) -> Void)?
    /// Error handler processing response.
    let errorRequestHandler = EgnyteBaseRequestErrorHandler.init() as RequestErrorHandler
    /// Completion block with closure returning EgnyteUploadResponse or throwing an error.
    let completion: (@escaping () throws -> EgnyteUploadResponse) -> Void
    /// EgnyteAPIClient which performs and authorize request.
    weak var apiClient: EgnyteAPIClient?
    
    /// Initialize FileUploadFromDiskRequest.
    ///
    /// - Parameters:
    ///   - apiClient: EgnyteAPIClient which performs and authorize request.
    ///   - fileURL: URL of file to upload.
    ///   - uploadFilepath: Upload file destination.
    ///   - lastModified: Last modification date metadata.
    ///   - checksum: Checksum of data to upload.
    ///   - progressHandler: Closure called whenever progress value changes.
    ///   - middleware: Use it to modify request, if you need to modify each request then use middleware in apiClient.
    ///   - completion: Completion block with closure returning EgnyteUploadResponse or throwing an error.
    public init(apiClient: EgnyteAPIClient,
                fileURL: URL,
                uploadFilepath: String,
                lastModified: String? = nil,
                checksum: String? = nil,
                progressHandler: ((Progress) -> Void)? = nil,
                middleware: ((URLRequest) -> URLRequest)? = nil,
                completion: @escaping (@escaping () throws -> EgnyteUploadResponse) -> Void) {
        
        self.apiClient = apiClient
        let url = apiClient.baseURL.appendingPathComponent("/pubapi/v1/fs-content/").appendingPathComponent(uploadFilepath)
        var request = URLRequest.init(url: url)
        request = apiClient.applyMiddlewareOperationsTo(request: request)
        request.setValue("form-data; name=\"file\"; filename=\"\(uploadFilepath)\"", forHTTPHeaderField: "Content-Disposition")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(lastModified, forHTTPHeaderField: "Last-Modified")
        request.setValue(checksum?.lowercased(), forHTTPHeaderField: "X-Sha512-Checksum")
        request.httpMethod = "POST"
        if let middleware = middleware {
            request = middleware(request)
        }
        self.request = request
        self.fileURL = fileURL
        self.completion = completion
        self.progressHandler = progressHandler
    }
    
    func createTask() -> URLSessionTask? {
        let task = self.apiClient?.session.uploadTask(with: self.request, fromFile: self.fileURL, completionHandler: { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error)
        })
        return task
    }
    
    func handleResponse(data: Data?, response: URLResponse?, error: Error?) {
        do {
            try self.errorRequestHandler.handleResponse(data: data, response: response, error: error)
            
        } catch EgnyteError.developerOverQPS(let retryAfter) {
            self.apiClient?.retry(egnyteRequest: self, after: retryAfter)
            
        } catch let error {
            self.apiClient?.callbackQueue.addOperation {
                self.completion({throw error})
            }
            return
        }
        
        apiClient?.callbackQueue.addOperation {
            self.completion({
                return try self.parse(data: data, response: response as! HTTPURLResponse) })
        }
    }

    /// Enqueues request to be performed.
    public func enqueue() {
        self.apiClient?.enqueue(egnyteRequest: self)
    }
    
    /// Cancels request execution or removes it from requests queue.
    public func cancel() {
        self.task?.cancel()
        self.progressObserver = nil
        self.apiClient?.cancel(egnyteRequest: self)
    }
    
    func execute() {
        self.task = createTask()
        self.trackProgress(task: self.task!)
        self.task!.resume()
    }

}

