//
//  CCKFApi.swift
//  VisionCCiOSSDK
//
//  Created by CQP-MacPro on 2023/12/19.
//

import UIKit
import Realm
import RxSwift
import SnapKit
import SocketIO
@_implementationOnly import VisionCCiOSSDKEngine

//MARK: 对外暴露的
/// 消息订阅委托
public protocol CCKFApiConversationDelegate {
    
    /// 主动推送未读消息的数量
    /// - Parameter count: Int 未读消息数量
    func unReadMessageCountEvent(count:Int)
    
    /// 快捷语传递给上层应用
    /// - Parameter model: ShortcutsModel
    func shortCutEvent(model:ShortcutsModel)
    
    /// 有消息更新
    /// - Parameter model: MessageModel
    func messageEvent(model:MessageModel)
    
    /// 埋点信息
    /// - Parameters:
    ///   - name: String Key
    ///   - attributes: [String:String] 埋点附加信息
    func trackEvent(name:String,attributes:[String:String])
}

//MARK: -
///聊天时导航栏左侧显示的服务类型
enum ChatServiceNavType:Int {
    ///没有，左侧不显示图片和名称
    case none = 0
    ///人工
    case artificial
    ///机器人聊天
    case machine
    ///(转人工)排队
    case lineup
    ///(转人工)正在人工会话
    case lineing
    
    var showTitle:String{
        switch self {
        case .artificial:
            return "客服名称"
        case .machine:
            return TGSUIModel.getSystemInfoModel(key: VXIUIConfig.shareInstance.getGlobalCgaKey())?.channel?.reception_robot_name ?? "机器人"
        case .lineup:
            return "加载中，请稍后..."
        default:
            return ""
        }
    }
}

/// 会话ViewController
public class CCKFApi: BaseChatVC {
    
