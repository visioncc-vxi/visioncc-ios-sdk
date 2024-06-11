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
        .package(url: "https://github.com/longitachi/ZLPhotoBrowser.git", .upToNextMajor(from: "4.5.3"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "VisionCCLibraryTarget",
            dependencies: [
                "VisionCCiOSSDK",
                .product(name: "ZLPhotoBrowser", package: "ZLPhotoBrowser")
            ],
            path: "VisionCCLibrary"
        ),
        Target.sdk()
    ],
    swiftLanguageVersions: [
        .v5
    ]  
)