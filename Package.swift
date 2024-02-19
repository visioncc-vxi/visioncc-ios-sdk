// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VisionCCiOSSDKPackage",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "VisionCCiOSSDKPackage",
            type: .dynamic,
            targets: ["VisionCCiOSSDKPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/socketio/socket.io-client-swift", .upToNextMinor(from: "16.1.0")),
        .package(url: "https://github.com/pujiaxin33/JXSegmentedView.git", .upToNextMinor(from: "1.2.7")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.7.1")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.5.0")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.6.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "VisionCCiOSSDKPackage"
        ),
        .binaryTarget(
            name: "VisionCCiOSSDK", //二进制库的名称
            url: "https://vcc-sdk.vxish.cn/VisionCCiOSSDK.xcframework.zip", // 二进制库的下载链接 上一步生成的
            checksum: "e28bee98703efd680cf1642c2ef78183515d0d3d614f8a29643e0100d417dfaf" // 二进制库的校验和 上一步生成的
        ),
        .testTarget(
            name: "VisionCCiOSSDKPackageTests",
            dependencies: ["VisionCCiOSSDKPackage"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