    //MARK: - override
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        serviceNavType = .machine
        setUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        VXIUIConfig.shareInstance.appSetNavigationeStyleFor(Hidden: true, andViewController: self)
        self.isViewWillAppend = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //关闭
        IQKeyboardManager.shared.enable = false
    }
    
    public override func updateViewConstraints() {
        
        if self.view.subviews.contains(self.navView) {
            self.navView.snp.makeConstraints { make in
                make.left.top.right.equalToSuperview()
            }
        }
        
        if self.chatView.subviews.contains(self.tableView){
            self.tableView.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.right.equalTo(0)
                make.top.equalTo(self.navView.snp.bottom)
                make.bottom.equalTo(self.chatView.evInputView.snp.top)
            }
        }
        
        if self.serviceNavBgView.subviews.contains(self.serviceNavIV){
            self.serviceNavIV.snp.makeConstraints { make in
                make.left.equalTo(15)
                make.size.equalTo(VXIUIConfig.shareInstance.robotImageSize())
                make.top.equalTo(7)
                make.bottom.equalTo(-7)
            }
        }
        
        if self.serviceNavBgView.subviews.contains(self.serviceNavNameLabel) {
            self.serviceNavNameLabel.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(serviceNavIV.snp.right).offset(8)
                make.centerY.equalTo(self.serviceNavIV.snp.centerY)
                make.right.equalTo(0)
            }
        }
        
        //MARK: 排队
        if self.serviceNavBgView.subviews.contains(self.labLineUpInfo) {
            self.labLineUpInfo.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(15)
                make.height.equalTo(20)
                make.right.equalTo(-15)
                make.bottom.equalTo(self.btnCancelLineup.snp.top)
            }
        }
        
        if self.serviceNavBgView.subviews.contains(self.btnCancelLineup) {
            self.btnCancelLineup.snp.makeConstraints { make in
                make.left.equalTo(15)
                make.height.equalTo(16.5)
                make.width.equalTo(60)
                make.bottom.equalTo(-3)
            }
        }
        
        super.updateViewConstraints()
    }
    
    
    //MARK: bindViewModel
    override func bindViewModel() {
        super.bindViewModel()
        
        /// 转人工(成功，进入排队等待)
        self.viewModel.convertArtificialPublishSubject.subscribe {[weak self] (_input:Event<Any>) in
            guard let self = self else { return}
            guard let (isOk,msg) = _input.element as? (Bool,String) else { return }
            if isOk {
                //监听SocketIO 里面的 guestQueuePrompt 消息
                self.serviceNavType = .lineup
                
                if VXISocketManager.share.socketManager?.status.active == false {
                    debugPrint("SocketManager 连接已关闭，需要重连")
                    self.shePromptInfoBy(Text: "SocketIO 正在重连...",andisShow: true)
                    
                    //重连
                    VXISocketManager.share.cliectReconnect()
                }
            }
            else{
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: msg)
            }
        }.disposed(by: rx.disposeBag)
        
        /// 历史消息结果处理
        self.viewModel.loadConversationHistoryPublishSubject.subscribe {[weak self] (_input:Event<Any>) in
            guard let self = self else { return }
            guard let (_isOK,_any,_msg,_direction) = _input.element as? (Bool,Any,String,String) else { return }
            var _haxNextPagge = false
            if _isOK,var _arr = _any as? [MessageModel] {
                print("我是历史消息")
                
                //排序处理
                self.setisShowFor(ArrData: &_arr)
                
                //消息时间计算
                TGSUIModel.calcMessageTimeFor(Data: _arr, andOldData: self.dataArray)
                
                if MessageHistoryDirection.init(rawValue: _direction) == .new {
                    self.dataArray.removeAll()
                    self.dataArray = _arr
                }
                else{
                    self.dataArray = _arr + self.dataArray
                }
                
                //未读消息状态处理
                self.unReadActionFor(Direction: _direction, andArram: _arr)
                self.lastMId = _arr.first?.mId
                
                _haxNextPagge = _arr.count >= VXIUIConfig.shareInstance.cellPageSize()
                self.saveLocationUpdateFor(Size: _arr.count - 1)
            }
            else{
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
            }
            
            self.stopAnimationFor(Refresh: MessageHistoryDirection.init(rawValue: _direction) == .new,
                                  andHasNextPage: _haxNextPagge)
        }.disposed(by: rx.disposeBag)
        
        /// 发送消息状态更新
        self.viewModel.conversationSendPublishSubject.subscribe {[weak self] (_input:Event<Any>) in
            guard let self = self else { return }
            guard let (_isOk,_,_dicTemp) = _input.element as? (Bool,String,[String:Any]) else { return }
            if _isOk {
                self.newMessageActionFor(Data: _dicTemp)
            }
        }.disposed(by: rx.disposeBag)
        
        /// 消息撤回状态
        self.viewModel.messageRevokePublishSubject.subscribe {[weak self] (_input:Event<Any>) in
            guard let self = self else { return }
            guard let (_isOk,_msg,_mid) = _input.element as? (Bool,String,Int64) else { return }
            if _isOk == false {
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
            }
            else{
                self.messageRevokeFor(MessageId: _mid)
            }
        }.disposed(by: rx.disposeBag)
        
        /// SocketIO 有时状态推送不及时
        NotificationCenter.default.rx.notification(VXIUIConfig.shareInstance.getCloseSectionKey(), object: nil).subscribe {[weak self] (_input:Event<Notification>) in
            guard let self = self else { return }
            if let isClossed = _input.element?.userInfo?["isClosed"] as? Bool {
                if isClossed {
                    self.serviceNavType = .machine
                    self.labPageTitle?.text = VXIUIConfig.shareInstance.pageName()
                }
            }
        }.disposed(by: rx.disposeBag)
        
        /// 留言
        self.viewModel.leaveMessageSubmitPublishSubject.subscribe {[weak self] (_input:Event<Any>) in
            guard let self = self else { return }
            guard let (_isOK,_msg) = _input.element as? (Bool,String) else { return }
            if !_isOK {
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
            }
            else{
                VXIUIConfig.shareInstance.keyWindow().showSuccessInfo(at: "留言成功")
                
                if self.serviceNavType == .lineup {
                    //排队超时，留言成功 取消排队
                    VXISocketManager.share.stopSocketIO(isNavgationback: false)
                }
            }
            self.leaveMessagePopupController.dismiss()
        }.disposed(by: rx.disposeBag)
        
    }
    
    
    //MARK: - lazy load
    /// 服务类型
    lazy var serviceNavType:ChatServiceNavType = .none {
        didSet{
            self.labLineUpInfo.isHidden = self.serviceNavType == .lineup ? false : true
            self.btnCancelLineup.isHidden = self.serviceNavType == .lineup ? false : true
            
            self.artificialBtn.isHidden = (self.serviceNavType == .lineup || self.serviceNavType == .lineing) ? true : false
            self.serviceNavNameLabel.isHidden = self.serviceNavType == .lineup ? true : false
            self.serviceNavIV.isHidden = self.serviceNavType == .lineup ? true : false
            
            //图像
            if self.serviceNavType == .lineing {
                VXIUIConfig.shareInstance.cellHumanDefaultImage(ImageView: self.serviceNavIV,
                                                                andSize: VXIUIConfig.shareInstance.robotImageSize())
            }
            else{
                VXIUIConfig.shareInstance.cellMachineImage(ImageView: self.serviceNavIV,
                                                           andSize: VXIUIConfig.shareInstance.robotImageSize())
            }
            
            //关闭会话按钮
            self.artificialCloseBtn.isHidden = self.serviceNavType == .lineing ? false : true
            
            serviceNavNameLabel.text = serviceNavType.showTitle
        }
    }
    
    private lazy var labPageTitle:VisionCCiOSSDKEngine.YYLabel? = nil
    
    /// 导航视图
    private lazy var navView:UIView = {
        return TGSUIModel.createDiyNavgationalViewFor(TitleStr: VXIUIConfig.shareInstance.pageName(),
                                                      andDisposeBag: rx.disposeBag) {[weak self] in
            guard let self = self else { return }
            self.clickArtificialCloseBtn(isNavigationback: true)
        } withOtherblock: {[weak self] (_bgView,_titleLabel) in
            guard let self = self else { return }
            self.labPageTitle = _titleLabel
            
            //配置导航
            self.configServiceNavBgView()
            _bgView.addSubview(self.serviceNavBgView)
            self.serviceNavBgView.snp.makeConstraints { make in
                make.left.bottom.equalToSuperview()
                make.top.equalTo(_titleLabel.snp.bottom).offset(17)
                make.bottom.equalToSuperview()
            }
            
            //关闭按钮
            _bgView.addSubview(self.artificialCloseBtn)
            artificialCloseBtn.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.equalTo(18.5)
                make.height.equalTo(20)
                make.centerY.equalTo(self.serviceNavBgView)
                make.right.equalTo(-17)
            }
            artificialCloseBtn.isHidden = true
            
            //转人工
            _bgView.addSubview(artificialBtn)
            artificialBtn.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.height.centerY.equalTo(self.serviceNavBgView)
                make.right.equalToSuperview().offset(-10)
            }
        }
    }()
    
    /// 图像
    private lazy var serviceNavIV:UIImageView = {
        let iv = TGSUIModel.createImage(rect: .zero,
                                        image: nil,
                                        backgroundColor: nil)
        iv.layer.cornerRadius = 0.38
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    /// 文本
    private lazy var serviceNavNameLabel:YYLabel = {
        let _f:CGFloat = TGSUIModel.getThemFontsConfig()?.cckf_tv_online_text_size ?? 16
        let _c:String = TGSUIModel.getThemColorsConfig()?.cckf_online_color ?? "#424242"
        return TGSUIModel.createLable(rect: .zero,
                                      text: nil,
                                      textColor: TGSUIModel.createColorHexString(_c),
                                      font: .systemFont(ofSize: _f, weight: .regular),
                                      andTextAlign: .left)
    }()
    
    private lazy var serviceNavBgView:UIView = {
        let view = UIView ()
        return view
    }()
    
    /// 转人工
    private lazy var artificialBtn:UIButton = {[unowned self] in
        let _f:CGFloat = TGSUIModel.getThemFontsConfig()?.cckf_trans_user_text_size ?? 16
        let btn = TGSUIModel.createBtn(rect: .zero,
                                       strTitle: "转人工",
                                       titleColor: TGSUIModel.createColorHexInt(0x424242),
                                       txtFont: UIFont.systemFont(ofSize: _f, weight: UIFont.Weight.regular),
                                       image: nil,
                                       backgroundColor: .clear)
        
        btn.rx.tap.subscribe { [weak self](event) in
            guard let self = self else { return }
            self.view.endEditing(true)
            self.viewModel.convertArtificialPublishSubject.onNext((0,false))
        }.disposed(by: rx.disposeBag)
        
        return btn
    }()
    
    /// 关闭按钮
    private lazy var artificialCloseBtn:UIButton = {[unowned self] in
        let bg_image = UIImage(named: "nav_close", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
        
        let closeBtn = TGSUIModel.createBtn(rect: .zero,
                                            image: nil,
                                            backgroundImage: bg_image)
        closeBtn.contentHorizontalAlignment = .left
        
        closeBtn.rx.tap.subscribe { [weak self](event) in
            guard let self = self else { return }
            self.view.endEditing(true)
            self.clickArtificialCloseBtn(isNavigationback: false)
        }.disposed(by: rx.disposeBag)
        
        return closeBtn
    }()
    
    private lazy var isViewWillAppend:Bool = false
    
    //MARK: 排队信息
    /// 排队信息
    private lazy var labLineUpInfo:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "加载中，请稍后...",
                                          textColor: TGSUIModel.createColorHexInt(0x424242),
                                          font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                          andTextAlign: .left,
                                          andisdisplaysAsync: false)
        _lab.isHidden = true
        return _lab
    }()
    
    /// 取消排队
    private lazy var btnCancelLineup:UIButton = {[unowned self] in
        let closeBtn = TGSUIModel.createBtn(rect: .zero,
                                            strTitle: "取消排队",
                                            titleColor: .colorFromRGB(0x02C161),
                                            txtFont: .systemFont(ofSize: 12, weight: .regular),
                                            image: nil,
                                            backgroundImage: nil)
        closeBtn.contentHorizontalAlignment = .left
        
        closeBtn.rx.tap.subscribe { [weak self](event) in
            guard let self = self else { return }
            self.view.endEditing(true)
            self.clickArtificialCloseBtn(isNavigationback: false)
        }.disposed(by: rx.disposeBag)
        
        closeBtn.isHidden = true
        return closeBtn
    }()
    
    /// 排队信息更新
    private func updateLineupFor(Model _m:GuestqueuepromptModel) {
        if let _str = _m.promptWord,let _c = _m.queueNumber {
            self.labLineUpInfo.attributedText = TGSUIModel.createAttributed(textString: _str,
                                                                            normalFont: self.labLineUpInfo.font,
                                                                            normalColor: self.labLineUpInfo.textColor,
                                                                            highLightString:"\(_c)",
                                                                            highLightFont:self.labLineUpInfo.font,
                                                                            highLightColor: .colorFromRGB(0xFF8F1F))
        }
    }
}


