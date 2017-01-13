//
//  MainViewController.swift
//  SampleApp
//
//  Created by Adam Kędzia on 17.10.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import UIKit
import EgnyteSDK

class MainViewController: UIViewController {
    @IBOutlet weak var domainField: UITextField!
    var token: String?
    static let API_KEY = "your api key"
    static let SHARED_SECRET = "your shared secret"
    var picker: EgnytePicker?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginButtonTouchUpInside(_ sender: AnyObject) {
        let loginService = LoginService.init(presentingViewController: self)
        
        let authRequest: AuthRequest
        // If user entered domain we use login flow with known domain. Otherwise, we use simplest flow, without known domain
        if domainField.text != nil, let domainUrl = URL.init(string: domainField.text!) {
            authRequest = AuthRequest.init(apiKey: MainViewController.API_KEY,
                                           sharedSecret: MainViewController.SHARED_SECRET,
                                           egnyteDomainURL: domainUrl)
        } else {
            authRequest = AuthRequest.init(apiKey: MainViewController.API_KEY,
                                           sharedSecret: MainViewController.SHARED_SECRET)
        }
        
    
        loginService.performAuthRequest(authRequest) { result in
            do{
                let authResult = try result()
                self.token = authResult.token
                self.picker = EgnytePicker.init(token: authResult.token,
                                                domainURL: authResult.egnyteDomainURL)
                let vc = self.picker!.pickerViewController()
                self.present(vc, animated: true, completion: nil)

            }catch AuthError.userResigned{
                self.showError(msg: AuthError.userResigned.localizedDescription)

            }catch AuthError.accessDenied{
                self.showError(msg: "Access denied")

            }catch EgnyteError.httpError(let code, let description) {
                self.showError(msg: "HTTP error \(code) \(description)")
            }
            catch let error {
                self.showError(msg:error.localizedDescription)
            }
        }
    }
    
    func showError(msg: String) -> Void {
        let alert = UIAlertController.init(title: nil, message: msg, preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

