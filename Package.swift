// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
 
import PackageDescription

let package = Package(
    name: "VisionCCLibrary",
    defaultLocalization: "en",
    platforms: [
      .iOS(.v12)
    ],
    products: [
        .library(
            name: "VisionCCLibrary",
            targets: ["VisionCCiOSSDK"]),
    ],
    targets: [
        .binaryTarget(
            name: "VisionCCiOSSDK", 
            path: "VisionCCiOSSDK.xcframework"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]  
)