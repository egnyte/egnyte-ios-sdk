//
//  EgnyteMimeIcon.swift
//  SampleApp
//
//  Created by Adam Kędzia on 23.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation
import UIKit
import EgnyteSDK

struct EgnyteMimeIcon {
    let iconImage: UIImage
    let iconLabel: String?
    
    init(item: EgnyteItem) {
        if item is EgnyteFolder {
            self.iconImage = UIImage.init(named: "folder")!
            self.iconLabel = nil
        }else {
            self.iconImage = UIImage.init(named: "unknown")!
            let fileExtension = URL.init(string:item.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)?.pathExtension
            self.iconLabel = fileExtension?.uppercased()
        }
    }
    
}
