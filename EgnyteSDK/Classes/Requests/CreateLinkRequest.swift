//
//  CreateLinkRequest.swift
//  EgnyteSDK
//
//  Created by Adam Kędzia on 15.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import Foundation

/// Request for creating a shared file or folder link.
@objc public class CreateLinkRequest: EgnyteBaseRequest {
    
    /// Initialize CreateLinkRequest.
    ///
    /// - Parameters:
    ///   - apiClient: EgnyteAPIClient which performs and authorize request.
    ///   - path: The absolute path of the target file or folder.
    ///   - type: This defines the type of link created. It can be a link for files, folders or an upload link.
    ///   - accessibility: Determines who a link is accessible by. Can be anyone, password, domain or recipients.
    ///   - sendEmail: Boolean value indicating whether  whether you want the link to be sent via email, through Egnyte or not.
    ///   - recipients: If you want the link to be shared by Egnyte, provide an array of email addresses for the recipients. **sendEmail** needs to be set as true.
    ///   - message: Personal message to be sent in link email. **sendEmail** needs to be set as true.
    ///   - copyMe: Boolean value indicating whether a copy of the link message will be sent to the link creator. Only applies if **sendEmail** is *true*. Defaults to *false*.
    ///   - notify: Boolean value indicating whether link creator will be notified when the shared link is accessed. Creator will be notified by email.
    ///   - linkToCurrent: Boolean value indicating whether link will always refer to current version of file. Only applicable for file links.
    ///   - linkExpiry: Expiry type of the link. Can be set to date or clicks.
    ///   - addFilename: Boolean value indicating whether filename will be appended to the end of the link. Only applies to file links, not folder links.
    ///   - folderPerRecipient: Boolean value indicating whether each recipient's uploaded data will be put into a separate folder. Only applies to upload links.
    ///   - completion: Completion block with closure returning EgnyteLinkResponse or throwing an error.
    public init(apiClient: EgnyteAPIClient,
                path: String,
                type: EgnyteLinkType,
                accessibility: EgnyteLinkAccessibility,
                sendEmail: Bool? = nil,
                recipients: [String]? = nil,
                message: String? = nil,
                copyMe: Bool? = nil,
                notify: Bool? = nil,
                linkToCurrent: Bool? = nil,
                linkExpiry: LinkExpiry?,
                addFilename: Bool? = nil,
                folderPerRecipient: Bool? = nil,
                completion:@escaping (@escaping () throws -> EgnyteLinkResponse) -> Void) {
                
        var expiryDateString: String?
        var expiryClicksCount: UInt?
        if let expiryDate = linkExpiry as? LinkDateExpiry {
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            expiryDateString = dateFormatter.string(from: expiryDate.date)
        } else if let expiryClicks = linkExpiry as? LinkClicksExpiry {
            expiryClicksCount = expiryClicks.clicks
        }
     
        var params = ["path": path,
                      "type": type.toString(),
                      "accessibility": accessibility.toString()] as [String: Any]
        params["send_email"] = sendEmail
        params["recipients"] = recipients
        params["message"] = message
        params["copy_me"] = copyMe
        params["notify"] = notify
        params["link_to_current"] = linkToCurrent
        params["expiry_date"] = expiryDateString
        params["expiry_clicks"] = expiryClicksCount
        params["add_file_name"] = addFilename
        params["folder_per_recipient"] = folderPerRecipient

        try! super.init(apiClient: apiClient,
                        endpoint: "/pubapi/v1/links",
                        filepath: nil,
                        method: "POST",
                        parameters: params) { result in
                            
                            do {
                                let data = try result()
                                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                                let linkResponse = try CreateLinkRequest.parse(data: json)
                                completion({return linkResponse})
                            }catch let error {
                                completion({throw error})
                            }
        }
    }
    
    static func parse(data: Any?) throws -> EgnyteLinkResponse {
        guard let json = data as? [String: Any] else {
            throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponse", comment: "invalid response"))
        }
        
        return try EgnyteLinkResponse.init(json: json)
    }
    
}
