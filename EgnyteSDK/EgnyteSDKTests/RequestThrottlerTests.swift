//
//  RequestThrottlerTests.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 28.10.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import XCTest
@testable import EgnyteSDK

class RequestMock: EgnyteRequest {
    var didExecute = false
    
    func execute() {
        didExecute = true
    }
    
    func enqueue() {
        
    }
    
    func cancel() {
        
    }
}

class RequestThrottlerTests: XCTestCase {
    

    func testThrottlingWithoutQPS() {
        let fixture = RequestThrottler.init(queriesPerSecond: nil)
        let req1 = RequestMock.init()
        let req2 = RequestMock.init()
        let req3 = RequestMock.init()
        
        fixture.enqueue(egnyteRequest: req1)
        fixture.enqueue(egnyteRequest: req2)
        fixture.enqueue(egnyteRequest: req3)
        
        XCTAssert(req1.didExecute)
        XCTAssert(req2.didExecute)
        XCTAssert(req3.didExecute)
        XCTAssert(fixture.waitingQueue.count == 0)
    }
    
    func testThrottlingWithQPS4_time05() {
        let fixture = RequestThrottler.init(queriesPerSecond: 4)
        let req1 = RequestMock.init()
        let req2 = RequestMock.init()
        let req3 = RequestMock.init()
        
        fixture.enqueue(egnyteRequest: req1)
        fixture.enqueue(egnyteRequest: req2)
        fixture.enqueue(egnyteRequest: req3)
        
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 0.5))
        
        XCTAssert(req1.didExecute)
        XCTAssert(req2.didExecute)
        XCTAssert(req3.didExecute == false)
        XCTAssert(fixture.waitingQueue.count == 1)
    }
    
    
    func testThrottlingWithQPS4_time05_WithInterval() {
        let fixture = RequestThrottler.init(queriesPerSecond: 4)
        let req1 = RequestMock.init()
        let req2 = RequestMock.init()
        let req3 = RequestMock.init()
        let req4 = RequestMock.init()
        
        fixture.enqueue(egnyteRequest: req1)
        fixture.enqueue(egnyteRequest: req2)
        
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 0.5))
        
        fixture.enqueue(egnyteRequest: req3)
        fixture.enqueue(egnyteRequest: req4)
        
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 0.3))
        
        XCTAssert(req1.didExecute)
        XCTAssert(req2.didExecute)
        XCTAssert(req3.didExecute)
        XCTAssert(req4.didExecute == false)
        XCTAssert(fixture.waitingQueue.count == 1)
    }
    
    func testThrottlingWithQPS4_time049() {
        let fixture = RequestThrottler.init(queriesPerSecond: 4)
        let req1 = RequestMock.init()
        let req2 = RequestMock.init()
        let req3 = RequestMock.init()
        
        fixture.enqueue(egnyteRequest: req1)
        fixture.enqueue(egnyteRequest: req2)
        fixture.enqueue(egnyteRequest: req3)
        
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 0.49))
        
        XCTAssert(req1.didExecute)
        XCTAssert(req2.didExecute == false)
        XCTAssert(req3.didExecute == false)
        XCTAssert(fixture.waitingQueue.count == 2)
    }
    
    func testThrottlingCancelling() {
        let fixture = RequestThrottler.init(queriesPerSecond: 4)
        let req1 = RequestMock.init()
        let req2 = RequestMock.init()
        let req3 = RequestMock.init()
        let req4 = RequestMock.init()
        
        fixture.enqueue(egnyteRequest: req1)
        fixture.enqueue(egnyteRequest: req2)
        fixture.cancel(egnyteRequest: req1)
        
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 0.25))
        
        fixture.enqueue(egnyteRequest: req3)
        fixture.enqueue(egnyteRequest: req4)
        fixture.cancel(egnyteRequest: req3)
        fixture.cancel(egnyteRequest: req4)
        
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 0.1))
        
        XCTAssert(req1.didExecute == false)
        XCTAssert(req2.didExecute)
        XCTAssert(req3.didExecute == false)
        XCTAssert(req4.didExecute == false)
        XCTAssert(fixture.waitingQueue.count == 0)
    }
    
    func testThrottlingCancellAll() {
        let fixture = RequestThrottler.init(queriesPerSecond: 4)
        let req1 = RequestMock.init()
        let req2 = RequestMock.init()
        let req3 = RequestMock.init()
        
        fixture.enqueue(egnyteRequest: req1)
        fixture.enqueue(egnyteRequest: req2)
        fixture.enqueue(egnyteRequest: req3)
        
        fixture.cancel(egnyteRequest: req3)
        fixture.cancel(egnyteRequest: req2)
        fixture.cancel(egnyteRequest: req1)
        
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 0.49))
        
        XCTAssert(req1.didExecute == false)
        XCTAssert(req2.didExecute == false)
        XCTAssert(req3.didExecute == false)
        XCTAssert(fixture.waitingQueue.count == 0)
    }
    
    func testThrottlingCancellUnenqueuedRequest() {
        let fixture = RequestThrottler.init(queriesPerSecond: 4)
        let req1 = RequestMock.init()
        let req2 = RequestMock.init()
        let req3 = RequestMock.init()
        
        fixture.enqueue(egnyteRequest: req1)
        
        fixture.cancel(egnyteRequest: req2)
        fixture.cancel(egnyteRequest: req3)
        
        XCTAssert(req1.didExecute == false)
        XCTAssert(req2.didExecute == false)
        XCTAssert(req3.didExecute == false)
        XCTAssert(fixture.waitingQueue.count == 1)
    }
    
    func testThrottlingretrydCancellAll() {
        let fixture = RequestThrottler.init(queriesPerSecond: 4)
        let req1 = RequestMock.init()
        let req2 = RequestMock.init()
        let req3 = RequestMock.init()
        
        fixture.enqueue(egnyteRequest: req1)
        fixture.retry(egnyteRequest: req2, after: 0.1)
        fixture.retry(egnyteRequest: req3, after: 0.1)
        
        fixture.cancel(egnyteRequest: req3)
        fixture.cancel(egnyteRequest: req2)
        fixture.cancel(egnyteRequest: req1)
        
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 0.49))
        
        XCTAssert(req1.didExecute == false)
        XCTAssert(req2.didExecute == false)
        XCTAssert(req3.didExecute == false)
        XCTAssert(fixture.waitingQueue.count == 0)
    }
    
    func testThrottlingretrydPriority() {
        let fixture = RequestThrottler.init(queriesPerSecond: 4)
        let req1 = RequestMock.init()
        let req2 = RequestMock.init()
        let req3 = RequestMock.init()
        
        fixture.enqueue(egnyteRequest: req1)
        fixture.retry(egnyteRequest: req2, after:0.1)
        fixture.retry(egnyteRequest: req3, after:0.2)
        
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 0.49))
        
        XCTAssert(req1.didExecute == false)
        XCTAssert(req2.didExecute)
        XCTAssert(req3.didExecute == false)
        XCTAssert(fixture.waitingQueue.count == 1)
        XCTAssert(fixture.retrydWaitingQueue.count == 1)

    }

}