//MARK: -  对外暴露方法
extension CCKFApi {
    
    /// SDK版本
    /// - Parameter isShort: Bool true 短版本信息，false 长版本信息 默认
    /// - Returns: String
    public static func getSDKVersion(isShort:Bool = false) -> String {
        if isShort == true {
            //短版本信息 x.x.x
            return String.init(format:"%@",Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! CVarArg)
        }
        else{
            //长版本信息 x.x.x.x
            return String.init(format:"%@.%@",Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! CVarArg,Bundle.main.infoDictionary!["CFBundleVersion"] as! CVarArg)
        }
    }
    
    
    /// 开启会话
    /// - Parameters:
    ///   - host: String 服务器域名         必填
    ///   - entryId: String 客户端entryId  必填
    ///   - appkey: String 密钥            必填
    ///   - userMappings: UserMappingModel 必填(用户身份信息,必须包含identity_id、openid、uniondid、deviceId 至少一个)
    ///   - callBack:(()->Void)? 进线发送消息 可选
    public func startSession(host:String,
                             entryId:String,
                             appkey:String,
                             userMappings:UserMappingModel,
                             callBack:(()->Void)? = nil) {
        VXISocketManager.share.callBack = callBack
        
        //域名
        UserDefaults.standard.setValue(host, forKey: VXIUIConfig.shareInstance.getHostKey())
        
        //秘钥
        VXISocketManager.share.appKey = appkey
        
        //无改变
        if VXISocketManager.share.xentry == entryId && VXISocketManager.share.uMolde != nil
            && VXISocketManager.share.uMolde == userMappings {
            self.show()
        }
        //已改变
        else{
            VXISocketManager.share.uMolde = userMappings
            
            //先关闭
            self.close()
            
            //开启SocketIO
            weak var weakSelf = self
            VXISocketManager.share.startSocketIOFor(XEntry: entryId,
                                                    andConnectDelegate: weakSelf,
                                                    withMessageDelegate: weakSelf)
        }
    }
    
    
    /// 支持SDK已经开启会话后，跳出聊天页面后再次打开聊天窗口，避免多次startSession
    public func show(){
        //自动创建
        if VXISocketManager.share.socketManager == nil {
            guard let _ak = VXISocketManager.share.appKey,_ak.isEmpty == false else {
                debugPrint("appKey 不存在，无法自动创建")
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "appKey 不存在，无法自动创建")
                return
            }
            
            guard let _eid = VXISocketManager.share.xentry,_eid.isEmpty == false else {
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "客户端entryId 不存在，无法自动创建")
                return
            }
            
