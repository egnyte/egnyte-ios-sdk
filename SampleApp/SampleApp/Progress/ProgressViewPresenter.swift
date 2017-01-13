//
//  ProgressViewPresenter.swift
//  SampleApp
//
//  Created by Adam Kędzia on 25.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import UIKit
import EgnyteSDK

@objc protocol ProgressViewPresenterProtocol {
    func titleLabelText() -> String
    func subtitleLabelText() -> String
    func register(_ progressView: ProgressViewController)
}

class ProgressViewPresenter: NSObject, ProgressViewPresenterProtocol {
    private let title: String
    private let subtitle: String

    private weak var progressView: ProgressViewController!
    weak var request: Cancellable?
    
    init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
    
    func register(_ progressView: ProgressViewController) {
        self.progressView = progressView
        progressView.bottomButton.addTarget(self, action: #selector(didCancel), for: .touchUpInside)
    }
    
    func titleLabelText() -> String {
        return self.title
    }
    
    func didCancel() {
        self.progressView.dismiss(animated: true) {
            self.request?.cancel()
        }
    }
    
    func subtitleLabelText() -> String {
        return self.subtitle
    }
    
    func updateProgress(progress: Progress) {
        self.progressView.progressView.progress = Float(progress.fractionCompleted)
    }
}
