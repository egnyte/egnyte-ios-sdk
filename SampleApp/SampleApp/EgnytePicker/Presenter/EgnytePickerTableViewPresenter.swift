//
//  EgnytePickerTableViewPresenter.swift
//  SampleApp
//
//  Created by Adam Kędzia on 23.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import UIKit
import EgnyteSDK

protocol EgnytePickerRouterProtocol {
    func didSelectFile(file: EgnyteFile) -> Void
    func didCancelled() -> Void
}

@objc protocol EgnytePickerPresenterProtocol {
    func didSelect(row: Int)
    func didTapActionsButton(row: Int)
    func fetchData()
    func leftBarButton() -> UIBarButtonItem?
    func rightBarButton() -> UIBarButtonItem?
    func title() -> String?
    func registerEgnytePicker(_ picker: EgnytePickerTableViewController)
}

class EgnytePickerTableViewPresenter: NSObject, EgnytePickerPresenterProtocol {
    public var shouldShowCancelButton = true
    let pickerDataSource: EgnyteDataSource
    let egnyteApiClient: EgnyteAPIClient!
    let actionsHandler: EgnyteActionsHandler
    let displayService = FileDisplayService.init()
    var folder: EgnyteFolder!
    weak var egnytePickerTableVC: EgnytePickerTableViewController!
    
    init(apiClient: EgnyteAPIClient, folder: EgnyteFolder,
         dataSource: EgnyteDataSource,
         actionsHandler: EgnyteActionsHandler) {
        self.egnyteApiClient = apiClient
        self.folder = folder
        self.pickerDataSource = dataSource
        self.actionsHandler = actionsHandler
        super.init()
    }
    
    func registerEgnytePicker(_ picker: EgnytePickerTableViewController) {
        picker.tableView.dataSource = self.pickerDataSource
        self.egnytePickerTableVC = picker
        self.actionsHandler.viewController = picker
        self.pickerDataSource.cellConfiguration = { [weak self] cell, item in
            cell.populateWith(viewModel: EgnytePickerCellViewModel.init(item: item))
            cell.delegate = self?.egnytePickerTableVC
            return cell
        }
    }
    
    func fetchData() {
        self.handleStartFetchingAnimation()
        self.pickerDataSource.fetchData { result in
            do {
                _ = try result()
                self.handleStopFetchingAnimation()
                self.egnytePickerTableVC.tableView.reloadData()
                
                if self.pickerDataSource.data.isEmpty {
                    self.egnytePickerTableVC.showMassageWith(text: "This folder is empty")
                }else {
                    self.egnytePickerTableVC.hideMessage()
                }
                
            }catch _ {
                self.handleStopFetchingAnimation()
                self.egnytePickerTableVC.showMassageWith(text: "An error occured.\n Pull to refresh folder content.")
            }
        }
        
    }
    
    func handleStartFetchingAnimation() {
        if self.egnytePickerTableVC.refreshControl?.isRefreshing == false {
            self.egnytePickerTableVC.loadingIndicator.startAnimating()
        }
    }
    
    func handleStopFetchingAnimation() {
        self.egnytePickerTableVC.loadingIndicator.stopAnimating()
        self.egnytePickerTableVC.refreshControl?.endRefreshing()
    }
    
    func rightBarButton() -> UIBarButtonItem? {
        
        guard self.shouldShowCancelButton else {
            return nil
        }
        let result = UIBarButtonItem.init(image: UIImage.init(named: "navigationbar-more"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(rightBarButtonPressed))
        result.setTitleTextAttributes([NSFontAttributeName: EgnyteTheme.navigationBarFont], for: .normal)
        return result
    }
    
    func rightBarButtonPressed() {
        let actions = self.actionsHandler.actionsForMenu(folder: self.folder)
        self.egnytePickerTableVC.showActionSheetWith(actions: actions)
    }
    
    func leftBarButton() -> UIBarButtonItem? {
        guard self.folder.path != EgnyteFolder.rootFolder().path else {
            return nil
        }
        
        return UIBarButtonItem.init(image: UIImage.init(named: "icon_title_back_arrow"),
                                    style: .plain,
                                    target: self,
                                    action: #selector(leftBarButtonPressed))
    }
    
    func leftBarButtonPressed() {
        _ = self.egnytePickerTableVC.navigationController?.popViewController(animated: true)
    }
    
    func title() -> String? {
        return self.folder.name == EgnyteFolder.rootFolder().name ? "Home" : self.folder.name
    }
    
    func didTapActionsButton(row: Int) {
        let item = self.pickerDataSource.data[row]
        let actions = self.actionsHandler.actionsFor(item: item)
        self.egnytePickerTableVC.showActionSheetWith(actions: actions)
    }
    
    func didSelect(row: Int) {
        let item = self.pickerDataSource.data[row]
        if item is EgnyteFolder {
            let dataSource = EgnytePickerDataSource.init(apiClient: self.egnyteApiClient, folder: item as! EgnyteFolder)
            let presenter = EgnytePickerTableViewPresenter.init(apiClient: self.egnyteApiClient,
                                                                folder: item as! EgnyteFolder,
                                                                dataSource: dataSource,
                                                                actionsHandler: EgnyteActionsHandler.init(apiClient: self.egnyteApiClient))
            presenter.shouldShowCancelButton = self.shouldShowCancelButton
            
            let searchPresenter = EgnyteSearchResultsPresenter.init(apiClient: self.egnyteApiClient,
                                                                    folder: EgnyteFolder.rootFolder(),
                                                                    dataSource: EgnyteSearchDataSource.init(apiClient: self.egnyteApiClient),
                                                                    actionsHandler: EgnyteActionsHandler.init(apiClient: self.egnyteApiClient))
            
            let searchVC = UISearchController.init(searchResultsController: EgnytePickerTableViewController.init(presenter: searchPresenter))
            searchVC.searchResultsUpdater = searchPresenter

            let pickerVC = EgnytePickerTableViewController.init(presenter: presenter, searchController: searchVC)
            
            self.egnytePickerTableVC.navigationController?.pushViewController(pickerVC, animated: true)
        } else {
            self.displayService.downloadAndDisplay(file: item,
                                                   controller: self.egnytePickerTableVC,
                                                   apiClient: self.egnyteApiClient)
        }
    }
}
