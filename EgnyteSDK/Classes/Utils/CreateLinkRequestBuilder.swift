//
//  CreateLinkRequestBuilder.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 16.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation

/// Builder for CreateLinkRequest.
public class CreateLinkRequestBuilder {
    /// EgnyteAPIClient which performs and authorize request.
    private weak var apiClient: EgnyteAPIClient?
    /// The absolute path of the target file or folder.
    private let path: String
    /// Type of link will be created. Can be file, folder or upload.
    private let type: EgnyteLinkType
    /// Determines who a link is accessible by. Can be anyone, password, domain or recipients.
    private let accessibility: EgnyteLinkAccessibility
    /// Boolean value indicating whether if link will be sent via email by Egnyte.
    public var sendEmail: Bool?
    /// Array of email addresses of recipients of the link. Only required if sendEmail is true.
    public var recipients: [String]?
    /// Personal message to be sent in link email. Only applies if sendEmail is true.
    public var message: String?
    /// Boolean value indicating whether a copy of the link message will be sent to the link creator. Only applies if sendEmail is true. Defaults to *false*.
    public var copyMe: Bool?
    /// Boolean value indicating whether link creator will be notified via email when link is accessed.
    public var notify: Bool?
    /// Boolean value indicating whether link will always refer to current version of file. Only applicable for file links.
    public var linkToCurrent: Bool?
    /// Expiry type of the link. Can be set to date or clicks.
    public var linkExpiry: LinkExpiry?
    /// Boolean value indicating whether filename will be appended to the end of the link. Only applies to file links, not folder links.
    public var addFilename: Bool?
    /// Boolean value indicating whether each recipient's uploaded data will be put into a separate folder. Only applies to upload links.
    public var folderPerRecipient: Bool?
    /// Completion block with closure returning EgnyteLinkResponse or throwing an error.
    public var completion:(() throws -> EgnyteLinkResponse) -> Void
    
    /// Initialize CreateLinkRequestBuilder with required parameters.
    ///
    /// - Parameters:
    ///   - apiClient: EgnyteAPIClient which performs and authorize request.
    ///   - path: The absolute path of the target file or folder.
    ///   - type: Type of link will be created. Can be file, folder or upload.
    ///   - accessibility: Determines who a link is accessible by. Can be anyone, password, domain or recipients.
    ///   - completion: Completion block with closure returning EgnyteLinkResponse or throwing an error.
    public init(apiClient: EgnyteAPIClient,
                path: String,
                type: EgnyteLinkType,
                accessibility: EgnyteLinkAccessibility,
                completion:@escaping (() throws -> EgnyteLinkResponse) -> Void){
        self.apiClient = apiClient
        self.path = path
        self.type = type
        self.accessibility = accessibility
        self.completion = completion
    }
    
    public func buildCreateLinkRequest() -> CreateLinkRequest {
        
        return CreateLinkRequest.init(apiClient: self.apiClient!,
                                      path: self.path,
                                      type: self.type,
                                      accessibility: self.accessibility,
                                      sendEmail: self.sendEmail,
                                      recipients: self.recipients,
                                      message: self.message,
                                      copyMe: self.copyMe,
                                      notify: self.notify,
                                      linkToCurrent: self.linkToCurrent,
                                      linkExpiry: self.linkExpiry,
                                      addFilename: self.addFilename,
                                      folderPerRecipient: self.folderPerRecipient,
                                      completion: self.completion)
    }
    
}
