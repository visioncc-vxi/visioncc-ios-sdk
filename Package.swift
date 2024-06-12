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
            name: "VisionCCLibrary",
            targets: ["VisionCCLibraryTarget"]),
    ],
    dependencies: [
        .package(url: "https://github.com/longitachi/ZLPhotoBrowser.git", .upToNextMajor(from: "4.5.3")),
        .package(url: "https://github.com/unpeng/MJRefreshSwift.git", .upToNextMajor(from: "1.5.6"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "VisionCCLibraryTarget",
            dependencies: [
                "VisionCCiOSSDK"
            ],
            path: "VisionCCLibrary"
        ),
        .binaryTarget(
            name: "VisionCCiOSSDK", 
            path: "VisionCCiOSSDK.xcframework"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]  
)