            //开启SocketIO
            VXISocketManager.share.startSocketIOFor(XEntry: _eid,
                                                    andConnectDelegate: self,
                                                    withMessageDelegate: self)
        }
        //直接使用
        else{
            guard let _eid = VXISocketManager.share.xentry,_eid.isEmpty == false else {
                debugPrint("客户端entryId 不存在，无法接入会话")
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "客户端entryId 不存在，无法接入会话")
                return
            }
            
            guard let _did = VXISocketManager.share.deviceId,_did.isEmpty == false else {
                debugPrint("deviceId 不存在，无法接入会话")
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "deviceId 不存在，无法接入会话")
                return
            }
            
            VXISocketManager.share.enterSectionBy(EntryId: _eid,
                                                  andDeviceId: _did,
                                                  withSocketId: nil,
                                                  andViewController: self)
        }
    }
    
    
    /// 关闭 SocketIO 对像
    public func close(){
        VXISocketManager.share.stopSocketIO(isNavgationback: true)
    }
    
    
    /// 获取Global配置(没有入参，需要在startSession 或 show 之后调用)
    /// - Parameter _rc: ((Bool,Any?)->Void)
    ///   true,请求成功，返回 GlobalCgaModel 配置信息
    ///   false,请求失败，返回 String 错误描述
    public static func registerNetUser(RequestCallback:@escaping ((Bool,Any?)->Void)){
        guard let _eid = VXISocketManager.share.xentry,_eid.isEmpty == false else {
            RequestCallback(false,"入口编号(Entryid)不存在，请在开启会话成功后调用")
            return
        }
        VXISocketManagerViewModel.getSocketIOConfigFor(XEntry: _eid,
                                                       andisModel: true,
                                                       withRACSubscriber: nil) { (_result:Bool, _data:Any?) in
            RequestCallback(_result,_data)
        }
    }
    
    /// 发送消息
    /// - Parameters:
    ///   - msgType: Int 1⽂本,2图⽚,3⾳频⽂件,4视频⽂件,5⽂件,6普通链接,10通⽤卡⽚
    ///   - messageBody: MessageBody
    public func sendMessage(msgType:Int,
                            msgBody:MessageBody){
        
        guard let _ak = VXISocketManager.share.appKey,_ak.isEmpty == false else {
            debugPrint("appKey 不存在，无法自动创建")
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "appKey 不存在，请先开启会话后再试")
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        guard let _eid = VXISocketManager.share.xentry,_eid.isEmpty == false else {
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "客户端entryId 不存在，请开先启会话后再试")
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        guard let _deviceId = VXISocketManager.share.deviceId,_deviceId.isEmpty == false else {
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "客户端deviceId 不存在，请开先启会话授权通过后再试")
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if VXISocketManager.share.socketIOClient?.status.active == false {
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "请开启会话后再试")
            self.navigationController?.popViewController(animated: true)
        }
        else{
            if let _data = try? JSONEncoder.init().encode(msgBody) {
                let _dic = TGSUIModel.getDicDataFor(Data: _data)
                print(_dic ?? "--")
                
                let message = MessageModel()
                message.timestamp = TGSUIModel.localUnixTimeForInt() * 1000
                message.renderMemberType = MessageDirection.send.rawValue
                message.cMid = NSUUID().uuidString
                message.mType = msgType
                message.messageBody = msgBody
                
                self.dataArray.append(message)
                self.saveRealmFor(Data: message)
                self.tableView.insertRows(at: [IndexPath.init(row: dataArray.count-1, section: 0)], with: .bottom)
                
                /// 发送
                VXIChatViewModel.conversationSendFor(Type: msgType,
                                                     andClientMessageId: VXIUIConfig.shareInstance.getClientMIdFor(Mid: message.cMid),
                                                     andBody: _dic!,
                                                     andisLoading: true,
                                                     withPublishSubject: nil) {[weak self] (_isOk:Bool, _msg:String) in
                    guard let self = self else { return }
                    if _isOk {
                        VXIUIConfig.shareInstance.keyWindow().showSuccessInfo(at: _msg)
                        self.efScrollToLastCell()
                    }
                    else{
                        VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
                    }
                }
            }
            else{
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "数据转换异常,请稍后再试")
            }
        }
    }
}


