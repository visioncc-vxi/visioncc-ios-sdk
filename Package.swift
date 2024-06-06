// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
 
import PackageDescription

extension Target {
    static func sdk() -> Target {
        return .binaryTarget(
                name: "VisionCCiOSSDK", 
                path: "VisionCCiOSSDK.xcframework"
            )
    }
}

let package = Package(
    name: "VisionCCLibrary",
    defaultLocalization: "en",
    // 支持的平台和版本
    platforms: [
      .iOS(.v12)
    ],    
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "VisionCCLibraryTarget",
            targets: ["VisionCCLibraryTarget"]),
    ],
    dependencies: [
        .package(url: "https://github.com/socketio/socket.io-client-swift.git", .upToNextMinor(from: "16.1.0")),
        .package(url: "https://github.com/pujiaxin33/JXSegmentedView.git", .upToNextMinor(from: "1.2.7")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.7.1")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.5.0")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.6.0")),
        .package(url: "https://github.com/longitachi/ZLPhotoBrowser.git", .upToNextMajor(from: "4.5.3")),
        .package(url: "https://github.com/mchoe/SwiftSVG.git", .upToNextMajor(from: "2.3.2")),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", exact: "6.5.11"),
        .package(url: "https://github.com/RxSwiftCommunity/NSObject-Rx.git", .upToNextMajor(from: "5.2.2")),
        .package(url: "https://github.com/unpeng/Refresh.git", .upToNextMajor(from: "1.5.4")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "VisionCCLibraryTarget",
            dependencies: [
                "VisionCCiOSSDK",
                .product(name: "SocketIO", package: "socket.io-client-swift"),
                .product(name: "JXSegmentedView", package: "JXSegmentedView"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ZLPhotoBrowser", package: "ZLPhotoBrowser"),
                .product(name: "IQKeyboardManagerSwift", package: "IQKeyboardManager"),
                .product(name: "SwiftSVG", package: "SwiftSVG"),
                .product(name: "JRefresh", package: "MJRefreshSwift"),
                .product(name: "NSObject-Rx", package: "NSObject-Rx"),
            ],
            path: "VisionCCLibrary"
        ),
        Target.sdk()
    ],
    swiftLanguageVersions: [
        .v5
    ]  
)