//
//  EgnytePickerTableViewController.swift
//  SampleApp
//
//  Created by Adam Kędzia on 22.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import UIKit
import EgnyteSDK

class EgnytePickerTableViewController: UITableViewController, PickerCellDelegate, UISearchBarDelegate {
    var presenter: EgnytePickerPresenterProtocol!
    var messageLabel: UILabel!
    let loadingIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    let searchController: UISearchController?
    
    init(presenter: EgnytePickerPresenterProtocol, searchController: UISearchController? = nil) {
        self.presenter = presenter
        self.searchController = searchController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib.init(nibName: "EgnytePickerTableViewCell", bundle: Bundle.main),
                                forCellReuseIdentifier: "kEgnytePickerTableViewCell")
        self.presenter.registerEgnytePicker(self)
        self.configureView()
        self.fetchData()
    }
    
    func showMassageWith(text: String) {
        self.messageLabel.text = text
        self.messageLabel.isHidden = false
    }
    
    func hideMessage() {
        self.messageLabel.isHidden = true
    }
    
    func showErrorAlertWith(message: String) {
        let alertVC = UIAlertController.init(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func showActionSheetWith(actions: [UIAlertAction]) {
        let actionsVC = UIAlertController.init(title: "Actions", message: nil, preferredStyle: .actionSheet)
        for action in actions {
            actionsVC.addAction(action)
        }
        self.present(actionsVC, animated: true, completion: nil)
    }
    
    private func configureView() {
        self.navigationItem.leftBarButtonItem = self.presenter.leftBarButton()
        self.navigationItem.rightBarButtonItem = self.presenter.rightBarButton()
        self.navigationItem.title = self.presenter.title()
        self.tableView.addSubview(self.loadingIndicator)
        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicator.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor).isActive = true
        self.loadingIndicator.centerYAnchor.constraint(equalTo: self.tableView.centerYAnchor).isActive = true
        self.tableView.separatorStyle = .none
        self.refreshControl = UIRefreshControl.init()
        self.refreshControl?.addTarget(self, action: #selector(fetchData), for: UIControlEvents.valueChanged)
        self.configureMassageLabel()
        if let searchBar = self.searchController?.searchBar {
            self.configureSearchBar(in: searchBar)
        }
    }
    
    private func configureSearchBar(in searchBar: UISearchBar) {
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.isOpaque = false
        searchBar.backgroundColor = .lightText
        searchBar.barTintColor = .lightText
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.tintColor = EgnyteTheme.searchButton
        self.tableView.tableHeaderView = searchBar
    }
    
    private func configureMassageLabel() {
        self.messageLabel = UILabel.init(frame: self.view.frame)
        self.messageLabel.font = UIFont.init(name: "HelveticaNeue-Thin", size: 24)
        self.messageLabel.numberOfLines = 0
        self.messageLabel.isHidden = true
        self.messageLabel.textAlignment = .center
        self.messageLabel.textColor = EgnyteTheme.messageText
        self.tableView.backgroundView = self.messageLabel
    }
    
    func didTapActionsButton(cell: UITableViewCell) {
        let index = self.tableView.indexPath(for: cell)!
        self.presenter.didTapActionsButton(row: index.row)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func fetchData() {
        self.presenter.fetchData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter.didSelect(row: indexPath.row)
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    //MARK : SearchBar delegate
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}
