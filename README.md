# EgnyteSDK

SDK using Egnyte’s Public API for your iOS projects.

## Requirements

- iOS 8.0+
- Xcode 8.0+
- Swift 3.0+

## Integration

#### CocoaPods (iOS 8.0+)

You can use [CocoaPods](http://cocoapods.org/) to install `EgnyteSDK`by adding it to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'YourApp' do
	pod 'EgnyteSDK'
end
```

Note that this requires CocoaPods version 1.1.0+, and your iOS deployment target to be at least 8.0:

#### Manually (iOS 8.0+)

To use this library in your project manually you may:  

1. For Projects, just drag Egnyte.swift to the project tree
2. For Workspaces, include the whole EgnyteSDK.xcodeproj

## Getting started
Get an API key, as described in [Getting an API key](https://developers.egnyte.com/docs/read/Getting_Started#Getting-an-API-Key).
If you need a domain for development, you can get one, as described in [Get a free Partner Domain](https://developers.egnyte.com/docs/read/Getting_Started#Get-a-Free-Partner-Domain).

### Authentication

Import

```swift
import EgnyteSDK
```

Initialize AuthRequest. You will find API key and Shared Secret [here](https://developers.egnyte.com/apps/mykeys)

```swift
let authRequest = AuthRequest.init(apiKey: "API_KEY",
                         		   sharedSecret: "SHARED_SECRET")
```

Initialize LoginService

```swift
// myViewController will present the necessary UI for a user to authenticate into Egnyte
let loginService = LoginService.init(presentingViewController: myViewController)
```

Perform auth request

```swift
loginService.performAuthRequest(authRequest) { result in
            do {
                let authResult = try result()
                self.token = authResult.token
				self.domainURL = authResult.egnyteDomainURL
            } catch let error {
                // handle error
            }
        }
```

### Creating APIClient instance

Once you have EgnyteAuthResult object, you can create APIClient that's capable of executing requests. Note that you should use only one instance per Egnyte domain.

```swift
let apiClient = EgnyteAPIClient.init(domainURL: domainURL, token: token)
```

### Executing requests

Create request by passing to initializer APIClient and required parameters. Then call on it `enqueue` which enqueues request to be executed by apiClient.

```swift
let folderContentRequest = ListFolderContentRequest.init(apiClient: apiClient,
                                                         path: "/Shared") { response in
    do {
        let folderContent = try response()
        // handle result
    } catch let error {
        // handle error
    }
}
        
folderContentRequest.enqueue()
```

## Sample App

A sample app can be found in the [SampleApp](./SampleApp/SampleApp) folder. The sample app demonstrates how to authenticate a user, and search, list, delete, upload, share, download files and folders.

To execute the sample app:
Install Pods
```
cd SampleApp
pod install
```
Open Workspace
```
open SampleApp.xcworkspace
```

Replace API_KEY and SHARED_SECRET in [MainViewController](./SampleApp/SampleApp/MainViewController.swift) with your API Key and Shared Secret.
```swift
// MainViewController.swift
static let API_KEY = "your api key"
static let SHARED_SECRET = "your shared secret"
```

## Tests

Tests can be found in the 'EgnyteSDKTests' target. [Use Xcode to execute the tests](https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/05-running_tests.html).

## Copyright and License
Copyright 2017 Egnyte. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
