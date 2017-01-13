//
//  EgnytePickerCellViewModel.swift
//  SampleApp
//
//  Created by Adam Kędzia on 23.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation
import EgnyteSDK

struct EgnytePickerCellViewModel {
    let mimeIcon: EgnyteMimeIcon
    let itemName: String
    let lastModified: String?
    
    init(item: EgnyteItem) {
        self.mimeIcon = EgnyteMimeIcon.init(item: item)
        self.itemName = item.name
        
        if let item = item as? EgnyteFile {
            self.lastModified = EgnytePickerCellViewModel.modifiedDataFrom(timeStamp: item.lastModified)
        } else if let item = item as? EgnyteSearchedFile{
            self.lastModified = EgnytePickerCellViewModel.modifiedDataFrom(timeStamp: item.lastModified)
        } else {
            self.lastModified = nil
        }
    }
    
    static private func modifiedDataFrom(timeStamp: TimeInterval) -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "dd.MM.YYYY, HH:mm"
        return  dateFormatter.string(from: Date.init(timeIntervalSince1970: timeStamp))
    }
}