//MARK: - 内部私有方法
extension CCKFApi {
    
    //MARK: 创建UI
    /// 创建UI
    private func setUI(){
        self.view.addSubview(self.navView)
        
        /// app将要进入前台
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification, object: nil).subscribe {[weak self] (_:Event<Notification>) in
            guard let self = self else { return }
            self.isViewWillAppend = true
            self.loadData(isReload: true)
            self.isViewWillAppend = false
            
            if VXISocketManager.share.socketManager?.status.active == false {
                debugPrint("SocketManager 连接已关闭，需要重连")
                self.shePromptInfoBy(Text: "SocketIO 正在重连...",andisShow: true)
                
                //重连
                VXISocketManager.share.cliectReconnect()
            }
        }.disposed(by: rx.disposeBag)
        
        /// 转人工状态监听
        NotificationCenter.default.rx.notification(VXIUIConfig.shareInstance.getEnabledEntranceKey(), object: nil).subscribe {[weak self] (_input:Event<Notification>) in
            guard let self = self else { return }
            if let _enable = _input.element?.userInfo?["isShow"] as? Bool {
                self.artificialBtn.isHidden = !_enable
            }
        }.disposed(by: rx.disposeBag)
        
        /// 传递上层应用
        NotificationCenter.default.rx.notification(VXIUIConfig.shareInstance.getQuickPhrases(), object: nil).subscribe {[weak self] (_input:Event<Notification>) in
            guard let self = self else { return }
            if let _enable = _input.element?.userInfo?["5"] as? ShortcutsModel {
                self.conversionDelegate?.shortCutEvent(model: _enable)
            }
        }.disposed(by: rx.disposeBag)
        
