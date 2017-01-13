//
//  CreateLinkResponse.swift
//  EgnyteSDK
//
//  Created by MP0091 on 16.11.2016.
//  Copyright © 2016 Egnyte. All rights reserved.
//

import Foundation


/// Links provide a reference back to a file or folder in the Web UI or mobile app.
@objc public class EgnyteLink: NSObject {
    /// Unique idenftifer of the link.
    public let id: String
    /// Obscured url path to file or folder.
    public let urlPath: String
    /// E-mails addresses of recipients.
    public let recipients: [String]
    
    public init(id: String, urlPath: String, recipients: [String]) {
        self.id = id
        self.urlPath = urlPath
        self.recipients = recipients
    }
    
}

public extension EgnyteLink {
    
    convenience init(json:[String: Any]) throws {
        guard  let id = json["id"] as? String,
            let urlPath = json["url"] as? String,
            let recipients = json["recipients"] as? [String] else {
                
                throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponse", comment: "invalid response"))
        }
        
        self.init(id: id, urlPath: urlPath, recipients: recipients)
    }
}

/// Represents deep link type
@objc public enum EgnyteLinkType: Int {
    case file
    case folder
    case upload
    
    public func toString() -> String {
        switch self {
        case .file:
            return "file"
        case .folder:
            return "folder"
        case .upload:
            return "upload"
        }
    }
    
    static public func fromString(_ string: String) -> EgnyteLinkType {
        
        switch string.lowercased() {
        case "file":
            return .file
        case "folder":
            return .folder
        default:
            return .upload
        }
    }
}

/// Represents deep link accessibility type
@objc public enum EgnyteLinkAccessibility: Int {
    /// Anyone can access link content
    case anyone
    /// Only people who enter password can access link content
    case password
    /// Only domain users can access link content
    case domain
    /// Only listed users can access link
    case recipients
    
    public func toString() -> String {
        switch self {
        case .anyone:
            return "anyone"
        case .password:
            return "password"
        case .domain:
            return "domain"
        case .recipients:
            return "recipients"
        }
    }
    
    static public func fromString(_ string: String) -> EgnyteLinkAccessibility {
        
        switch string.lowercased() {
        case "anyone":
            return .anyone
        case "password":
            return .password
        case "domain":
            return .domain
        default:
            return .recipients
        }
    }
}

@objc public class EgnyteLinkResponse: NSObject {
    /// EgnyteLink array
    public let links: [EgnyteLink]
    /// Full path to file or folder specified by the link.
    public let path: String
    /// Ype of the link. Can be file, folder or upload.
    public let type: EgnyteLinkType
    /// Determines who a link is accessible by.
    public let accessibility: EgnyteLinkAccessibility
    /// A Boolean value indicating whether link creator will be notified via email when link is accessed.
    public let notify: Bool
    /// A Boolean value indicating whether link will always refer to current version of file. Only applicable for file links.
    public let linkToCurrent: Bool
    /// Timestamp describing date of link creation.
    public let creationTimestamp: TimeInterval
    /// A Boolean value indicating whether, link will be sent via email by Egnyte.
    public let sendMail: Bool
    /// A Boolean value indicating whether a copy of the link message will be sent to the link creator. Only applies if sendMail is true. Defaults to false.
    public let copyMe: Bool
    /// Link exipry. Can be set to clicks or date.
    public let expiry: LinkExpiry?
    /// If accessibility was set to password this property contains password required to preview link.
    public let password: String?
    
    
    public init(links: [EgnyteLink],
                path: String,
                type: EgnyteLinkType,
                accessibility: EgnyteLinkAccessibility,
                notify: Bool,
                linkToCurrent: Bool,
                creationTimestamp: TimeInterval,
                sendMail: Bool,
                copyMe: Bool,
                expiry: LinkExpiry?,
                password: String?) {
        self.links = links
        self.path = path
        self.type = type
        self.accessibility = accessibility
        self.notify = notify
        self.linkToCurrent = linkToCurrent
        self.creationTimestamp = creationTimestamp
        self.sendMail = sendMail
        self.copyMe = copyMe
        self.expiry = expiry
        self.password = password
    }
}

public extension EgnyteLinkResponse {
    
    convenience init(json: [String: Any]) throws {
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let linksData = json["links"] as? [[String: Any]],
            let path = json["path"] as? String,
            let type = json["type"] as? String,
            let accessibility = json["accessibility"] as? String,
            let notify = json["notify"] as? Bool,
            let linkToCurrent = json["link_to_current"] as? Bool,
            let dateString = json["creation_date"] as? String,
            let sendMail = json["send_mail"] as? Bool,
            let copyMe = json["copy_me"] as? Bool
            else {
                throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponse", comment: "invalid response"))
        }
        
        guard let date = dateFormatter.date(from: dateString) else {
            throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponseDateFormat", comment: "invalid date format in response"))
        }
        
        let timestamp = date.timeIntervalSince1970
        var links = [EgnyteLink]()
        for linkData in linksData {
            let link = try EgnyteLink.init(json: linkData)
            links.append(link)
        }
        
        var expiry: LinkExpiry?
        
        if let expiryDateString = json["expiry_date"] as? String {
            guard let expiryDate = dateFormatter.date(from: expiryDateString) else {
                throw EgnyteError.unexpectedResponse(description: NSLocalizedString("kInvalidResponseDateFormat", comment: "invalid date format in response"))
            }
            expiry = LinkDateExpiry.init(date: expiryDate)
        }else if let expiryClicks = json["expiry_clicks"] as? UInt {
            expiry = LinkClicksExpiry.init(clicks: expiryClicks)
        }
        
        self.init(links: links,
                  path: path,
                  type: EgnyteLinkType.fromString(type),
                  accessibility: EgnyteLinkAccessibility.fromString(accessibility),
                  notify: notify,
                  linkToCurrent: linkToCurrent,
                  creationTimestamp: timestamp,
                  sendMail: sendMail,
                  copyMe: copyMe,
                  expiry: expiry,
                  password: json["password"] as? String
        )
    }
    
}



