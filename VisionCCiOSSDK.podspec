
Pod::Spec.new do |s|
  s.name         = "VisionCCiOSSDK"
  s.version      = "1.6.3"
  s.summary      = "VisionCCiOSSDK是维音CC客服系统在iOS平台访客端的解决方案，既包含了客服聊天逻辑管理，也提供了聊天界面，开发者可方便的将客服功能集成到自己的 App 中"
  s.homepage     = "https://git.vxish.cn/visioncc-vxi/visioncc-ios-sdk"
  s.license      = "MIT"
  s.author       = { "vxi" => "peng.wang@vxichina.com" }
  s.platform     = :ios, "12.0"
  s.swift_version = "5.0"
  s.source       = { :git => "https://git.vxish.cn/visioncc-vxi/visioncc-ios-sdk.git", :tag => "#{s.version}" }
  s.framework    = "UIKit"
  s.requires_arc = true
  s.ios.vendored_frameworks  = 'VisionCCiOSSDK.xcframework'

  #外部依赖
  s.dependency 'RxSwift', '6.5.0'
  s.dependency 'Alamofire', '5.7.1'
  s.dependency 'SnapKit', '5.6.0'
  s.dependency 'RxCocoa', '6.5.0'
  s.dependency 'Starscream','4.0.6'
  s.dependency 'Socket.IO-Client-Swift', '~> 16.1.0'
  s.dependency 'JXSegmentedView', '1.2.7'
  s.dependency 'NSObject+Rx', '5.2.2'
  s.dependency 'SwiftSVG', '~> 2.3.2'
  s.dependency 'ZLPhotoBrowser', '4.5.3'
  s.dependency 'MJRefreshSwift', '1.5.14'
  s.dependency 'IQKeyboardManagerSwift', '6.5.11'

 #工程配置
  s.user_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  
end
