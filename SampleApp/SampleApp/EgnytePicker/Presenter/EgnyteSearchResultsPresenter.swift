//
//  EgnyteSearchResultsPresenter.swift
//  SampleApp
//
//  Created by Adam Kędzia on 01.12.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import UIKit
import EgnyteSDK

class EgnyteSearchResultsPresenter: EgnytePickerTableViewPresenter, UISearchResultsUpdating {

    public func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        (self.pickerDataSource as! EgnyteSearchDataSource).query = query
        if query.characters.count < 3 {
            self.egnytePickerTableVC.showMassageWith(text: "Query must have at least 3 characters")
        } else {
            self.fetchData()
        }
    }
    
    override func fetchData() {
        self.handleStartFetchingAnimation()
        self.pickerDataSource.fetchData { result in
            do {
                _ = try result()
                self.handleStopFetchingAnimation()
                self.egnytePickerTableVC.tableView.reloadData()
                
                if self.pickerDataSource.data.isEmpty {
                    self.egnytePickerTableVC.showMassageWith(text: "No search results")
                }else {
                    self.egnytePickerTableVC.hideMessage()
                }
                
            }catch _ {
                self.handleStopFetchingAnimation()
                self.egnytePickerTableVC.showMassageWith(text: "An error occured.\n Pull to refresh folder content.")
            }
        }
        
    }
    
    override func rightBarButton() -> UIBarButtonItem? {
        return nil
    }
    
    override func leftBarButton() -> UIBarButtonItem? {
        guard self.folder.path != EgnyteFolder.rootFolder().path else {
            return nil
        }
        
        return UIBarButtonItem.init(image: UIImage.init(named: "icon_title_back_arrow"),
                                    style: .plain,
                                    target: self,
                                    action: #selector(leftBarButtonPressed))
    }
    
    
    override func title() -> String? {
        return "Search"
    }
}
