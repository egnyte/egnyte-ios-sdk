//
//  ValueObserverTests.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 10.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import XCTest
@testable import EgnyteSDK

class observableObject: NSObject {
    dynamic var number = NSNumber.init(value: 0)
}

class ValueObserverTests: XCTestCase {

    
    func testValueObserver() {
        let observableObj = observableObject.init()
        var fixture: ValueObserver?
        fixture = ValueObserver.init(objectToObserve:observableObj , path: "number") { newValue in
            XCTAssert(newValue as! Int == 1)
        }
        
        observableObj.number = 1
        XCTAssert(fixture!.observable == observableObj)
        fixture = nil
        observableObj.number = 2
    }    
}

