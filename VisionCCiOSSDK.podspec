
Pod::Spec.new do |s|
  s.name         = "VisionCCiOSSDK"
  s.version      = "2.0.2"
  s.summary      = "VisionCCiOSSDK是维音CC客服系统在iOS平台访客端的解决方案，既包含了客服聊天逻辑管理，也提供了聊天界面，开发者可方便的将客服功能集成到自己的 App 中"
  s.homepage     = "https://github.com/visioncc-vxi/visioncc-ios-sdk"
  s.license      = "MIT"
  s.author       = { "vxi" => "esbu@vxichina.com" }
  s.platform     = :ios, "12.0"
  s.swift_version = "5.0"
  s.source       = { :git => "https://github.com/visioncc-vxi/visioncc-ios-sdk.git", :tag => "#{s.version}" }
  s.framework    = "UIKit"
  s.requires_arc = true
  s.ios.vendored_frameworks  = 'VisionCCiOSSDK.xcframework'

 #工程配置
  s.user_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  
end
