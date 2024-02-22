//
//  VXIConfig.swift
//  Tool
//
//  Created by CQP-MacPro on 2023/12/19.
//

import UIKit
@_implementationOnly import VisionCCiOSSDKEngine


//MARK: - UI配置
/// UI配置
struct VXIUIConfig {
    
    static let shareInstance = VXIUIConfig.init()
    
    /// 获取Screen的Size
    let YLScreenWidth  = UIScreen.main.bounds.width
    let YLScreenHeight = UIScreen.main.bounds.height
    
    let K_APP_RANDOM_ARRAY = [
        "a", "b", "c", "d", "e", "f", "g","h", "i", "j", "k", "m", "n","o", "p",
        "q", "r", "s", "t","u", "v","w", "x", "y", "z","A", "B", "C", "D", "E", "F",
        "G","H", "I", "J", "K", "L", "M", "N","O", "P", "Q", "R","S","T","U", "V", "W",
        "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    
    /// 获取当前Bundle
    /// - Returns: Bundle
    func getBundle() -> Bundle? {
        var bundleName = self.getConfigBundleName()
        let podName = "VisionCCiOSSDK"
        
        if bundleName.contains(".bundle") {
            bundleName = bundleName.components(separatedBy: ".bundle").first ?? "VisionCCiOSSDK"
        }
        
        //没使用framwork的情况下
        var associateBundleURL:URL? = Bundle.main.url(forResource: bundleName, withExtension: "bundle")
        
        //使用framework形式
        if associateBundleURL == nil {
            associateBundleURL = Bundle.main.url(forResource:"Frameworks", withExtension: nil)
            associateBundleURL = associateBundleURL?.appendingPathComponent(podName)
            associateBundleURL = associateBundleURL?.appendingPathExtension("framework")
            if associateBundleURL != nil,let associateBunle = Bundle.init(url: associateBundleURL!) {
                associateBundleURL = associateBunle.url(forResource: bundleName, withExtension: "bundle")
            }
        }
        
        var _bundle:Bundle? = (associateBundleURL != nil) ? Bundle.init(url: associateBundleURL!) : nil
        if _bundle == nil {
            _bundle = Bundle.init(identifier: "com.vxi.cckf")
        }
        
        if _bundle == nil {
            debugPrint("取不到关联bundle")
        }
        return _bundle
    }
    
    /// 资源包名称
    func getConfigBundleName() -> String {
        return "VisionCCiOSSDK"
    }
    
    /// 第三方库初始化设置
    func initConfigThreadLabs(){
        //初始设置
        //SVProgressHUD.setDefaultStyle(.dark)
        
        //键盘开启
        if IQKeyboardManager.shared.enable == false {
            IQKeyboardManager.shared.enable = true
        }
        
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.registerTextFieldViewClass(YYTextView.self,
                                                            didBeginEditingNotificationName: Notification.Name.YYTextViewTextDidBeginEditing.rawValue,
                                                            didEndEditingNotificationName: Notification.Name.YYTextViewTextDidEndEditing.rawValue)
        
        // 控制键盘上的工具条文字颜色是否用户自定义
        IQKeyboardManager.shared.shouldToolbarUsesTextFieldTintColor = true
        // 有多个输入框时，可以通过点击Toolbar 上的“前一个”“后一个”按钮来实现移动到不同的输入框
        IQKeyboardManager.shared.toolbarManageBehaviour = .bySubviews
        // 控制是否显示键盘上的工具条
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        // 控制点击背景是否收起键盘
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        // 是否显示占位文字
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true
    }
    
    
    //MARK: - 网络请求相关
    /// 加载信息
    /// - Returns: <#description#>
    func appLoadInfo() -> String {
        return "请求处理中..."
    }
    
    /// 请求超时时间(单位：秒)
    /// - Returns: <#description#>
    func appRequestTimeOut() -> TimeInterval {
        return TimeInterval.init(100)
    }
    
    /// 网络请求的支持类型
    /// - Returns: <#description#>
    func appAcceptableContenttypes() -> Set<String> {
        return ["application/json", "text/json", "text/javascript","text/plain","text/html","application/x-www-form-urlencoded","multipart/form-data"]
    }
    
    /// 登录令牌信息存储Key
    /// - Returns: <#description#>
    func appUserLoginToken() -> String {
        return "VXI.app.user.login.token"
    }
    
    /// 令牌key
    func userToken() -> String {
        return "x-entry"
    }
    
    /// 设备编号
    func userDeviceId() -> String {
        return "x-device-id"
    }
    
    /// 状态码
    func apiResultCode() -> String { return "status" }
    
    /** 接口返回的描述信息键 */
    func apiResultMessage() -> String { return "title"}
    
    /** 网络请求状态判断 */
    func apiIsOk(rs:Any?) -> Bool {
        guard let _rt:Int = rs as? Int else {
            return false
        }
        
        //表示成功
        return _rt == 200 || _rt == 204
    }
    
    /** 请求证书设置 */
    func requestOption() -> YYWebImageOptions {
        return [.progressiveBlur,.allowInvalidSSLCertificates]
    }
    
    
    // MARK: - 当前window
    /// 当前window
    func keyWindow() -> UIWindow {
        if Thread.current.isMainThread == false {
            if #available(iOS 15.0, *) {
                let keyWindow = UIApplication.shared.connectedScenes
                    .map({ $0 as? UIWindowScene })
                    .compactMap({ $0 })
                    .first?.windows.first ?? UIWindow()
                return keyWindow
            }else {
                let keyWindow = UIApplication.shared.windows.first ?? UIWindow()
                return keyWindow
            }
        }
        else{
            if #available(iOS 15.0, *) {
                let keyWindow = UIApplication.shared.connectedScenes
                    .map({ $0 as? UIWindowScene })
                    .compactMap({ $0 })
                    .first?.windows.first ?? UIWindow()
                return keyWindow
            }else {
                let keyWindow = UIApplication.shared.windows.first ?? UIWindow()
                return keyWindow
            }
        }
    }
    
    /// 顶部安全区高度
    func xp_safeDistanceTop() -> CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.top
        }
        return 0
    }
    
    /// 底部安全区高度
    func xp_safeDistanceBottom() -> CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        }
        return 0
    }
    
    /// 顶部状态栏高度（包括安全区）
    func xp_statusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height
        
    }
    
    /// 导航栏高度
    func xp_navigationBarHeight() -> CGFloat {
        return 44.0
    }
    
    /// 顶部附加视图高度
    func topAdditionalViewHeight() -> CGFloat {
        return 44
    }
    
    /// 状态栏+导航栏的高度
    func xp_navigationFullHeight() -> CGFloat {
        return xp_statusBarHeight() + xp_navigationBarHeight()
    }
    
    /// 底部导航栏高度
    func xp_tabBarHeight() -> CGFloat {
        return 49.0
    }
    
    /// 底部导航栏高度（包括安全区）
    func xp_tabBarFullHeight() -> CGFloat {
        return xp_tabBarHeight() + xp_safeDistanceBottom()
    }
    
    /// VC背景颜色
    func appViewControlelrBackgroundColor() -> UIColor {
        let _c:String = TGSUIModel.getThemColorsConfig()?.cckf_chat_status_bar_color ?? "#FFFFFF"
        return .init().colorFromHexString(hex: _c)
    }
    
    /// 页面底部背景色
    func appViewBottomBackgroundColor() -> UIColor {
        let _c:String = TGSUIModel.getThemColorsConfig()?.cckf_chat_bottom_bgColor ?? "#FFFFFF"
        return .init().colorFromHexString(hex: _c)
    }
    
    /// 状态栏颜色
    func appViewStatusBarColor() -> UIColor {
        let _c:String = TGSUIModel.getThemColorsConfig()?.cckf_app_status_bar_color ?? "#FFFFFF"
        return .init().colorFromHexString(hex: _c)
    }
    
    /// app主题色
    func appTintColor() -> UIColor {
        return .blue
    }
    
    /// 设置导航样式
    /// - Parameters:
    ///   - isHidden: <#isHidden description#>
    ///   - _vc: <#_vc description#>
    ///   - _bgc: 背景色(默认VC的背景色)
    func appSetNavigationeStyleFor(Hidden isHidden:Bool = true,
                                   andViewController _vc:UIViewController?,
                                   withBackgroundColor _bgc:UIColor = VXIUIConfig.shareInstance.appViewStatusBarColor()){
        let _nav:UINavigationController? = _vc?.navigationController
        
        if isHidden == false {
            let _img:UIImage? = TGSUIModel.createImageFor(Color: _bgc,
                                                          andSize: .init(width: VXIUIConfig.shareInstance.YLScreenWidth, height: xp_navigationBarHeight()))
            _nav?.navigationBar.setBackgroundImage(_img, for: .defaultPrompt)
            _nav?.toolbar.backgroundColor = _bgc
        }
        _nav?.navigationBar.isTranslucent = false
        _nav?.isNavigationBarHidden = isHidden
        _nav?.navigationBar.isHidden = isHidden
        _nav?.toolbar.isHidden = isHidden
        
    }
    
    
    /// 缓存目录
    func getCachePath() -> String {
        //包名
        let bundleIdentifier = Bundle.main.infoDictionary?["CFBundleIdentifier"]
        
        return String.init(format: "%@/%@", NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last!,bundleIdentifier as! CVarArg)
    }
    
    func pageName() -> String {
        if let _cn = TGSUIModel.getSystemInfoModel(key: VXIUIConfig.shareInstance.getGlobalCgaKey())?.guest?.companyName,_cn.isEmpty == false {
            return _cn
        }
        return "维音"
    }
    
    //MARK: 消息
    /// 获取客户端消息编号
    func getClientMIdFor(Mid _mid:String?) -> String {
        return (_mid == nil || _mid?.isEmpty == true) ? NSUUID().uuidString : _mid!
    }
    
    /// 未读消息处理时间间隔或变动个数(单位：秒/个)
    func getThrottleTimeinterval() -> Int {
        return 5
    }
    
    /// 消息时间颜色
    func messageTimeTextColor() -> UIColor {
        return UIColor.colorFromRGB(0x9E9E9E)
    }
    
    /// 消息时间字体
    func messageTimeTextFont() -> UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    //MARK: 气泡
    /// 气泡消息圆角
    func bubbleCornerRadius() -> CGFloat {
        return 4
    }
    
    /// 气泡内边距
    func bubbleEdgeInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: 30, left: 28, bottom: 85, right: 28)
    }
    
    /// 己方气泡背景色
    func bubbleOwnBackgroundcolor() -> UIColor {
        let _c:String = TGSUIModel.getThemColorsConfig()?.cckf_chat_right_bgColor ?? "#95EC6A"
        return .init().colorFromHexString(hex: _c)
    }
    
    /// 对方气泡背景色
    func bubbleOthersideBackgroundcolor() -> UIColor {
        let _c:String = TGSUIModel.getThemColorsConfig()?.cckf_chat_left_bgColor ?? "#FFFFFF"
        return .init().colorFromHexString(hex: _c)
    }
    
    /// 内容与气泡底部间距
    func cellBottonContentMargin() -> CGFloat {
        return 10
    }
    
    /// 图像距离列顶部间距
    func cellTopBubbleMargin() -> CGFloat {
        return 12
    }
    
    //MARK: 列
    /// 列消息条数
    func cellPageSize() -> Int {
        return 50
    }
    
    /// 列最大宽度
    func cellMaxWidth() -> CGFloat {
        return VXIUIConfig.shareInstance.YLScreenWidth - 2 * (cellUserImageSize().width + cellUserLeftOrRightMargin() + cellLeftOrRightContentMargin())
    }
    
    /// 图片转换率
    func imageCompressionQuality() -> Double {
        return 0.75
    }
    
    /// 列背(聊天)景色
    func cellBackgroundColor() -> UIColor? {
        let _c:String = TGSUIModel.getThemColorsConfig()?.cckf_chat_back_all ?? "#F4F4F4"
        return UIColor.init().colorFromHexString(hex: _c)
    }
    
    /// 列图片默认背景色
    func cellImageDefaultBackgroudColor() -> UIColor {
        return .lightGray
    }
    
    /// 列分割线颜色
    func cellSplitColor() -> UIColor {
        return .colorFromRGB(0xEEEEEE)
    }
    
    /// 文本字体
    func cellMessageFont() -> UIFont {
        let _f:CGFloat = TGSUIModel.getThemFontsConfig()?.cckf_text_view_size ?? 14
        return .systemFont(ofSize: _f, weight: .regular)
    }
    
    /// 问题列表字体
    func cellMessageQuestionFont() -> CGFloat {
        let _f:CGFloat = TGSUIModel.getThemFontsConfig()?.cckf_question_title_size ?? 14
        return _f
    }
    
    /// 文本颜色
    func cellMessageColor() -> UIColor {
        return .colorFromRGB(0x424242)
    }
    
    /// 语音文本颜色
    func cellMessageVoiceColor() -> UIColor {
        return .colorFromRGB(0x141413)
    }
    
    /// 链接文本颜色(左)
    func cellMessageLinkLeftColor() -> UIColor {
        let _c:String = TGSUIModel.getThemColorsConfig()?.cckf_color_link ?? "#1677FF"
        return .init().colorFromHexString(hex: _c)
    }
    
    /// 链接文本颜色(右)
    func cellMessageLinkRightColor() -> UIColor {
        let _c:String = TGSUIModel.getThemColorsConfig()?.cckf_color_rlink ?? "#1677FF"
        return .init().colorFromHexString(hex: _c)
    }
    
    /// 文本超链接匹配正则
    func cellMessageLinkRegex() -> String {
        return "([hH][tT]{2}[pP]://|[hH][tT]{2}[pP][sS]://)(([A-Za-z0-9-~]+).)+([A-Za-z0-9-~\\/])+"
    }
    
    /// 支持的视频后缀
    func cellVideosSuffixs() -> [String] {
        return ["mp4","mpg","mpe","mpeg", "mov","qt","m4v","wmv", "avi","webm","flv"]
    }
    
    /// 支持的图片后缀
    func cellPicturesSuffixs() -> [String] {
        return ["gif","jpg","jpeg","jpg2", "png","tif","tiff","bmp","svg","svgz","webp","ico"]
    }
    
    /// 列表默认高度
    func cellTableViewDefaultHeight() -> CGFloat {
        return 40
    }
    
    //MARK: 用户信息
    /// 用户图像尺寸
    func cellUserImageSize() -> CGSize {
        return .init(width: 40, height: 40)
    }
    
    /// 用户图像距离左边/右边间距
    func cellUserLeftOrRightMargin() -> CGFloat {
        return 15
    }
    
    /// 用户图像左边/右边 距离消息内容的间距
    func cellLeftOrRightContentMargin() -> CGFloat {
        return 8
    }
    
    /// 用户默认图像
    func cellUserDefaultImage() -> UIImage? {
        return UIImage(named: "ico_my_h", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
    }
    
    /// 默认占位图
    func cellDefaultImage() -> UIImage? {
        return UIImage(named: "ic_img_failed", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
    }
    
    /// 机器人(系统)默认图像
    func cellMachineImage(ImageView _iv:UIImageView? = nil,
                          andSize _s:CGSize? = nil) {
        let _img = UIImage(named: "nav_machine", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
        
        if let _path = TGSUIModel.getSystemInfoModel(key:VXIUIConfig.shareInstance.getGlobalCgaKey())?.channel?.reception_robot_avatar_url,_path.isEmpty == false {
            let _url = TGSUIModel.getFileRealUrlFor(Path: _path, andisThumbnail: true)
            if _iv != nil,let _newUrl = URL.init(string: _url) {
                _iv?.yy_setImage(with: _newUrl,
                                 placeholder: _img,
                                 options: VXIUIConfig.shareInstance.requestOption()) { (_img:UIImage?, _:URL, _:YYWebImageFromType, _:YYWebImageStage, _error:Error?) in
                    let _tBlock = {
                        if let _image = _img{
                            if _s != nil {
                                let imgNew:UIImage? = _image.yy_imageByResize(to: _s!,
                                                                              contentMode: VXIUIConfig.shareInstance.cellImageContentMode())?.yy_image(byRoundCornerRadius: VXIUIConfig.shareInstance.cellUserImageSize().height * 0.5)
                                _iv?.image = imgNew
                            }
                            else{
                                _iv?.image = _image
                            }
                        }
                    }
                    
                    if Thread.current.isMainThread {
                        _tBlock()
                    }
                    else{
                        DispatchQueue.main.async {
                            _tBlock()
                        }
                    }
                }
            }
        }
        else{
            _iv?.image = _img
        }
    }
    
    /// 人工(坐席)默认图像
    func cellHumanDefaultImage(ImageView _iv:UIImageView? = nil,
                               andSize _s:CGSize? = nil) {
        let _img = UIImage(named: "tool_evaluate.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
        
        let _m = TGSUIModel.getSystemInfoModel(key: VXIUIConfig.shareInstance.getGlobalCgaKey())
        if let _path = _m?.guest?.receptionistAvatarUrl,_path.isEmpty == false,_m?.guest?.enabledGlobalAvatar == true {
            let _url = TGSUIModel.getFileRealUrlFor(Path: _path, andisThumbnail: true)
            if _iv != nil,let _newUrl = URL.init(string: _url) {
                _iv?.yy_setImage(with: _newUrl,
                                 placeholder: _img,
                                 options: VXIUIConfig.shareInstance.requestOption()) { (_img:UIImage?, _:URL, _:YYWebImageFromType, _:YYWebImageStage, _error:Error?) in
                    let _tBlock = {
                        if let _image = _img{
                            if _s != nil {
                                let imgNew:UIImage? = _image.yy_imageByResize(to: _s!,
                                                                              contentMode: VXIUIConfig.shareInstance.cellImageContentMode())?.yy_image(byRoundCornerRadius: VXIUIConfig.shareInstance.cellUserImageSize().height * 0.5)
                                _iv?.image = imgNew
                            }
                            else{
                                _iv?.image = _image
                            }
                        }
                    }
                    
                    if Thread.current.isMainThread {
                        _tBlock()
                    }
                    else{
                        DispatchQueue.main.async {
                            _tBlock()
                        }
                    }
                }
            }
        }
        else{
            _iv?.image = _img
        }
    }
    
    /// 机器人图像尺寸
    func robotImageSize() -> CGSize {
        return .init(width: 30, height: 30)
    }
    
    /// 列图片 UIViewContentMode
    func cellImageContentMode() -> UIView.ContentMode {
        return .scaleAspectFill
    }
    
    //MARK: 表情面板
    /// emoji面板高度
    func faceFootViewHeight() -> CGFloat {
        return 259
    }
    
    /// 表情尺寸(宽高等同)
    func faceEmojiSize() -> CGFloat {
        return 36.08
    }
    
    /// 自定义表情图片
    func faceImageSize() -> CGSize {
        return .init(width: 60, height: 60)
    }
    
    /// 表情顶部功能面板高度
    func faceEmojiMenuheight() -> CGFloat {
        return 38
    }
    
    /// 表情组头高度
    func faceMenuHeight() -> CGFloat {
        return 44
    }
    
    /// 选中高亮颜色
    func cellHighlightColor() -> UIColor {
        return TGSUIModel.createColorHexInt(0x02C161)
    }
    
    /// 常规颜色
    func cellnornalColor() -> UIColor {
        return TGSUIModel.createColorHexInt(0x424242)
    }
    
    //MARK: 消息撤回配置
    /// 文本
    func messageRevokeText() -> String {
        return "撤回"
    }
    
    /// 撤回图标名称
    func messageRevokeImageName() -> String {
        return "chat_ch.png"
    }
    
    /// 撤回字体
    func messageRevokeFont() -> UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    /// 撤回背景颜色
    func messageRevokeBgColor() -> UIColor {
        return UIColor.init().colorFromHexInt(hex: 0x333333)
    }
    
    /// 撤回文本颜色
    func messageRevokeTextColor() -> UIColor {
        return .white
    }
    
    /// 撤回列高度
    func messageRevokeCellHeight() -> CGFloat {
        return 66.5
    }
    
    
    //MARK: KEY
    /// 全局配置key
    func getGlobalCgaKey() -> String {
        return "K_VXI_GLOBAL_CGA"
    }
    
    /// 快捷
    func getInputQuickReplyHandleKey() -> Notification.Name {
        return .init("K_VXI_INPUT_QUICK_REPLY")
    }
    
    /// 访客自主评价key
    func getEnabledGuestSensitiveKey() -> Notification.Name {
        return .init("K_VXI_INPUT_GUEST_SENSITIVE")
    }
    
    /// 表情配置信息key
    func getFaceConfigkey() -> Notification.Name {
        return .init("K_VXI_INPUT_FACE_CONFIG")
    }
    
    /// 是否开启常驻转人工入口（true：开启，false：关闭）key
    func getEnabledEntranceKey() -> Notification.Name {
        return .init("K_VXI_INPUT_ENABLED_ENTRANCE")
    }
    
    /// 关闭会话通知
    func getCloseSectionKey() -> Notification.Name {
        return .init("K_VXI_INPUT_CLOSE_SECTION")
    }
    
    /// 快捷语(传递上层应用)
    func getQuickPhrases() -> Notification.Name {
        return .init("K_VXI_QUICK_PHRASES")
    }
    
    /// 域名配置
    func getHostKey() -> String {
        return "K_VXI_HOST"
    }
    
    /// 默认满意度配置key
    func getEvaluatDefaultKey() -> String {
        return "K_VXI_EVALUAT_DEFAULT_CONFIG"
    }
    
    /// 默认留言配置key
    func getLeaveMessageDefaultKey() -> String {
        return "K_VXI_LEAVE_MESSAGE_CONFIG"
    }
    
    /// 星星最大个数
    func getEvaluatMaxStarKey() -> String {
        return "K_VXI_EVALUAT_DEFAULT_CONFIG"
    }
    
    //MARK: 满意度(评价)
    /// 满意度评价最大星星数
    func getMaxStar() -> Int {
        let _max = UserDefaults.standard.integer(forKey: getEvaluatMaxStarKey())
        return _max
    }
    
    ///满意度评价星星数起点Tag
    func getStarBeginTag() -> Int {
        return 2024
    }
    
    /// 选中颜色
    func getStarSelectColor() -> UIColor {
        return UIColor.init().colorFromHexInt(hex: 0x02C161)
    }
    
    /// 满意度描述字号
    func getStarCellFont() -> UIFont {
        return UIFont.systemFont(ofSize: 11, weight: .regular)
    }
    
    /// 满意度描述列高
    func getStarCellHeight() -> CGFloat {
        return 19
    }
    
    /// 行情间距
    func getStarCellRowMargin() -> CGFloat {
        return 6
    }
    
    /// 最大评论长度
    func getStarMaxComment() -> Int {
        return 100
    }
}