        /// 进入会话结果
        VXISocketManager.share.viewModel.enterSectionPublishSubject.subscribe { (_input:Event<Any>) in
            guard let (_isOK,_msg) = _input.element as? (Bool,String) else { return }
            if _isOK == false {
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
            }
            else if _isOK == true {
                debugPrint("enterSectionPublishSubject-进入会话成功")
                if self.isViewWillAppend == true {
                    self.loadData(isReload: true)
                    self.isViewWillAppend = false
                }
                
                //进线卡片
                if VXISocketManager.share.callBack != nil {
                    VXISocketManager.share.callBack?()
                    VXISocketManager.share.callBack = nil
                }
            }
        }.disposed(by: rx.disposeBag)
        
        /// 定时更新未读消息
        Observable<Int>.timer(RxTimeInterval.seconds(VXIUIConfig.shareInstance.getThrottleTimeinterval()),         //首次产生第一个指的时间
                              period: RxTimeInterval.seconds(VXIUIConfig.shareInstance.getThrottleTimeinterval()), //时间间隔
                              scheduler: MainScheduler.instance).subscribe {[weak self] (_input:Event<Int>) in
            guard let self = self else { return }
            self.unReadActionFor(Direction: nil, andArram: nil)
        }.disposed(by: rx.disposeBag)
        
        self.bindViewModel()
    }
    
    /// 设置导航
    private func configServiceNavBgView(){
        serviceNavBgView.addSubview(serviceNavIV)
        serviceNavBgView.addSubview(serviceNavNameLabel)
        
        serviceNavBgView.addSubview(self.labLineUpInfo)
        serviceNavBgView.addSubview(self.btnCancelLineup)
    }
    
}


//MARK: - 会话
extension CCKFApi {
    
