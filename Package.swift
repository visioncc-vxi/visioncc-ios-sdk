// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VisionCCLibrary",
    defaultLocalization: "en",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "VisionCCLibrary",
            targets: ["VisionCCiOSSDK"]),
    ],
    dependencies: [
        .package(name: "socket.io-client-swift", url: "https://github.com/socketio/socket.io-client-swift.git", .upToNextMinor(from: "16.1.0")),
        .package(name: "JXSegmentedView", url: "https://github.com/pujiaxin33/JXSegmentedView.git", .upToNextMinor(from: "1.2.7")),
        .package(name: "Alamofire", url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.7.1")),
        .package(name: "RxSwift", url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.5.0")),
        .package(name: "SnapKit", url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.6.0")),
        .package(name: "realm-swift", url: "https://github.com/realm/realm-swift.git", .upToNextMajor(from: "10.47.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        //.binaryTarget(name: "VisionCCiOSSDK", path: "VisionCCiOSSDK.xcframework"),
        .binaryTarget(
            name: "VisionCCiOSSDK", 
            url: "https://vcc-sdk.vxish.cn/VisionCCiOSSDK-1.0.7.1.xcframework.zip",
            checksum: "98bcbc7851db75e0fe0016e54910a7c56e6ed3da1621f9b5607246442816c0ff"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]    
)
