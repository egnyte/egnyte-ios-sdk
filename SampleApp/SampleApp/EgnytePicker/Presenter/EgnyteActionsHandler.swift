//
//  EgnyteActionsHandler
//  SampleApp
//
//  Created by Adam Kędzia on 29.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import UIKit
import EgnyteSDK

class EgnyteActionsHandler: NSObject, UIDocumentPickerDelegate, UIDocumentMenuDelegate {
    private let apiClient: EgnyteAPIClient
    weak var viewController: EgnytePickerTableViewController!
    private var uploadFolder: EgnyteFolder?
    
    init(apiClient: EgnyteAPIClient) {
        self.apiClient = apiClient
        super.init()
    }
    
    func actionsFor(item: EgnyteItem) -> [UIAlertAction] {
        let createLink = UIAlertAction.init(title: "Share Link", style: .default) { [weak self] _ in
                self?.createLink(item: item)
        }
        let delete = UIAlertAction.init(title: "Delete", style: .destructive) { [weak self] _ in
            self?.delete(item: item)
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel)
        
        var result =  [createLink, delete, cancel]
        
        if let file = item as? EgnyteFile {
            if file.locked {
                result.insert(UIAlertAction.init(title: "Unlock", style: .default) {[weak self] _ in self?.unlock(item: file)}, at: 0)
            } else {
                result.insert(UIAlertAction.init(title: "Lock", style: .default) {[weak self] _ in self?.lock(item: file)}, at: 0)
            }
        }
        
        return result;
    }
    
    func actionsForMenu(folder: EgnyteFolder) -> [UIAlertAction] {
        let createFolder = UIAlertAction.init(title: "New Folder", style: .default) { [weak self] _ in
            self?.createFolder(parentFolder: folder)
        }
        let logOut = UIAlertAction.init(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.logOut()
        }
        let upload = UIAlertAction.init(title: "New file", style: .default) { [weak self] _ in
            self?.uploadFileTo(folder: folder)
        }

        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel)

        return [createFolder, upload, logOut, cancel]
    }
    
    private func uploadFileTo(folder: EgnyteFolder) {
        let importMenu = UIDocumentMenuViewController(documentTypes: ["public.data"], in: .import)
        importMenu.delegate = self
        self.uploadFolder = folder
        
        self.viewController.present(importMenu, animated: true, completion: nil)
    }
    
    private func createFolder(parentFolder: EgnyteFolder) {
        let alert = UIAlertController.init(title: "New Folder", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "New folder name"
        }
        
        alert.addAction(UIAlertAction.init(title: "Create", style: .default, handler: { _ in
            let textField = alert.textFields?.first!
            let path = parentFolder.path.appendingFormat("/%@", textField?.text ?? "")
            let createFolderRequest = CreateFolderRequest.init(apiClient: self.apiClient,
                                                               path: path) { result in
                                                                do {
                                                                    let success = try result()
                                                                    if (success) {
                                                                        self.viewController.fetchData()
                                                                    }

                                                                } catch let error {
                                                                    self.viewController.showErrorAlertWith(message: error.localizedDescription)
                                                                }
            }
            
            createFolderRequest.enqueue()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel))
        self.viewController.present(alert, animated: true, completion: nil)
    }
    
    private func logOut() {
        self.viewController?.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func delete(item: EgnyteItem) {
        let deleteRequest = DeleteRequest.init(apiClient: self.apiClient,
                                               path: item.path) { result in
                                                do {
                                                    let success = try result()
                                                    if (success) {
                                                        self.viewController.fetchData()
                                                    }
                                                } catch let error {
                                                    self.viewController.showErrorAlertWith(message: error.localizedDescription)
                                                }
        }
        
        deleteRequest.enqueue()
    }
    
    private func createLink(item: EgnyteItem) {
        let type = item is EgnyteFile ? EgnyteLinkType.file : EgnyteLinkType.folder
        let builder = CreateLinkRequestBuilder.init(apiClient: apiClient,
                                                    path: item.path,
                                                    type: type, accessibility: .anyone) { [weak self] result in
                                                        do {
                                                            let response = try result()
                                                            let linkPath = response.links.first!.urlPath
                                                            let alertVC = UIAlertController.init(title: "Link Created", message: String.init(format: "Your link is: %@", linkPath), preferredStyle: .alert)
                                                            alertVC.addAction(UIAlertAction.init(title: "Copy to Clipboard", style: .default, handler: {_ in
                                                                UIPasteboard.general.string = linkPath
                                                                alertVC.dismiss(animated: true, completion: nil)
                                                            }))
                                                            alertVC.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                                                            self?.viewController.present(alertVC, animated: true, completion: nil)
                                                        } catch let error {
                                                            self?.viewController.showErrorAlertWith(message: error.localizedDescription)
                                                        }
        }
        
        builder.buildCreateLinkRequest().enqueue()
    }
    
    private func lock(item: EgnyteFile) {
        
        let customLockRequest = try! EgnyteBaseRequest.init(apiClient: self.apiClient,
                                                       endpoint: "/pubapi/v1/fs/",
                                                       filepath: item.path,
                                                       method: "POST",
                                                       parameters: ["action" : "lock", "lock_token": "lockToken"]) {
                                                        result in
                                                        do {
                                                            _ = try result()
                                                            self.viewController.fetchData()
                                                        } catch let error {
                                                            self.viewController.showErrorAlertWith(message: error.localizedDescription)
                                                        }
        }
        customLockRequest.enqueue()
    }
    
    private func unlock(item: EgnyteFile) {
        
        let customUnlockRequest = try! EgnyteBaseRequest.init(apiClient: self.apiClient,
                                                       endpoint: "/pubapi/v1/fs/",
                                                       filepath: item.path,
                                                       method: "POST",
                                                       parameters: ["action" : "unlock", "lock_token": "lockToken"]) {
                                                        result in
                                                        do {
                                                            _ = try result()
                                                            self.viewController.fetchData()
                                                        } catch let error {
                                                            self.viewController.showErrorAlertWith(message: error.localizedDescription)
                                                        }
        }
        customUnlockRequest.enqueue()
    }
    
    // MARK - document menu delegate

    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.viewController.present(documentPicker, animated: true, completion: nil)
    }
    
    // MARK - document picker delegate
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        let progressViewPresenter = ProgressViewPresenter.init(title: url.lastPathComponent, subtitle: "Uploading...")
        let progressView = ProgressViewController.init(presenter: progressViewPresenter)
        
        let uploadRequest = FileUploadFromDiskRequest.init(apiClient: self.apiClient,
                                                           fileURL: url,
                                                           uploadFilepath: self.uploadFolder!.path.appending("/" + url.lastPathComponent),
                                                           lastModified: nil,
                                                           checksum: nil,
                                                           progressHandler: { (progress) in
                                                            progressViewPresenter.updateProgress(progress: progress)
        },
                                                           completion: { (result) in
                                                            do {
                                                                progressView.dismiss(animated: true, completion:nil)
                                                                _ = try result()
                                                                self.viewController.fetchData()
                                                            } catch let error {
                                                               self.viewController.showErrorAlertWith(message: error.localizedDescription)
                                                            }
        })
        
        progressViewPresenter.request = uploadRequest
        uploadRequest.enqueue()
        self.viewController.present(progressView, animated: true, completion: nil)

    }
}
