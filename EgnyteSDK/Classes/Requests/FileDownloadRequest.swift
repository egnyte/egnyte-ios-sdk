//
//  FileDownloadRequest.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 08.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation

/// Request for downloading file to memory. Use FileDownloadToDiskRequest if you want to save it directly to disk.
@objc public class FileDownloadRequest: NSObject, EgnyteRequest, DownloadProgressTracking {
    /// URL session task created by FileDownloadRequest.
    var task: URLSessionTask?
    /// URL request of FileDownloadRequest.
    let request: URLRequest
    /// Object responsible for tracking dowbload progress.
    var progressObserver: ValueObserver?
    /// Closure called whenever progress value changes.
    let progressHandler: ((Progress) -> Void)?
    /// Error handler processing response.
    let errorRequestHandler = EgnyteBaseRequestErrorHandler.init()
    /// Completion block with closure returning Data or throwing an error.
    let completion: (@escaping () throws -> Data?) -> Void
    /// EgnyteAPIClient which performs and authorize request.
    weak var apiClient: EgnyteAPIClient?
    
    /// Initialize FileDownloadRequest.
    ///
    /// - Parameters:
    ///   - apiClient: EgnyteAPIClient which performs and authorize request.
    ///   - filepath: Path to file to be downloaded.
    ///   - versionEntryId: Identifier of file version to be downloaded. If nil, then newest vesrion will be downloaded.
    ///   - progressHandler: Closure called whenever progress value changes.
    ///   - middleware: Use it to modify request, if you need to modify each request then use middleware in apiClient.
    ///   - completion: Completion block with closure returning Data or throwing an error.
    public init(apiClient: EgnyteAPIClient,
                filepath: String,
                versionEntryId: String? = nil,
                progressHandler: ((Progress) -> Void)? = nil,
                middleware: ((URLRequest) -> URLRequest)? = nil,
                completion: @escaping (@escaping () throws -> Data?) -> Void) {
        
        self.apiClient = apiClient
        let url =  apiClient.baseURL.appendingPathComponent("/pubapi/v1/fs-content").appendingPathComponent(filepath)
        var request = URLRequest.init(url: url)
        request.httpMethod = "GET"
        request.setValue(versionEntryId, forHTTPHeaderField: "entry_id")
        if let middleware = middleware {
            request = middleware(request)
        }
        self.request = apiClient.applyMiddlewareOperationsTo(request: request)
        self.completion = completion
        self.progressHandler = progressHandler
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
    
    func createTask() -> URLSessionTask? {
        let task = self.apiClient?.session.downloadTask(with: request, completionHandler: { (location, response, error) in
            var data: Data?
            do {
                try self.errorRequestHandler.handleResponse(data: nil, response: response, error: error)
                if let location = location {
                    data = try Data.init(contentsOf: location)
                }
                
            } catch EgnyteError.developerOverQPS(let retryAfter) {
                self.apiClient?.retry(egnyteRequest: self, after: retryAfter)
                
            } catch let error {
                self.apiClient?.callbackQueue.addOperation {
                    self.completion({throw error})
                }
                return
            }
            
            self.apiClient?.callbackQueue.addOperation {
                self.completion({return data})
            }
        })
        
        return task
    }
}

/// Request for downloading file and writting it to disk. Use FileDownloadRequest if you want to keep file in memory without writting it to disk.
@objc public class FileDownloadToDiskRequest: NSObject, EgnyteRequest, DownloadProgressTracking {
    /// URL session task created by FileDownloadRequest.
    var task: URLSessionTask?
    /// URL request of FileDownloadRequest.
    let request: URLRequest
    /// File manager used to wirte file to disk.
    let fileManager: FileManager
    /// URL where downloaded file should be written to.
    let destinationURL: URL
    /// Object responsible for tracking dowbload progress.
    var progressObserver: ValueObserver?
    /// Closure called whenever progress value changes.
    let progressHandler: ((Progress) -> Void)?
    /// Error handler processing response.
    let errorRequestHandler = EgnyteBaseRequestErrorHandler.init()
    /// Completion block with closure returning URL where file was written or throwing an error.
    let completion: (@escaping () throws -> URL) -> Void
    /// EgnyteAPIClient which performs and authorize request.
    weak var apiClient: EgnyteAPIClient?
    
    /// Initialize FileDownloadToDiskRequest.
    ///
    /// - Parameters:
    ///   - apiClient: EgnyteAPIClient which performs and authorize request.
    ///   - filepath: Path to file to be downloaded.
    ///   - destinationURL: URL where downloaded file should be written to.
    ///   - versionEntryId: Identifier of file version to be downloaded. If nil, then newest vesrion will be downloaded.
    ///   - fileManager: File manager used to wirte file to disk. If nil, default NSFileManager is used.
    ///   - progressHandler: Closure called whenever progress value changes.
    ///   - middleware: Use it to modify request, if you need to modify each request then use middleware in apiClient.
    ///   - completion: Completion block with closure returning URL to saved file or throwing an error.
    public init(apiClient: EgnyteAPIClient,
                filepath: String,
                destinationURL: URL,
                versionEntryId: String?,
                fileManager: FileManager?,
                progressHandler: ((Progress) -> Void)? = nil,
                middleware: ((URLRequest) -> URLRequest)? = nil,
                completion: @escaping (@escaping () throws -> URL) -> Void) {
        
        self.apiClient = apiClient
        self.fileManager = fileManager ?? FileManager.default
        self.destinationURL = destinationURL
        let url = apiClient.baseURL.appendingPathComponent("/pubapi/v1/fs-content/").appendingPathComponent(filepath)
        var request = URLRequest.init(url: url)
        request.httpMethod = "GET"
        request.setValue(versionEntryId, forHTTPHeaderField: "entry_id")
        if let middleware = middleware {
            request = middleware(request)
        }
        self.request = apiClient.applyMiddlewareOperationsTo(request: request)
        self.completion = completion
        self.progressHandler = progressHandler
    }
    
    /// Initialize default FileDownloadToDiskRequest.
    ///
    /// - Parameters:
    ///   - apiClient: EgnyteAPIClient which performs and authorize request.
    ///   - filepath: Path to file to be downloaded.
    ///   - destinationURL: URL where downloaded file should be written to.
    ///   - completion: Completion block with closure returning URL to saved file or throwing an error.
    public convenience init(apiClient: EgnyteAPIClient,
                            filepath: String,
                            destinationURL: URL,
                            completion: @escaping (() throws -> URL) -> Void) {
        self.init(apiClient: apiClient,
                  filepath: filepath,
                  destinationURL: destinationURL,
                  versionEntryId: nil,
                  fileManager: nil,
                  completion: completion)
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
        self.task?.resume()
    }
    
    func createTask() -> URLSessionTask? {
        return self.apiClient?.session.downloadTask(with: request, completionHandler: { (location, response, error) in
            do {
                try self.errorRequestHandler.handleResponse(data: nil, response: response, error: error)
                if let location = location {
                    try self.fileManager.moveItem(at: location, to: self.destinationURL)
                }
                
            } catch EgnyteError.developerOverQPS(let retryAfter) {
                self.apiClient?.retry(egnyteRequest: self, after: retryAfter)
                
            } catch let error {
                self.apiClient?.callbackQueue.addOperation {
                    self.completion({throw error})
                }
                return
            }
            
            let result = self.destinationURL
            self.apiClient?.callbackQueue.addOperation {
                self.completion({return result })
            }
        })
    }
}

