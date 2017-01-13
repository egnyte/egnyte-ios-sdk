//
//  ChunkedUploadRequest.swift
//  EgnyteSDK
//
//  Created by MP0091 on 17.11.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

/// Request for chunk upload. The chunked upload flow provides a mechanism to upload large files.  Though not a firmly enforced requirement, we recommend using this flow for files larger than 100 MB. To upload files of smaller sizes, you can use the simpler upload flow - UploadRequest.
///
///Chunked Upload process:

///1. Split file into chunks—recommended size is 104857600 bytes (100 MB) each.  The minimum chunk size is 10485760 (10 MB). The maximum chunk size is 1073741824 bytes (1GB).  All chunks should be the same size, except for the last chunk which can be any size.
///
///2. Start the process by uploading the first chunk. Save the **uploadId** received in the response. Use the **checksum** hash in the response to confirm that each chunk was uploaded cleanly.
///
///3. Upload the rest of the chunks except the final one in any order. Use the *uploadId* identifier and **chunkNumber** sequence numbers to uniquely identify each chunk. Upload chunks in parallel to get maximum throughput.
///
///4. When uploading the final chunk, indicate this by setting **lastChunk** to *true*.
///
///5. Chunks remain available for a period of 24 hours after the first chunk is uploaded.
@objc public class ChunkedUploadRequest: NSObject, EgnyteRequest, UploadProgressTracking {
    /// URL session task created by FileUploadFromDiskRequest.
    var task: URLSessionTask?
    /// URL request of FileUploadFromDiskRequest.
    let request: URLRequest
    /// Data chunk to upload.
    let data: Data
    /// Object responsible for tracking dowbload progress.
    var progressObserver: ValueObserver?
    /// Closure called whenever progress value changes.
    let progressHandler: ((Progress) -> Void)?
    /// Error handler processing response.
    let errorRequestHandler = EgnyteBaseRequestErrorHandler.init() as RequestErrorHandler
    /// Completion block with closure returning ChunkedUploadResponse or throwing an error.
    let completion: (@escaping () throws -> ChunkedUploadResponse) -> Void
    /// EgnyteAPIClient which performs and authorize request.
    weak var apiClient: EgnyteAPIClient?
    
    /// Initialize ChunkedUploadRequest.
    ///
    /// - Parameters:
    ///   - apiClient: EgnyteAPIClient which performs and authorize request.
    ///   - data: Data chunk to upload.
    ///   - uploadFilepath: Destination path of file to upload.
    ///   - chunkNumber: Number of chunk.
    ///   - lastChunk: A Boolean value indicating whether it is last chunk.
    ///   - uploadId: Identifier of chunked upload.
    ///   - lastModified: Last modification date metadata.
    ///   - checksum: Checksum of data to upload.
    ///   - progressHandler: Closure called whenever progress value changes.
    ///   - middleware: Use it to modify request, if you need to modify each request then use middleware in apiClient.
    ///   - completion: Completion block with closure returning ChunkedUploadResponse or throwing an error.
    public init(apiClient: EgnyteAPIClient,
                data: Data,
                uploadFilepath: String,
                chunkNumber: UInt,
                lastChunk: Bool = false,
                uploadId: String? = nil,
                lastModified: String? = nil,
                checksum: String? = nil,
                progressHandler: ((Progress) -> Void)? = nil,
                middleware: ((URLRequest) -> URLRequest)? = nil,
                completion: @escaping (@escaping () throws -> ChunkedUploadResponse) -> Void) {
        
        assert(chunkNumber == 1 || (chunkNumber > 1 && uploadId != nil))
        self.apiClient = apiClient
        var request = URLRequest.init(url: apiClient.baseURL.appendingPathComponent("/pubapi/v1/fs-content-chunked/").appendingPathComponent(uploadFilepath))
        request = apiClient.applyMiddlewareOperationsTo(request: request)
        request.setValue("form-data; name=\"file\"; filename=\"\(uploadFilepath)\"", forHTTPHeaderField: "Content-Disposition")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(lastModified, forHTTPHeaderField: "Last-Modified")
        request.setValue(checksum?.lowercased(), forHTTPHeaderField: "X-Sha512-Checksum")
        request.setValue(uploadId, forHTTPHeaderField: "X-Egnyte-Upload-Id")
        request.setValue(String(chunkNumber), forHTTPHeaderField: "X-Egnyte-Chunk-Num")
        if lastChunk {
            request.setValue("true", forHTTPHeaderField: "X-Egnyte-Last-Chunk")
        }
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
            
            self.apiClient?.callbackQueue.addOperation {
                self.completion({
                    return ChunkedUploadRequest.parse(response: response as! HTTPURLResponse)
                })
            }
        })
        return task
    }
    
    static func parse(response: HTTPURLResponse) -> ChunkedUploadResponse {
        let uploadId = response.allHeaderFields["X-Egnyte-Upload-Id"] as? String
        let chunkNumberString = response.allHeaderFields["X-Egnyte-Chunk-Num"] as? String
        let checksum = response.allHeaderFields["X-Egnyte-Chunk-Sha512-Checksum"] as! String
        var chunkNumber: UInt?
        
        if let chunkNumberString = chunkNumberString {
            chunkNumber = UInt(chunkNumberString)
        }
        
        return ChunkedUploadResponse.init(uploadId: uploadId, chunkNumber:chunkNumber, checksum: checksum)
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