    //MARK: 关闭会话
    /// 关闭会话
    /// - Parameter _isnavback: true 返回关闭(SocketIO 对象关闭) false(关闭人工会话和取消排队调用，此时SocketIO 对象不销毁)
    private func clickArtificialCloseBtn(isNavigationback _isnavback:Bool){
        if _isnavback {
            self.navigationController?.popViewController(animated: true)
            //返回销毁对象
            //VXISocketManager.share.stopSocketIO(isNavgationback: _isnavback)
        }
        else{
            ///显示弹窗
            TGSSystemAlert.showTipWithTitleAlert(vc: self,
                                                 titleStr: "结束会话",
                                                 tipStr: "确定结束会话吗？如有需要，欢迎随时与我联系",
                                                 leftStr: "继续咨询",
                                                 leftColor: TGSUIModel.createColorHexInt(0x424242),
                                                 rightStr: "结束会话",
                                                 rightColor: TGSUIModel.createColorHexInt(0x1677FF)) {
                VXISocketManager.share.stopSocketIO(isNavgationback: _isnavback)
            }
        }
        
    }
    
    
    //MARK: 会话状态处理
    /// 会话状态处理
    private func updateConversationFor(Model _m: GuestSessionModel){
        self.sessionId = _m.sessionId
        self.eid = _m.eId
        
        //访客评价状态更新
        if let _config = _m.satisfactionConfig {
            NotificationCenter.default.post(name: VXIUIConfig.shareInstance.getEnabledGuestSensitiveKey(),
                                            object: nil,
                                            userInfo: ["isShow":_config.enableGuestActiveEvaluate ?? false])
        }
        
        debugPrint("sessionStatus:\(_m.sessionStatus ?? 0),sessionType:\(_m.sessionType ?? 0)")
        
        // 如果开启常驻转人工
        // 如果不在咨询中并且系统会话，显示转人工按钮
        if (_m.sessionType == SessionType.system.rawValue || _m.sessionType == SessionType.offline.rawValue) ||
            (_m.sessionStatus == SessionStatus.isTerminated.rawValue || _m.sessionStatus == SessionStatus.isEnded.rawValue) {
            self.artificialBtn.isHidden = false
            self.serviceNavType = .machine
            self.labPageTitle?.text = VXIUIConfig.shareInstance.pageName()
        }
        
        // 如果排队中，显示取消排队按钮
        if _m.sessionStatus == SessionStatus.isQueuing.rawValue && _m.sessionType == SessionType.queuing.rawValue {
            self.serviceNavType = .lineup
        }
        
        // 如果咨询中，显示结束会话按钮
        if _m.sessionStatus == SessionStatus.isSuccess.rawValue {
            self.serviceNavType = .lineing
            self.labPageTitle?.text = VXIUIConfig.shareInstance.pageName()
            serviceNavNameLabel.text = _m.receptionistName
        }
    }
    
    
    //MARK: 新会话消息处理
    /// 新会话消息处理
    /// - Parameter _d: <#_d description#>
    private func newMessageActionFor(Data _d:[String:Any]){
        //消息时间，服务端编号更新
        if let _mid = _d["mId"] as? Int64,
           let _cMid = _d["cMid"] as? String,
           let _createTime = _d["createTime"] as? Double {
            let _m:MessageModel? = self.dataArray.first(where: { $0.cMid == _cMid })
            if _m != nil {
                //do{
                //RLMRealm.default().beginWriteTransaction()
                _m?.mId = _mid
                //_m?.cMid = "\(_mid)"
                _m?.createTime = _createTime
                debugPrint("本地会话消息已更新:{cMid:\(_cMid),mid:\(_mid)}")
                //try RLMRealm.default().commitWriteTransaction()
                //}
                //catch(let _errr){
                //    debugPrint(_errr)
                //}
            }
        }
        
        //新消息处理
        if let _mType = _d["mType"] as? Int,_mType > 0 {
            let _tempBlock:((_ _index:Int?)->Void) = {[weak self] _index in
                guard let self = self else { return }
                if let _data = TGSUIModel.getJsonDataFor(Any: _d) {
                    do {
                        let _result = try JSONDecoder.init().decode(MessageModel.self, from: _data)
                        if _index == nil {
                            let lock = NSLock.init()
                            lock.lock()
                            self.dataArray.append(_result)
                            self.saveRealmFor(Data: _result)
                            self.saveLocationUpdateFor(Size: self.dataArray.count - 1)
                            debugPrint("会话消息已新增:{mId:\(_result.mId ?? 0),createTime:\(_result.createTime ?? 0)，mType:\(_result.mType ?? 0),renderMemberType:\(_result.renderMemberType ?? 0),_result:\(_result)}")
                            lock.unlock()
                        }
                        else if self.dataArray.count > _index! {
                            self.dataArray[_index!] = _result
                            debugPrint("会话消息已更新:{index:\(_index!)}")
                        }
                    }
                    catch(let _error){
                        debugPrint(_error)
                    }
                }
            }
            
            //替换
            if let _mid = _d["mId"] as? Int64, let _index = self.dataArray.firstIndex(where: { $0.mId == _mid && $0.cMid?.isEmpty == false }) {
                //do{
                //RLMRealm.default().beginWriteTransaction()
                _tempBlock(_index)
                //try RLMRealm.default().commitWriteTransaction()
                //}
                //catch(let _errr){
                //    debugPrint(_errr)
                //}
            }
            //新增
            else {
                _tempBlock(nil)
            }
        }
    }
    
    
    //MARK: 消息撤回
    /// 消息撤回
    /// - Parameter _mid: Int64 消息编号
    private func messageRevokeFor(MessageId _mid:Int64) {
        if let _index = self.dataArray.firstIndex(where: { $0.mId == _mid }) {
            let lock = NSLock.init()
            lock.lock()
            
            self.dataArray.remove(at: _index)
            if _index > 0 {
                self.saveLocationUpdateFor(Size: _index - 1)
            }
            else{
                self.saveLocationUpdateFor(Size: 0)
            }
            
            debugPrint("消息撤回:{mId:\(_mid)}")
            lock.unlock()
        }
    }
    
    //MARK: 消息更新
    /// 消息更新
    /// - Parameter _d: [String:Any]
    private func messageUpdateBy(Data _d:[String:Any]) {
        if let _mid = _d["mId"] as? Int64,
           let _mType = _d["mType"] as? Int,
           let _index = self.dataArray.firstIndex(where: { $0.mId == _mid }) {
            let _item = self.dataArray[_index]
            _item.mType  = _mType
            _item.mStatus = _d["mStatus"] as? Int
            
            if let _mb = _d["mBody"],let _data = TGSUIModel.getJsonDataFor(Any: _mb),
               let _result = try? JSONDecoder.init().decode(MessageBody.self, from: _data) {
                _item.messageBody = _result
            }
            
            self.saveLocationUpdateFor(Size: _index)
            debugPrint("消息更新：\(_d)")
        }
    }
}


