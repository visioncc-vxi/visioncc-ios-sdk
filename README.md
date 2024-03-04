打包脚本

```
xcodebuild clean \
    -scheme VisionCCiOSSDK

xcodebuild archive \
  -scheme VisionCCiOSSDK \
  -configuration Release \
  -sdk iphoneos \
  -destination='generic/platform=iOS' \
  -archivePath "archives/ios-device" \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO \
  OTHER_SWIFT_FLAGS="-no-verify-emitted-module-interface"

xcodebuild archive \
  -scheme VisionCCiOSSDK \
  -configuration Release \
  -sdk iphonesimulator \
  -destination='generic/platform=iOS Simulator' \
  -archivePath "archives/ios-simulator" \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO \
  OTHER_SWIFT_FLAGS="-no-verify-emitted-module-interface"

xcodebuild -create-xcframework \
  -framework archives/ios-device.xcarchive/Products/Library/Frameworks/VisionCCiOSSDK.framework \
  -framework archives/ios-simulator.xcarchive/Products/Library/Frameworks/VisionCCiOSSDK.framework \
  -output archives/VisionCCiOSSDK.xcframework

```
