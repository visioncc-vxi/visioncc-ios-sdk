// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
 
import PackageDescription
 
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
        .package(url: "https://github.com/SVProgressHUD/SVProgressHUD.git", .upToNextMajor(from: "2.3.1")),
        .package(url: "https://github.com/realm/realm-swift.git", exact: "10.32.3"),
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
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "SVProgressHUD", package: "SVProgressHUD"),
            ],
            path: "VisionCCLibrary"
        ),
       .binaryTarget(
            name: "VisionCCiOSSDK", 
            url: "https://vcc-sdk.vxish.cn/sdk/xcode15.0.1/1.4.6/VisionCCiOSSDK.xcframework.zip",
            checksum: "5c77217c6c29598951cf4109bf161db99e1e5349ab8dac82d9d57234f4f621b9"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]  
)