//MARK: - VXISocketManagerConnectDelegate
extension CCKFApi : VXISocketManagerConnectDelegate {
    
    func socketConnectChangeFor(ClientEvent _ce: SocketIO.SocketClientEvent?, andSocketIOStatus _ss: SocketIO.SocketIOStatus?) {
        switch _ss {
        case .some(.connected):
            self.shePromptInfoBy(Text: "SocketIO 已链接成功",andisShow: false)
            break
            
        case .some(.notConnected):
            self.shePromptInfoBy(Text: "SocketIO 链接已断开...",andisShow: true)
            break
            
        case .some(.disconnected):
            self.shePromptInfoBy(Text: "SocketIO 链接已关闭",andisShow: true)
            VXISocketManager.share.socketManager?.reconnect()
            break
            
        case .some(.connecting):
            if _ce == .reconnectAttempt {
                self.shePromptInfoBy(Text: "SocketIO 尝试重连中...",andisShow: true)
            }
            else{
                self.shePromptInfoBy(Text: "SocketIO 正在链接...",andisShow: true)
            }
            break
            
        default:
            break
        }
    }
    
}


//MARK: - VXISocketManagerMessageDelegate
extension CCKFApi : VXISocketManagerMessageDelegate {
    
    func socketReceiveMessageFor(Event _ce: SocketReceiveEvent?, andMessageInfo _msg: [Any]?) {
        var _message_type:String? = _msg?.first as? String
        if (_msg?.count ?? 0) > 2 {
            _message_type = _msg?[1] as? String
        }
        if _message_type == nil || _message_type?.isEmpty == true { return }
        
        switch _message_type! {
            //MARK: 消息更新
        case SocketReceiveEvent.updateMessage.rawValue:
            if _msg?.last != nil,let _dicData = _msg?.last as? [String:Any] {
                self.messageUpdateBy(Data: _dicData)
            }
            break
            
            //MARK: 撤回消息
        case SocketReceiveEvent.msgRevoked.rawValue:
            if _msg?.last != nil,let _mid = (_msg?.last as? [String:Any])?["msgId"] as? Int64 {
                self.messageRevokeFor(MessageId: _mid)
            }
            break
            
            //MARK: 排队信息
        case SocketReceiveEvent.guestQueuePrompt.rawValue:
            if _msg?.last != nil,
               let _data = TGSUIModel.getJsonDataFor(Any: _msg!.last!),
               let _model = try? JSONDecoder().decode(GuestqueuepromptModel.self, from: _data) {
                self.updateLineupFor(Model: _model)
            }
            break
            
            //MARK: 会话状态
        case SocketReceiveEvent.updateGuestSessionStatus.rawValue:
            if _msg?.last != nil,
               let _data = TGSUIModel.getJsonDataFor(Any: _msg!.last!),
               let _model = try? JSONDecoder().decode(GuestSessionModel.self, from: _data) {
                if self.eid == nil {
                    self.updateConversationFor(Model: _model)
                }
                else if self.eid != nil && (_model.eId ?? 0) > (self.eid ?? 0) {
                    self.updateConversationFor(Model: _model)
                }
            }
            break
            
            //MARK: 新消息处理
        case SocketReceiveEvent.message.rawValue:
            if _msg?.last != nil,let _dicData = _msg?.last as? [String:Any] {
                self.newMessageActionFor(Data: _dicData)
                
                if let _data = TGSUIModel.getJsonDataFor(Any: _dicData),
                   let _resulr = try? JSONDecoder.init().decode(MessageModel.self, from: _data) {
                    self.conversionDelegate?.messageEvent(model: _resulr)
                }
                else{
                    debugPrint("sendConversation 消息对外发送失败")
                }
            }
            break
            
            //MARK: 配置更新
        case SocketReceiveEvent.globalConfigUpdate.rawValue:
            if _msg?.last != nil,let _data = TGSUIModel.getJsonDataFor(Any: _msg!.last!) {
                //更新配置数据
                String.writeLocalCacheData(data: _data, key: VXIUIConfig.shareInstance.getGlobalCgaKey())
                debugPrint("\(SocketReceiveEvent.globalConfigUpdate.rawValue) 已更新：\(_msg!.last!)")
            }
            break
            
        default:
            break
        }
    }
    
}
