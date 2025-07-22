<H1 align="center">VisionCCiOSSDK</H1>

<p align="center">
    <img src="https://img.shields.io/github/license/visioncc-vxi/visioncc-ios-sdk.svg" alt="GitHub license"/>
</p>

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/visioncc-vxi/visioncc-ios-sdk)
[![Swift](https://img.shields.io/badge/Swift-5.6_5.7_5.8_5.9_5.10_6.0-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.6_5.7_5.8_5.9_5.10_6.0-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-iOS-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-iOS-Green?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
[![Github tag](https://img.shields.io/github/tag/visioncc-vxi/visioncc-ios-sdk.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/v/VisionCCiOSSDK.svg)](http://cocoadocs.org/docsets/VisionCCiOSSDK)


## Overview

The VisionCCiOSSDK is an iOS framework that enables communication capabilities within iOS applications. This document provides a high-level introduction to the SDK's purpose, architecture, and key components, with special emphasis on its WebView-based implementation approach.

## Purpose and Scope

VisionCCiOSSDK provides a communication framework that allows iOS applications to implement customer communication features. The SDK has evolved from a native implementation to a WebView-based architecture to enable more dynamic content delivery, faster updates without requiring app releases, and improved cross-platform compatibility.

## Key Features

- WebView-based architecture for dynamic content delivery
- Support for rich communication features
- Offline caching mechanisms for improved performance
- Simple integration via CocoaPods or Swift Package Manager
- Support for iOS 14.0 and above
- Cross-platform compatibility through H5 technologies

## WebView vs. Native Architecture

The SDK has transitioned from a fully native implementation to a WebView-based approach, which offers several advantages:

### Architecture Benefits

| Feature| Native Architecture| WebView Architecture|
| ---| ---| ---|
| Update Mechanism| Requires app update| Server-side updates|
| Iteration Speed| Slow (App Store review)| Fast (immediate)|
| Cross-platform Compatibility| Limited| Excellent|
| Content Management| Static| Dynamic|
| System Integration| Deep| Moderate with JS bridge|
| Performance| Higher| Optimized with caching|


## Core Components

### CCKFApi

The `CCKFApi` class is the main interface between the host application and the SDK. It's a subclass of `UIViewController` that manages the WebView and provides methods for communication.

### Architecture
![00e5e970-fb66-4bd0-8122-aaa66654a2b1](https://github.com/user-attachments/assets/c2956356-4c76-48a9-905c-d7961878841d)


## Installation and Setup

VisionCCiOSSDK in your iOS project. The SDK can be integrated using either CocoaPods or Swift Package Manager (SPM)

## Requirements

Before installing the VisionCCiOSSDK, ensure your development environment meets the following requirements:

- iOS 14.0+ (as specified in the podspec)
- Swift 5.0+
- Xcode 11.0+ (for Swift Package Manager support)

## Installation Methods

The VisionCCiOSSDK supports two installation methods: CocoaPods and Swift Package Manager. The following diagram illustrates the installation workflow for both methods:


### Installation with CocoaPods

CocoaPods is a dependency manager for Swift and Objective-C Cocoa projects. Follow these steps to install VisionCCiOSSDK using CocoaPods:

1. If you haven't installed CocoaPods yet, install it by running the following command in Terminal:

   ```bash
   sudo gem install cocoapods
   ```

2. Create a `Podfile` in your project directory if you don't have one:

   ```bash
   pod init
   ```

3. Add the VisionCCiOSSDK to your Podfile:

   ```ruby
   pod 'VisionCCiOSSDK'
   ```

4. If you need a specific version, specify it in your Podfile:

   ```ruby
   pod 'VisionCCiOSSDK', '2.1.4'
   ```

5. Install the dependencies:

   ```bash
   pod install
   ```

6. Open the generated `.xcworkspace` file instead of your project file.

7. Import the SDK in your Swift code:

   ```swift
   import VisionCCiOSSDK
   ```

### Installation with Swift Package Manager

Swift Package Manager (SPM) is integrated with Xcode and provides a native experience for managing dependencies. Follow these steps to install VisionCCiOSSDK using SPM:

1. Open your Xcode project.

2. Go to `File` → `Swift Packages` → `Add Package Dependency...`

3. Enter the repository URL:

   ```plaintext
   https://github.com/visioncc-vxi/visioncc-ios-sdk.git
   ```

4. Select the version rule:
   - Exact: Choose a specific version (e.g., 2.1.4)
   - Up to Next Major: Updates up to (but not including) the next major version
   - Up to Next Minor: Updates up to (but not including) the next minor version
   - Branch/Commit: Specific branch or commit

5. Select the VisionCCiOSSDK target where you want to use the package.

6. Click `Finish`.

7. Import the SDK in your Swift code:

   ```swift
   import VisionCCiOSSDK
   ```


## SDK Integration

After installing the SDK using either method, you need to integrate it into your iOS application. The following diagram illustrates how the SDK components are integrated into your application:


## Verification

To verify that the SDK has been successfully installed, you can perform these steps:

1. Import the SDK in a Swift file:

   ```swift
   import VisionCCiOSSDK
   ```

2. Try to access the main class:

   ```swift
   let api = CCKFApi()
   ```

If no compilation errors occur, the SDK has been successfully installed.

## Core SDK Methods

#### Initialization and Session Management
1. `initSDK(host:entryId:appkey:userMappings:needRealtimePush:)`
   
    Initializes the SDK with connection parameters and user information.


    **Parameters**:
    - `host: String` - VisionCC server host URL
    - `entryId: String` - Entry point identifier for the conversation
    - `appkey: String` - Application authentication key
    - `userMappings: UserMappingModel` - User identity and device information
    - `needRealtimePush: Bool` - Enable real-time push notifications (default: true)

2. `startSession(host:entryId:appkey:userMappings:needRealtimePush:callBack:)`
   
    Starts a new communication session with the specified parameters.


    **Parameters**:
    - `host: String` - VisionCC server host URL
    - `entryId: String` - Entry point identifier
    - `appkey: String` - Application authentication key
    - `userMappings: UserMappingModel` - User identity information
    - `needRealtimePush: Bool` - Enable real-time push (default: false)
    - `callBack: (() -> Void)?` - Optional completion callback

3. `getUnreadCount(host:entryId:appkey:userMappings:completion:)`
   
    Retrieves the count of unread messages for the user.

   
    **Parameters**:
    - `host: String` - VisionCC server host URL
    - `entryId: String` - Entry point identifier
    - `appkey: String` - Application authentication key
    - `userMappings: UserMappingModel` - User identity information
    - `completion: @escaping (Result<Int, Error>) -> Void` - Completion handler with unread count or error 


4. `sendMessage(msgType:msgBody:)`
   
    Sends a message through the communication channel.

   
    **Parameters**:
    - `msgType: Int` - Message type identifier
    - `msgBody: MessageBody` - Message content and metadata

## Delegate Protocols

The `CCKFApiConversationDelegate` protocol is the primary interface that host applications implement to receive events from the SDK. This protocol defines three essential methods for handling conversation-related events.


### Protocol Definition

![image](https://github.com/user-attachments/assets/09f81749-2d99-47e8-8c87-97999c5bb4ee)

### Delegate Protocol Methods

| Method | Purpose | Parameters |
| ---- | ---- | ---- |
| `unReadMessageCountEvent(count:)` | Notifies when unread message count changes | count: Current unread message count |
| `trackEvent(name:attributes:)` | Reports user interaction and analytics events | name: Event name, attributes: Event metadata |
| `newMessageEvent(entryId:msgId:message:)` | Signals arrival of new messages | entryId: Entry identifier, msgId: Message ID, message: Message content |

### Implementation Pattern

Applications typically implement this delegate to update UI components, handle notifications, and track user engagement:

![image](https://github.com/user-attachments/assets/f005abd4-d237-4017-880e-40d704a91529)

### Integration Example

Below is a simplified integration example showing how to use the CCKFApi class in an iOS application:

```swift
import UIKit
import VisionCCiOSSDK

class ChatViewController: UIViewController, CCKFApiConversationDelegate {
    
    private var cckfApi: CCKFApi?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the API
        cckfApi = CCKFApi()
        cckfApi?.conversionDelegate = self
        
        // Create user mapping
        let userMapping = UserMappingModel(
            identity_id: "user123",
            visitor_name: "John Doe",
            app_id: "app id",
            env_name: "test"
        )
        
        // Configure and start session
        cckfApi?.startSession(
            host: "https://api.example.com",
            entryId: "entry123",
            appkey: "your-app-key",
            userMappings: userMapping
        )
        
        // Add the CCKFApi view controller as a child
        if let cckfApiVC = cckfApi {
            addChild(cckfApiVC)
            view.addSubview(cckfApiVC.view)
            cckfApiVC.view.frame = view.bounds
            cckfApiVC.didMove(toParent: self)
        }
    }
    
    // MARK: - CCKFApiConversationDelegate
    
    func unReadMessageCountEvent(count: Int) {
        print("Unread message count: \(count)")
    }
    
    func trackEvent(name: String, attributes: [String : String]) {
        print("Tracking event: \(name), attributes: \(attributes)")
    }
    
    func newMessageEvent(entryId: String, msgId: Int, message: String) {
        print("New message: \(message)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cckfApi?.close()
    }
}
```

Or (Simply/Just) fetch the unread message count  

```swift
import UIKit
import VisionCCiOSSDK

class ChatViewController: UIViewController, CCKFApiConversationDelegate {
    
    private var cckfApi: CCKFApi?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the API

        cckfApi = CCKFApi()

        // Create user mapping
        let userMapping = UserMappingModel(
            identity_id: "user123",
            visitor_name: "John Doe",
            app_id: "appid",
            env_name: "test"
        )

        // Get the count of unread messages
        cckfApi?.getUnreadCount(
                    host: "https://api.example.com",
                    entryId: "entry123",
                    appkey: "your-app-key",
                    userMappings: userMapping){ result in
                            switch result {
                            case .success(let count):
                                print(count)
                                // Successfully fetched the unread count; `count` contains the value from the server
                                // Update UI or perform business logic (e.g., show badge, sync data, etc.)
                            case .failure(let error):
                                print(error.localizedDescription)
                                // Failed to fetch unread count; `error` contains the failure details
                                // Handle error (e.g., display alert, log error, retry mechanism, etc.)
                            }
                    }
}
```


## Troubleshooting

### Common CocoaPods Issues

1. **Pod not found**:
   - Ensure your Podfile contains the correct pod name: `pod 'VisionCCiOSSDK'`
   - Run `pod repo update` before `pod install`
   - Check your internet connection

2. **Version conflicts**:
   - Try using a specific version: `pod 'VisionCCiOSSDK', '2.1.4'`
   - Make sure your iOS deployment target is at least 14.0 (as specified in the podspec)

3. **Build errors after installation**:
   - Ensure you're opening the `.xcworkspace` file, not the `.xcodeproj` file
   - Clean the build folder (Cmd+Shift+K) and rebuild

### Common Swift Package Manager Issues

1. **Package resolution failure**:
   - Check your internet connection
   - Verify the repository URL is correct
   - Try using a specific version rather than a branch

2. **Integration issues**:
   - Make sure the package is added to your target dependencies
   - Clean the build folder (Cmd+Shift+K) and rebuild
   - In Xcode, go to `File` → `Packages` → `Reset Package Caches`

## Next Steps

Once you've successfully installed the SDK, proceed to learn about the main SDK components and how to initialize it in your application. For more information about the SDK's core components.



## Platform Support

VisionCCiOSSDK is built as an XCFramework that supports:

- iOS devices (arm64)
- iOS simulators (arm64, x86_64)
- Minimum iOS version: 14.0


## Performance Optimization

To ensure optimal performance despite the WebView architecture, the SDK implements:

1. **Offline Caching**: H5 resources are cached locally to reduce loading times
2. **Resource Preloading**: Essential resources are loaded proactively
3. **Optimized JavaScript Bridge**: Efficient native-to-web communication


## Permissions

The SDK requires various permissions that may need to be included in your app's Info.plist:

- Camera access for image capture
- Microphone access for audio recording
- Photo Library access for image selection


## Conclusion

VisionCCiOSSDK provides a flexible, updatable communication framework for iOS applications through its WebView-based architecture. This approach enables faster iterations, cross-platform compatibility, and dynamic content management while maintaining a native-like user experience through performance optimizations.

For more detailed information about specific components and usage, please refer to the relevant sections in this documentation.



LICENSE
---
Distributed under the MIT License.

Contributions
---
Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.

Author
---
If you wish to contact me, email at: esbu@vxichina.com

