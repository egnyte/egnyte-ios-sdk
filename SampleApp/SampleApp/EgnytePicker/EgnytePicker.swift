//
//  EgnytePicker.swift
//  SampleApp
//
//  Created by Adam Kędzia on 24.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import UIKit
import EgnyteSDK

public class EgnytePicker: NSObject {
    public var shouldShowCancelButton = true
    weak var navigationVC: UINavigationController?
    let apiClient: EgnyteAPIClient
    
    public init(token:String, domainURL: URL) {
        self.apiClient = EgnyteAPIClient.init(domainURL: domainURL, token: token)
    }
    
    public func pickerViewController() -> UIViewController {
        return self.navigationVC ?? self.configurePickerViewController()
    }
    
    public func currentFolder() -> EgnyteFolder {
        let tablveVC = (self.navigationVC?.topViewController as? EgnytePickerTableViewController)
        return (tablveVC?.presenter as? EgnytePickerTableViewPresenter)?.folder ?? EgnyteFolder.rootFolder()
    }
    
    func configurePickerViewController() -> UIViewController {
        let dataSource = EgnytePickerDataSource.init(apiClient: self.apiClient, folder: EgnyteFolder.rootFolder())
        let pickerPresenter = EgnytePickerTableViewPresenter.init(apiClient: self.apiClient,
                                                                  folder: EgnyteFolder.rootFolder(),
                                                                  dataSource: dataSource,
                                                                  actionsHandler: EgnyteActionsHandler.init(apiClient: self.apiClient))
        pickerPresenter.shouldShowCancelButton = self.shouldShowCancelButton
        
        let searchPresenter = EgnyteSearchResultsPresenter.init(apiClient: self.apiClient,
                                                                folder: EgnyteFolder.rootFolder(),
                                                                dataSource: EgnyteSearchDataSource.init(apiClient: self.apiClient),
                                                                actionsHandler: EgnyteActionsHandler.init(apiClient: self.apiClient))
        
        
        let searchVC = UISearchController.init(searchResultsController: EgnytePickerTableViewController.init(presenter: searchPresenter))
        searchVC.searchResultsUpdater = searchPresenter
        
        let pickerVC = EgnytePickerTableViewController.init(presenter: pickerPresenter, searchController: searchVC)
        let navVC = UINavigationController.init(rootViewController: pickerVC)
        
        navVC.navigationBar.barTintColor = EgnyteTheme.navigationBarBackground
        navVC.navigationBar.tintColor = EgnyteTheme.navigationBarTint
        let titleBarAttributes = [NSFontAttributeName: EgnyteTheme.navigationBarFont]
        navVC.navigationBar.titleTextAttributes = titleBarAttributes
        navVC.navigationBar.barStyle = .black
        self.navigationVC = navVC
        
        return navVC
    }
}
