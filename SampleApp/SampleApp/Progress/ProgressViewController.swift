//
//  ProgressViewController.swift
//  SampleApp
//
//  Created by Adam Kędzia on 25.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var fileNameLabel: UILabel!
    let presenter: ProgressViewPresenterProtocol
    
    init(presenter: ProgressViewPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "ProgressViewController", bundle: Bundle.main)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.register(self)
        self.progressView.progress = 0.0
        self.fileNameLabel.text = presenter.titleLabelText()
        self.bottomLabel.text = presenter.subtitleLabelText()
    }
}
