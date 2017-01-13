//
//  LoginViewController.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 18.10.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation
import WebKit
import UIKit

class LoginViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView!
    let urlRequest: URLRequest?
    var oAuthDelegate: OAuthWebDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        self.urlRequest = nil
        self.oAuthDelegate = nil
        super.init(coder: aDecoder)
    }
    
    init(urlRequest: URLRequest, oAuthDelegate: OAuthWebDelegate) {
        self.urlRequest = urlRequest
        self.oAuthDelegate = oAuthDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cancelButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.cancel,
                                              target: self,
                                              action:#selector(didCancelAuthProcess))
        self.navigationItem.setLeftBarButton(cancelButton, animated: true)
        URLSession.shared.reset { 
            self.webView.load(self.urlRequest!)
        }
    }
    
    func didCancelAuthProcess() {
        self.oAuthDelegate?.didResigned()
        self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if self.oAuthDelegate!.shouldRedirectForRequest(navigationAction.request) {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.oAuthDelegate?.didReceive(error: error)
    }
}
