
Pod::Spec.new do |s|
  s.name         = "VisionCCiOSSDK"
  s.version      = "1.0.6"
  s.summary      = "iOS SDK 是维音CC客服系统访客端的解决方案，既包含了客服聊天逻辑管理，也提供了聊天界面，开发者可方便的将客服功能集成到自己的 App 中"
  s.homepage     = "https://github.com/visioncc-vxi"
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author       = { "unpeng" => "unpeng@qq.com" }
  s.platform     = :ios, "12.0"
  s.swift_version = "5.0"
  s.source       = { :git => "https://github.com/visioncc-vxi/visioncc-ios-sdk.git", :tag => "#{s.version}" }
  s.framework    = "UIKit"
  s.source_files  = "Sources", "Sources/**/*.{swift}"
  s.requires_arc = true
  s.ios.vendored_frameworks  = 'https://vcc-sdk.vxish.cn/VisionCCiOSSDK.xcframework.zip'

  #外部依赖
  s.dependency 'RxSwift', '6.5.0'
  s.dependency 'Alamofire', '5.7.1'
  s.dependency 'SnapKit', '5.6.0'
  s.dependency 'RxSwift', '6.5.0'
  s.dependency 'RxCocoa', '6.5.0'
  s.dependency 'RealmSwift','10.47.0'
  s.dependency 'Socket.IO-Client-Swift', '~> 16.1.0'
  s.dependency 'JXSegmentedView', '1.2.7'

 #工程配置
  s.user_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  
end
