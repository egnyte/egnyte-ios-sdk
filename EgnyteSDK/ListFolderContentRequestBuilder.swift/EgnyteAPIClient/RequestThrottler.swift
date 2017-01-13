//
//  RequestThrottler.swift
//  EgnyteSDK
//
//  Created by MP0091 on 28.10.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

class RequestThrottler {
    let queriesPerSecond: Double?
    var waitingQueue = [EgnyteRequest]()
    var retrydWaitingQueue = [EgnyteRequest]()
    let queueLock = NSObject()
    var timer: Timer?
    
    required init(queriesPerSecond: Double?) {
        self.queriesPerSecond = queriesPerSecond
    }
    
    @objc func executeNextRequest() {
        
        self.nextRequest()?.execute()
        self.invalidateTimerIfNeeded()
    }
    
    func invalidateTimerIfNeeded() {
        objc_sync_enter(self.queueLock)
        
        if self.waitingQueue.count == 0 && self.retrydWaitingQueue.count == 0 {
            self.timer?.invalidate()
            self.timer = nil
        }
        objc_sync_exit(self.queueLock)
    }
    
    func nextRequest() -> EgnyteRequest? {
        
        var result: EgnyteRequest?
        objc_sync_enter(self.queueLock)
        
        if self.retrydWaitingQueue.count > 0 {
            result = self.retrydWaitingQueue.removeFirst()
        } else if self.waitingQueue.count > 0 {
            result = self.waitingQueue.removeFirst()
        }
        objc_sync_exit(self.queueLock)

        return result
    }
    
    func setTimerWith(timeInterval: Double) {
        self.timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                target: self,
                                selector: #selector(executeNextRequest),
                                userInfo: nil,
                                repeats: true)
        
    }
    
    
    func retry(egnyteRequest: EgnyteRequest, after: TimeInterval) {
        self.enqueueOn(queue: &self.retrydWaitingQueue, egnyteRequest: egnyteRequest)
    }
    
    func enqueue(egnyteRequest: EgnyteRequest)  {
        self.enqueueOn(queue: &self.waitingQueue, egnyteRequest: egnyteRequest)
    }
    
    func enqueueOn(queue: inout [EgnyteRequest], egnyteRequest: EgnyteRequest) {
        if let qps = self.queriesPerSecond {
            objc_sync_enter(self.queueLock)
            queue.append(egnyteRequest)
            if self.timer == nil {
                self.setTimerWith(timeInterval: 1.0/qps)
            }
            objc_sync_exit(self.queueLock)
        } else{
            egnyteRequest.execute()
        }

    }
    
    func cancel(egnyteRequest: EgnyteRequest) {
        objc_sync_enter(self.queueLock)
        self.waitingQueue = self.waitingQueue.filter({$0 !== egnyteRequest})
        self.retrydWaitingQueue = self.retrydWaitingQueue.filter({$0 !== egnyteRequest})
        objc_sync_exit(self.queueLock)
    }
}
