//
//  FileDisplayService.swift
//  SampleApp
//
//  Created by Adam Kędzia on 01.12.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import UIKit
import QuickLook
import EgnyteSDK

class FileDisplayService: NSObject, QLPreviewControllerDataSource  {
    var currentURL: URL?
    
    public func downloadAndDisplay(file: EgnyteItem, controller: EgnytePickerTableViewController, apiClient: EgnyteAPIClient) {
        let progressViewPresenter = ProgressViewPresenter.init(title: file.name, subtitle: "Downloading...")
        let progressView = ProgressViewController.init(presenter: progressViewPresenter)
        let url = URL.init(fileURLWithPath:NSTemporaryDirectory().appending(file.name))
        try? FileManager.default.removeItem(at: url)
        
        let downloadReq = FileDownloadToDiskRequest.init(apiClient: apiClient,
                                                         filepath: file.path,
                                                         destinationURL: url,
                                                         versionEntryId: nil,
                                                         fileManager: nil,
                                                         progressHandler: { (progress) in
                                                            progressViewPresenter.updateProgress(progress: progress)
        },
                                                         middleware: { request in
                                                            var result = request
                                                            result.cachePolicy = .reloadIgnoringLocalCacheData
                                                            return result
        },
                                                         completion: { (result) in
                                                            progressView.dismiss(animated: true, completion: {
                                                                do {
                                                                    self.currentURL = try result()
                                                                    self.displayQL(presentingController: controller)
                                                                } catch let error {
                                                                    let connectionCancelled = (error as NSError).code == -999
                                                                    guard connectionCancelled == false else {
                                                                        return
                                                                    }
                                                                    controller.showErrorAlertWith(message: error.localizedDescription)
                                                                }
                                                            })
        })
        
        progressViewPresenter.request = downloadReq
        downloadReq.enqueue()
        controller.present(progressView, animated: true, completion: nil)
    }
    
    private func displayQL(presentingController: UIViewController) {
        let ql = QLPreviewController.init()
        ql.dataSource = self
        
        if let vc = presentingController.navigationController {
            vc.pushViewController(ql, animated: true)
        } else {
            presentingController.present(ql, animated: true, completion: nil)
        }
    }
    
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.currentURL as! QLPreviewItem
    }
    
}
