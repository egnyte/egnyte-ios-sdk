//
//  EgnyteItem.swift
//  SampleApp
//
//  Created by Adam Kędzia on 01.12.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation
import EgnyteSDK

public protocol EgnyteItem {
    var name: String {get}
    var path: String {get}
}

extension EgnyteFile: EgnyteItem {
    
}

extension EgnyteFolder: EgnyteItem {
    
}

extension EgnyteSearchedFile: EgnyteItem {
    
}

extension EgnyteSearchedFolder: EgnyteItem {
		
}
