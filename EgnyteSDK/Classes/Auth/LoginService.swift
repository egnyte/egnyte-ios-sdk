//
//  LoginService.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 18.10.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation
import UIKit

/// Represents errors during OAuth.
public enum AuthError: CustomNSError, LocalizedError{
    /// User denied access to requested API.
    case accessDenied
    /// User canceled auth process.
    case userResigned
    /// State parameter in response is different. It may be effect of cross-site request forgery. Checkout OAtuh 2.0 specification to learn more.
    case invalidResponseStateParameter
    
    /// Domain of error.
    public static var errorDomain: String { return "AuthError"}
    /// Code of error.
    public var errorCode: Int {
        switch self {
        case .accessDenied: return -1
        case .invalidResponseStateParameter: return -2
        case .userResigned: return -3
        }
    }
    /// User info of error.
    public var errorUserInfo: [String : Any]  {
        return [NSLocalizedDescriptionKey : self.errorDescription!]
    }
    /// Description of error.
    public var errorDescription: String? {
        switch self {
        case .accessDenied:
            return NSLocalizedString("kAccessDeniedFailureErrorDesc", comment: "User denied access to Egnyte.")
        case .invalidResponseStateParameter:
            return NSLocalizedString("kInvalidResponseStateParameterErrorDesc", comment: "State parameter in response is different. It may be effect of cross-site request forgery. Checkout OAtuh 2.0 specification to learn more.")
        case .userResigned:
            return NSLocalizedString("kUserResignedErrorDesc", comment: "User cancelled auth process.")
        }
    }
}

/// Represents errors durign creation of AuthRequest
public enum DomainUrlError: Error {
    /// Domain url is does not have https scheme.
    case httpsSchemeRequired
    /// Domain url contains forbidden query.
    case forbiddenQuery
}

public typealias AuthResult = () throws -> AuthResponse

/// LoginService is a helper used to obtain auth token.
@objc public class LoginService: NSObject {
    
    /// Controller which would be used to present web view.
    unowned let  presentingViewController : UIViewController
    
    /// Designated initializer
    ///
    /// - Parameter presentingViewController: controller which would is used to present web view
    public required init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController;
        super.init()
    }

    
    /// Starts auth process by presenting web view to the user.
    ///
    /// - Parameters:
    ///   - authRequest: object containing necessary data to perform auth
    ///   - completion: contains closure returning AuthResponse, may throw AuthError or EgnyteError
    public func performAuthRequest(_ authRequest: AuthRequest, completion:@escaping (AuthResult) -> Void) {
        do {
            try self.validateAuthRequest(authRequest)
        } catch let domainError {
            completion({throw domainError})
            return;
        }
        
        let request = createURLRequest(authRequest)
        let authHelper = OAuthHelper.init(urlRequest: request, sharedSecret: authRequest.sharedSecret) { result in
            
            DispatchQueue.main.async {
                self.presentingViewController.dismiss(animated: true, completion: {
                    completion(result)
                })
            }
        }
        let loginVC = LoginViewController.init(urlRequest: request, oAuthDelegate: authHelper)
        let navVC = UINavigationController.init(rootViewController: loginVC)
        self.presentingViewController.present(navVC, animated: true, completion: nil)
    }
    
    func validateAuthRequest(_ authRequest: AuthRequest) throws {
        if let url = authRequest.egnyteDomainURL {
            try self.validateDomainUrl(url)
        }
    }
    
    func validateDomainUrl(_ domainUrl: URL) throws {
        let urlComponents = URLComponents.init(url: domainUrl, resolvingAgainstBaseURL: false)
        
        guard urlComponents?.query == nil else {
            throw DomainUrlError.forbiddenQuery
        }
        
        guard urlComponents?.scheme == "https" else {
            throw DomainUrlError.httpsSchemeRequired
        }
    }
    
    func createURLRequest(_ authRequest: AuthRequest) -> URLRequest {
        
        var resultURL: URL
        if let domainURL = authRequest.egnyteDomainURL {
            resultURL = domainURL
            resultURL.appendPathComponent("puboauth/token")
        } else {
            switch authRequest.region! {
            case .eu:
                resultURL = URL.init(string: "https://partner-integrations.egnyte.com")!
            case .us:
                resultURL = URL.init(string: "https://us-partner-integrations.egnyte.com")!
            }
            resultURL.appendPathComponent("services/oauth/code")
        }
        
        var pathComponents = URLComponents.init(url: resultURL, resolvingAgainstBaseURL: false)
        pathComponents!.queryItems = [URLQueryItem.init(name: "client_id", value: authRequest.apiKey)]
        pathComponents!.queryItems!.append(URLQueryItem.init(name: "state", value: authRequest.state))
        if let requestedScope = authRequest.scope, authRequest.scope!.isEmpty == false {
            var scopeValue = ""
            for scope in requestedScope {
                scopeValue += " \(scope.toString())"
            }
            pathComponents!.queryItems!.append(URLQueryItem.init(name: "scope", value: scopeValue))
            
        }
        pathComponents!.queryItems!.append(contentsOf: [URLQueryItem.init(name: "mobile", value: "1"),
                                                        URLQueryItem.init(name: "response_type", value: "code"),
                                                        URLQueryItem.init(name: "redirect_uri", value: "https://egnyte.com")])
        
        
        return URLRequest.init(url: pathComponents!.url!)
    }
}
