// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
 
import PackageDescription
import Foundation

func runCommand() -> String {
    let task = Process()
    let pipe = Pipe()
    let base = "15.0.1"
    task.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")
    task.arguments = ["-version"]
    task.standardInput = nil
    task.standardError = nil
    task.standardOutput = pipe

    do {
        try task.run()
    } catch {
        return base
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    let range = NSRange(output.startIndex..., in: output)

    let pattern = #"(\d+\.\d+(\.\d+)?(\.\d+)?)\b"#
    guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
          let firstMatch = regex.matches(in: output, range: range).first else {
        return base
    }

    let versionRange = firstMatch.range(at: 1)
    if let range = Range(versionRange, in: output) {
        let version = output[range]
        return String(version)
    } else {
        return base
    }
}

extension Target {
    static func sdk() -> Target {
        let result = runCommand()
        return .binaryTarget(
                name: "VisionCCiOSSDK", 
                path: "Framework/\(result)/VisionCCiOSSDK.xcframework"
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
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.6.0"))
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
                .product(name: "RxCocoa", package: "RxSwift")
            ],
            path: "VisionCCLibrary"
        ),
        Target.sdk()
    ],
    swiftLanguageVersions: [
        .v5
    ]  
)