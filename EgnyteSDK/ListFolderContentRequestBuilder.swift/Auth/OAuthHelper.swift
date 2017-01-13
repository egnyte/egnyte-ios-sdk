//
//  OAuthHelper.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 19.10.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation

protocol OAuthWebDelegate: class {
    func didResigned() -> Void
    func didReceive(error: Error) -> Void
    func shouldRedirectForRequest(_ urlRequest: URLRequest) -> Bool
}

class OAuthHelper: OAuthWebDelegate {
    let authRequest: URLRequest
    let clientSecret: String
    let authCompletion: (@escaping AuthResult) -> Void
    
    required init(urlRequest: URLRequest, clientSecret: String, completion: @escaping ( @escaping AuthResult) -> Void) {
        self.authRequest = urlRequest
        self.authCompletion = completion
        self.clientSecret = clientSecret
    }
    
    internal func shouldRedirectForRequest(_ urlRequest: URLRequest) -> Bool {
        let url = urlRequest.url
        let redirectURL = self.queryValue(self.authRequest.url!, key: "redirect_uri")
        
        if url?.host == URL.init(string: redirectURL!)?.host {
            return self.processIntermidateAuthResult(urlRequest);
        }
        
        return true;
    }
    
    internal func didResigned() {
        self.authCompletion { () -> AuthResponse in
            throw AuthError.userResigned
        }
    }
    
    internal func didReceive(error: Error) {
        guard (error as NSError).code != 102 else {
            return
        }
        
        self.authCompletion { () -> AuthResponse in
            throw error
        }
    }

    func queryValue(_ url:URL, key:String) -> String? {
        let queryItems = URLComponents.init(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        for queryItem in queryItems {
            if queryItem.name == key {
                return queryItem.value
            }
        }
        return nil;
    }
    
    func processIntermidateAuthResult(_ urlRequest: URLRequest) -> Bool {
        let state = self.queryValue(urlRequest.url!, key: "state")
        let code = self.queryValue(urlRequest.url!, key: "code")
        let error = self.queryValue(urlRequest.url!, key: "error")
        
        guard error == nil else {
            self.authCompletion { () -> AuthResponse in
                throw AuthError.accessDenied
            }
            return false
        }
        
        guard state == self.queryValue(self.authRequest.url!, key: "state") else {
            self.authCompletion { () -> AuthResponse in
                throw AuthError.invalidResponseStateParameter
            }
            return false
        }
        
        if let authCode = code {
            let scope = self.queryValue(self.authRequest.url!, key: "scope")
            let domain = URL.init(string: urlRequest.value(forHTTPHeaderField: "Referer")!)!
            let exchangeRequest = createExchangeRequest(code: authCode,
                                                        domainURL: domain,
                                                        clientID: self.queryValue(self.authRequest.url!, key: "client_id")!,
                                                        redirectURI: self.queryValue(self.authRequest.url!, key: "redirect_uri")!,
                                                        clientSecret: self.clientSecret,
                                                        scope:scope)
            self.exchangeCodeWithRequest(exchangeRequest: exchangeRequest)
            return false
        }
        
        return true
    }
    
    func createExchangeRequest(code: String, domainURL: URL, clientID: String, redirectURI: String, clientSecret: String, scope: String?) -> URLRequest {
        var requestBodyString = "client_id=" + clientID
        requestBodyString += "&client_secret=" + clientSecret
        requestBodyString += "&redirect_uri=" + redirectURI
        requestBodyString += "&code=" + code + "&grant_type=authorization_code"
        
        if let scope = scope {
            requestBodyString += "&scope=" + scope
        }
        
        var exchangeRequest = URLRequest.init(url: URL.init(string: "https://\(domainURL.host!)/puboauth/token")!)
        exchangeRequest.httpBody = requestBodyString.data(using: .utf8)
        exchangeRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        exchangeRequest.httpMethod = "POST"
        
        return exchangeRequest
    }
    
    func exchangeCodeWithRequest(exchangeRequest: URLRequest) -> Void {
        let task = URLSession.shared.dataTask(with: exchangeRequest) { [weak self] (data, response, error) in
            self?.processAuthResponse(data: data, response: response, error: error, exchangeRequest: exchangeRequest)
        }
        
        task.resume()
    }
    
    func processAuthResponse(data :Data?, response: URLResponse?, error :Error?, exchangeRequest: URLRequest) {
        
        let errorHandler = EgnyteBaseRequestErrorHandler.init()
        do {
            try errorHandler.handleResponse(data: data, response: response, error: error)
        } catch let error {
            self.authCompletion({throw error})
            return
        }
        
        guard let token = self.tokenFrom(data: data) else {
            self.authCompletion({
                throw EgnyteError.unexpectedResponse(description: errorHandler.errorDescriptionFrom(data: data)
                    ?? NSLocalizedString("kUnexpectedResponse",
                                         comment: "Unexpected response from server"))
            })
            return
        }
        
        self.authCompletion({ () -> AuthResponse in
            return AuthResponse.init(token: token,
                                     egnyteDomainURL: URL.init(string: "https://" + exchangeRequest.url!.host!)!)
        })
    }
    
    func tokenFrom(data:Data?) -> String? {
        guard let dataToSerialize = data else {
            return nil
        }
        
        do {
            let result = try JSONSerialization.jsonObject(with: dataToSerialize, options:.allowFragments) as! [String: Any]
            return result["access_token"] as? String
            
        }catch let error {
            self.authCompletion({throw error})
            return nil
        }
    }
    
}
