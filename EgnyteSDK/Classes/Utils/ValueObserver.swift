//
//  ValueObserver.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 10.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation

@objc protocol DownloadProgressTracking : class {
    var progressObserver: ValueObserver? {set get}
    var task: URLSessionTask? {get}
    var progressHandler: ((Progress) -> Void)? {get}
}

extension DownloadProgressTracking {
    func trackProgress(task: URLSessionTask) {
        if self.progressHandler != nil, let task = self.task {
            self.progressObserver = ValueObserver.init(objectToObserve: task,
                                                       path: "countOfBytesReceived",
                                                       newValueHandler: { [weak self] newValue in
                                                        let progress = Progress.init(totalUnitCount: task.countOfBytesExpectedToReceive)
                                                        let completed =  newValue as! NSNumber
                                                        progress.completedUnitCount = completed.int64Value
                                                        OperationQueue.main.addOperation {
                                                            self!.progressHandler?(progress)
                                                        }
                })
        }
    }

}


@objc protocol UploadProgressTracking : class {
    var progressObserver: ValueObserver? {set get}
    var task: URLSessionTask? {get}
    var progressHandler: ((Progress) -> Void)? {get}
}

extension UploadProgressTracking {
    func trackProgress(task: URLSessionTask) {
        if self.progressHandler != nil, let task = self.task {
            self.progressObserver = ValueObserver.init(objectToObserve: task,
                                                       path: "countOfBytesSent",
                                                       newValueHandler: { [weak self] newValue in
                                                        let progress = Progress.init(totalUnitCount: self!.task!.countOfBytesExpectedToSend)
                                                        let completed =  newValue as! NSNumber
                                                        progress.completedUnitCount = completed.int64Value
                                                        OperationQueue.main.addOperation {
                                                            self!.progressHandler?(progress)
                                                        }
            })
        }
    }

}

class ValueObserver: NSObject {
    weak var observable: NSObject?
    let newValueHandler: (Any) -> Void
    let observePath: String
    
    init(objectToObserve: NSObject, path: String, newValueHandler:@escaping (Any) -> Void) {
        self.newValueHandler = newValueHandler
        self.observable = objectToObserve
        self.observePath = path
        super.init()
        self.observable!.addObserver(self, forKeyPath: path, options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let newValue = change?[.newKey] {
            self.newValueHandler(newValue)
        }
    }
    
    private func stopObserving() {
        self.observable?.removeObserver(self, forKeyPath: self.observePath)
    }
    
    deinit {
        self.stopObserving()
    }
}
