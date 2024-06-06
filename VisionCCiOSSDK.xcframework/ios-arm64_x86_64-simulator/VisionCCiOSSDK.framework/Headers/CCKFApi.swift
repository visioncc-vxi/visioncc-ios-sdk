//
//  CCKFApi.swift
//  VisionCCiOSSDK
//
//  Created by CQP-MacPro on 2023/12/19.
//

import UIKit
//import Realm
@_implementationOnly import RxSwift
@_implementationOnly import SnapKit
@_implementationOnly import SocketIO
@_implementationOnly import VisionCCiOSSDKEngine
@_implementationOnly import IQKeyboardManagerSwift

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
        
        self.isViewWillAppend = true
        NSLog("isViewWillAppend:true")
        
        serviceNavType = .machine
        setUI()
        //        _start()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        VXIUIConfig.shareInstance.appSetNavigationeStyleFor(Hidden: true, andViewController: self)
        
        self.isViewWillAppend = true
        NSLog("isViewWillAppend:true")
        ///界面消息出现或消失隐藏键盘
        self.view.endEditing(true)
        
        for family in UIFont.familyNames.sorted() {
            debugPrint("Family: \(family)")
            
            let names = UIFont.fontNames(forFamilyName: family)
            for fontName in names {
                if fontName.contains("Adihau") {
                    debugPrint("OK")
                }
                debugPrint("- \(fontName)")
            }
        }
    }
    
    /// 状态栏
    public override var preferredStatusBarStyle: UIStatusBarStyle{
        if VXIUIConfig.shareInstance.isBlueTop() {
            return .lightContent
        }
        else{
            return .default
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        VXIUIConfig.shareInstance.appSetNavigationeStyleFor(Hidden: true, andViewController: self)
        
        //关闭
        IQKeyboardManager.shared.enable = false
        ///界面消息出现或消失隐藏键盘
        self.view.endEditing(true)
        self.conversionDelegate = nil
        //self.viewDisappearObs.onNext(true)
    }
    
    public override func updateViewConstraints() {
        
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
                make.right.equalTo(self.btnCancelLineup.snp.left).offset(-5)
                make.bottom.equalTo(-10)
            }
        }
        
        if self.serviceNavBgView.subviews.contains(self.btnCancelLineup) {
            self.btnCancelLineup.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.right.equalTo(-15)
                make.height.equalTo(16.5)
                make.width.equalTo(60)
                make.centerY.equalTo(self.labLineUpInfo.snp.centerY)
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
                //self.serviceNavType = .lineup
                
                if VXISocketManager.share.socketManager?.status.active == false {
                    debugPrint("SocketManager 连接已关闭，需要重连")
                    self.shePromptInfoBy(Text: "正在重连到客服...",andisShow: true)
                    
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
            ///进面新进的值
            let newSaveEntryId = UserDefaults.standard.string(forKey: "kSaveEntryIdKey")
            let newDeviceId = UserDefaults.standard.string(forKey: "deviceIdKey")
            
            let oldSaveEntryId = UserDefaults.standard.string(forKey: "oldSaveEntryIdKey")
            let oldDeviceId = UserDefaults.standard.string(forKey: "oldDeviceIdKey")
            
            ///这俩不一样，清空本地数据
            if (newSaveEntryId != oldSaveEntryId || newDeviceId != oldDeviceId){
                self.dataArray.removeAll()
            }
            
            if _isOK,var _arr = _any as? [MessageModel] {
                //                guard !_arr.isEmpty else {
                //                    return
                //                }
                
                if MessageHistoryDirection.init(rawValue: _direction) == .new {
                    //保留本地发送失败的
                    let _arrTemp = self.dataArray.filter({ MessageDirection(rawValue: $0.renderMemberType ?? 0).isSend() == true && ($0.mStatus == 4 || $0.mStatus == nil) })
                    
                    ///入口Id 和授权回来的 deviceID 都没变 才添加发送失败的数据加进去
                    if _arrTemp.count > 0, newSaveEntryId == oldSaveEntryId, newDeviceId == oldDeviceId{
                        var _narr = _arrTemp + _arr
                        debugPrint("保留本地发送失败的:{\(_arrTemp.count),\(_arrTemp.last?.timestamp ?? 0)},{\(_narr.count),\(_arr.first?.createTime ?? 0)}")
                        
                        //排序处理
                        self.setisShowFor(ArrData: &_narr)
                        
                        //消息时间计算
                        TGSUIModel.calcMessageTimeFor(Data: _narr, andOldData: self.dataArray)
                        
                        self.dataArray.removeAll()
                        self.dataArray = _narr
                    }
                    else{
                        //排序处理
                        self.setisShowFor(ArrData: &_arr)
                        
                        //消息时间计算
                        TGSUIModel.calcMessageTimeFor(Data: _arr, andOldData: self.dataArray)
                        
                        self.dataArray.removeAll()
                        self.dataArray = _arr
                    }
                }
                else{
                    //排序处理
                    self.setisShowFor(ArrData: &_arr)
                    
                    //消息时间计算
                    TGSUIModel.calcMessageTimeFor(Data: _arr, andOldData: self.dataArray)
                    
                    self.dataArray = _arr + self.dataArray
                }
                
                //未读消息状态处理
                self.unReadActionFor(Direction: _direction, andArram: _arr)
                self.lastMId = _arr.first?.mId
                
                _haxNextPagge = _arr.count >= VXIUIConfig.shareInstance.cellPageSize()
                self.saveLocationUpdateFor(Size: _arr.count - 1)
                
                //进线卡片
                if VXISocketManager.share.callBack != nil {
                    VXISocketManager.share.callBack?()
                    VXISocketManager.share.callBack = nil
                }
                
                //页面显示更多埋点
                if VXIShenCeConfig.shareInstance.isFiveSecondLater == true {
                    if self.shenCeCardType != .All {
                        let _ct = self.getCardTypeBy(Messages: _arr)
                        if _ct != self.shenCeCardType {
                            self.shenCeCardType = _ct
                            let _dic = VXIShenCeConfig.shareInstance.getAdditionalInformationBy(Messages: _arr)
                            VXIShenCeConfig.shareInstance.scViewBuryingPointBy(CSType: self.getCSType(),
                                                                               andCardType: _ct,
                                                                               andisHasRG: self.getisHasRG(),
                                                                               andisHasWelcome: self.getisHasWelcomeBy(Messages: _arr),
                                                                               withAdditionalInformation: _dic,
                                                                               andSessionId: self.sessionId ?? "")
                        }
                    }
                }
                
                ///储存新的获取历史数据对应的kSaveEntryId和deviceId
                UserDefaults.standard.setValue(newSaveEntryId, forKey: "oldSaveEntryIdKey")
                UserDefaults.standard.setValue(newDeviceId,forKey: "oldDeviceIdKey")
                DispatchQueue.main.async {
                    UserDefaults.standard.synchronize()
                }
                
                ///重新排序
                //self.setisShowFor(ArrData: &self.dataArray)
                
                ///滚动到最底部
                if self.isFirst {
                    self.scrollBottom()
                }
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
                var _new = _dicTemp
                if _new["mStatus"] == nil {
                    _new["mStatus"] = 1//已收未读
                }
                self.newMessageActionFor(Data: _new)
                //                self.tableView.reloadData()
                //                self.tableView.beginUpdates()
                //                self.tableView.endUpdates()
                //                self.efScrollToLastCell()
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
                    self.labPageTitle.text = VXIUIConfig.shareInstance.pageName()
                    
                    //切换对话类型埋点
                    if VXIShenCeConfig.shareInstance.isFiveSecondLater == true {
                        if self.shenCeCardType != .All {
                            let _ct = self.getCardTypeBy(Messages: self.dataArray)
                            if _ct != self.shenCeCardType {
                                self.shenCeCardType = _ct
                                
                                let _dic = VXIShenCeConfig.shareInstance.getAdditionalInformationBy(Messages: self.dataArray)
                                VXIShenCeConfig.shareInstance.scViewBuryingPointBy(CSType: self.getCSType(),
                                                                                   andCardType: _ct,
                                                                                   andisHasRG: self.getisHasRG(),
                                                                                   andisHasWelcome: self.getisHasWelcomeBy(Messages: self.dataArray),
                                                                                   withAdditionalInformation: _dic,
                                                                                   andSessionId: self.sessionId ?? "")
                            }
                        }
                    }
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
    private(set) lazy var viewDisappearObs: PublishSubject<Bool> = .init()
    
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
            
            //[S]顶部高度处理
            if self.serviceNavType == .lineup {
                self.serviceNavBgView.isHidden = false
                let _h = 44 + VXIUIConfig.shareInstance.xp_statusBarHeight() + VXIUIConfig.shareInstance.appTopViewHeight()
                var _frame = self.navView.frame
                _frame.size.height = _h
                self.navView.frame = _frame
                
                self.tableView.snp.remakeConstraints{[weak self] make in
                    guard let self = self else { return }
                    make.left.right.equalTo(0)
                    make.top.equalTo(44 + VXIUIConfig.shareInstance.xp_statusBarHeight())
                    make.bottom.equalTo(self.chatView.evInputView.snp.top)
                }
                
                
                debugPrint("ChatServiceNavType-我显示了，\(self.serviceNavType)")
            }
            else{
                self.serviceNavBgView.isHidden = true
                self.labLineUpInfo.text = ""
                var _frame = self.navView.frame
                _frame.size.height = 44 + VXIUIConfig.shareInstance.xp_statusBarHeight()
                self.navView.frame = _frame
                
                self.tableView.snp.remakeConstraints{[weak self] make in
                    guard let self = self else { return }
                    make.left.right.equalTo(0)
                    make.top.equalTo(44 + VXIUIConfig.shareInstance.xp_statusBarHeight())
                    make.bottom.equalTo(self.chatView.evInputView.snp.top)
                }
                
                debugPrint("ChatServiceNavType-我隐藏了，\(self.serviceNavType)")
            }
            //[E]
        }
    }
    
    /// system robot 算非人工,其他都算人工
    private lazy var _receptionistId:String? = nil
    
    private lazy var labPageTitle:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: VXIUIConfig.shareInstance.pageName(),
                                          textColor: VXIUIConfig.shareInstance.pageTitleColor(),
                                          font: VXIUIConfig.shareInstance.pageTitleFont(),
                                          andTextAlign: .center)
        _lab.isUserInteractionEnabled = false
        return _lab
    }()
    
    /// 导航视图
    private lazy var navView:UIView = {
        let _v = TGSUIModel.createDiyNavgationalViewFor(TitleStr: VXIUIConfig.shareInstance.pageName(),
                                                        andDisposeBag: rx.disposeBag,
                                                        andBackblock: {[weak self] in
            guard let self = self else { return }
            self.backAction()
        },
                                                        andChatServiceNavType: self.serviceNavType) { [weak self] (_bgView,_btnBack) in
            guard let self = self else { return }
            
            //标题
            _bgView.addSubview(self.labPageTitle)
            
            //底部排队导航
            self.configServiceNavBgView()
            _bgView.addSubview(self.serviceNavBgView)
            
            //关闭按钮
            _bgView.addSubview(self.artificialCloseBtn)
            self.artificialCloseBtn.isHidden = true
            
            //转人工
            _bgView.addSubview(self.artificialBtn)
            
            //MARK: 约束
            self.artificialBtn.snp.makeConstraints { make in
                make.centerY.equalTo(_btnBack.snp.centerY)
                make.right.equalTo(-15)
                make.height.equalTo(44)
                make.width.equalTo(55)
            }
            
            self.artificialCloseBtn.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.equalTo(52)
                make.height.equalTo(18.5)
                make.centerY.equalTo(self.serviceNavBgView)
                make.right.equalTo(-15)
            }
            
            self.serviceNavBgView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.equalTo(VXIUIConfig.shareInstance.appTopViewHeight())
                make.bottom.equalTo(0)
            }
            
            self.labPageTitle.snp.makeConstraints { make in
                make.left.right.equalTo(0)
                make.height.equalTo(44)
                make.centerY.equalTo(_btnBack.snp.centerY)
            }
        }
        return _v
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
    
    /// 底部视图
    private lazy var serviceNavBgView:UIView = .init(frame: .zero)
    
    //MARK: 转人工
    /// 转人工
    private lazy var artificialBtn:UIButton = {[unowned self] in
        let _f = TGSUIModel.getThemFontsConfig()?.cckf_trans_user_text_size ?? 13
        var _font:UIFont = UIFont.init(name: "AdihausDIN-Regular", size: _f) ?? UIFont.systemFont(ofSize: _f, weight: .regular)
        var _txtColor:UIColor = TGSUIModel.createColorHexInt(0x424242)
        if VXIUIConfig.shareInstance.isBlueTop() {
            _txtColor = .white
            _font = UIFont.init(name: "AdihausDIN-Regular", size: 11) ?? UIFont.systemFont(ofSize: 11, weight: .regular)
        }
        let btn = TGSUIModel.createBtn(rect: .zero,
                                       strTitle: "转人工",
                                       titleColor: _txtColor,
                                       txtFont: _font,
                                       image: nil,
                                       backgroundColor: .clear)
        
        btn.rx.safeTap.subscribe { [weak self](event) in
            guard let self = self else { return }
            debugPrint("转人工")
            
            self.view.endEditing(true)
            self.viewModel.convertArtificialPublishSubject.onNext((0,false))
            
            //转人工埋点
            let _dic = VXIShenCeConfig.shareInstance.getAdditionalInformationBy(Messages: self.dataArray)
            VXIShenCeConfig.shareInstance.scButtonClickBuryingPointBy(ButtonType: .rg,
                                                                      andButtonName: "转人工",
                                                                      withAdditionalInformation: _dic,
                                                                      andSessionId: self.sessionId)
        }.disposed(by: rx.disposeBag)
        
        return btn
    }()
    
    //MARK: 结束会话
    /// 关闭按钮
    private lazy var artificialCloseBtn:UIButton = {[unowned self] in
        var _f:UIFont = UIFont.init(name: "AdihausDIN-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .regular)
        var _txtColor:UIColor = TGSUIModel.createColorHexInt(0x000000)
        if VXIUIConfig.shareInstance.isBlueTop() {
            _txtColor = .white
            _f = UIFont.init(name: "AdihausDIN-Regular", size: 11) ?? UIFont.systemFont(ofSize: 11, weight: .regular)
        }
        
        let closeBtn = TGSUIModel.createBtn(rect: .zero,
                                            strTitle: "结束会话",
                                            titleColor: _txtColor,
                                            txtFont:_f,
                                            image: nil,
                                            backgroundImage: nil)
        closeBtn.contentHorizontalAlignment = .right
        
        closeBtn.rx.safeTap.subscribe { [weak self](event) in
            guard let self = self else { return }
            self.view.endEditing(true)
            self.zhPopupStop.show()
        }.disposed(by: rx.disposeBag)
        
        return closeBtn
    }()
    
    private lazy var isViewWillAppend:Bool = false
    
    private lazy var stopCustomAlertBoxView:CustomAlertBoxView = {
        let _v = CustomAlertBoxView.init(title: "结束会话",
                                         andSubtitle: "确定结束会话吗？如有需要，欢迎随时与我联",
                                         andLeft: "继续咨询",
                                         withRight: "结束会话")
        _v.leftBlock = {[weak self] in
            guard let self = self else { return }
            self.zhPopupStop.dismiss()
        }
        
        _v.rightBlock = {[weak self] in
            guard let self = self else { return }
            self.zhPopupStop.dismiss()
            VXISocketManager.share.stopSocketIO(isNavgationback: false)
        }
        
        return _v
    }()
    
    private lazy var zhPopupStop:zhPopupController = {
        let _pop = zhPopupController.init(view: self.stopCustomAlertBoxView,
                                          size: self.stopCustomAlertBoxView.frame.size)
        _pop.layoutType = .center
        //_pop.presentationStyle = .fromBottom
        
        _pop.willDismissBlock = {[weak self] (pop) in
            guard let self = self else { return }
            self.cancelCustomAlertBoxView.removeFromSuperview()
        }
        
        return _pop
    }()
    
    //MARK: 排队信息
    /// 排队信息
    private lazy var labLineUpInfo:YYLabel = {
        var _txtColor:UIColor = TGSUIModel.createColorHexInt(0x363738)
        if VXIUIConfig.shareInstance.isBlueTop() {
            _txtColor = .white
        }
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "加载中，请稍后...",
                                          textColor: _txtColor,
                                          font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                          andTextAlign: .left,
                                          andisdisplaysAsync: false)
        _lab.isHidden = true
        return _lab
    }()
    
    /// 取消排队
    private lazy var btnCancelLineup:UIButton = {[unowned self] in
        var _txtColor:UIColor = .colorFromRGB(0x000000)
        if VXIUIConfig.shareInstance.isBlueTop() {
            _txtColor = .white
        }
        let closeBtn = TGSUIModel.createBtn(rect: .zero,
                                            strTitle: "取消排队",
                                            titleColor: _txtColor,
                                            txtFont: UIFont.init(name: "AdihausDIN-Regular", size: 13) ?? .systemFont(ofSize: 13, weight: .regular),
                                            image: nil,
                                            backgroundImage: nil)
        closeBtn.contentHorizontalAlignment = .right
        
        closeBtn.rx.safeTap.subscribe { [weak self](event) in
            guard let self = self else { return }
            self.view.endEditing(true)
            self.zhPopupCancel.show()
        }.disposed(by: rx.disposeBag)
        
        closeBtn.isHidden = true
        return closeBtn
    }()
    
    private lazy var cancelCustomAlertBoxView:CustomAlertBoxView = {
        let _v = CustomAlertBoxView.init(title: "取消排队",
                                         andSubtitle: "确定取消排队吗，如有需要欢迎随时联系。",
                                         andLeft: "继续等待",
                                         withRight: "取消排队")
        _v.leftBlock = {[weak self] in
            guard let self = self else { return }
            self.zhPopupCancel.dismiss()
        }
        
        _v.rightBlock = {[weak self] in
            guard let self = self else { return }
            self.zhPopupCancel.dismiss()
            VXISocketManager.share.stopSocketIO(isNavgationback: false)
        }
        
        return _v
    }()
    
    private lazy var zhPopupCancel:zhPopupController = {
        let _pop = zhPopupController.init(view: self.cancelCustomAlertBoxView,
                                          size: self.cancelCustomAlertBoxView.frame.size)
        _pop.layoutType = .center
        //_pop.presentationStyle = .fromBottom
        
        _pop.willDismissBlock = {[weak self] (pop) in
            guard let self = self else { return }
            self.cancelCustomAlertBoxView.removeFromSuperview()
        }
        
        return _pop
    }()
    
    
    //MARK: 对外暴露
    /// 隐私确认
    /// true 同意，false 拒绝
    public var guestPrivacyAcceptBlock:((Bool)->Void)? = nil
    
    //    var _entryId: String? = nil
    //    var _um: UserMappingModel? = nil
}


//MARK: -  对外暴露方法
extension CCKFApi {
    
    /// SDK版本
    /// - Parameter isShort: Bool true 短版本信息，false 长版本信息 默认
    /// - Returns: String
    public static func getSDKVersion(isShort:Bool = false) -> String {
        
        
        
        guard let infoDictionary = Bundle(for: CCKFApi.self).infoDictionary else {
            return ""
        }
        
        if isShort == true {
            //短版本信息 x.x.x
            return String.init(format:"%@",infoDictionary["CFBundleShortVersionString"] as! CVarArg)
        }
        else{
            //长版本信息 x.x.x.x
            return String.init(format:"%@.%@",infoDictionary["CFBundleShortVersionString"] as! CVarArg,Bundle.main.infoDictionary!["CFBundleVersion"] as! CVarArg)
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
        //还原初始状态
        VXIShenCeConfig.shareInstance.isFiveSecondLater = false
        self._receptionistId = nil
        //        self._entryId = entryId
        
        //秘钥
        VXISocketManager.share.appKey = appkey
        
        //埋点辅助信息
        VXISocketManager.share.platform = userMappings.app_name ?? "COM"
        VXISocketManager.share.environment = userMappings.env_name ?? "test"
        
        //域名
        UserDefaults.standard.setValue(host, forKey: VXIUIConfig.shareInstance.getHostKey())
        
        //DeviceId
        var _um = userMappings

        if _um.deviceId == nil || _um.deviceId?.isEmpty == true {
            _um.deviceId = TGSUIModel.getDeviceUUID()
        }
        
        ///存储deviceId和entryId 在请求历史数据做校验，两者一样消息发送的数据才显示，不一样就只用请求的数据
        UserDefaults.standard.setValue(entryId, forKey: "kSaveEntryIdKey")
        DispatchQueue.main.async {
            UserDefaults.standard.synchronize()
        }
        //检查隐私政策
        self.privacyCheckBy(EntryId: entryId,
                            andUserMappings: _um) {[weak self] in
            guard let self = self else { return }
            
            VXISocketManager.share.callBack = callBack
            
            //无改变
            if VXISocketManager.share.xentry == entryId && VXISocketManager.share.uMolde != nil
                && VXISocketManager.share.uMolde == _um {
                self.show()
            }
            //已改变
            else{
                VXISocketManager.share.uMolde = _um
                
                //先关闭
                self.close()
                
                //开启SocketIO
                VXISocketManager.share.startSocketIOFor(XEntry: entryId)
            }
        }
    }
    
    //    private func _start() {
    ////        VXISocketManager.share.callBack = callBack
    //
    //        //无改变
    ////        if VXISocketManager.share.xentry == entryId && VXISocketManager.share.uMolde != nil
    ////            && VXISocketManager.share.uMolde == _um {
    ////            self.show()
    ////        }
    ////        //已改变
    ////        else{
    //        VXISocketManager.share.uMolde = self._um
    //
    //            //先关闭
    //            self.close()
    //
    //            //开启SocketIO
    //        VXISocketManager.share.startSocketIOFor(XEntry: self._entryId)
    ////        }
    //    }
    
    
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
            VXISocketManager.share.startSocketIOFor(XEntry: _eid)
            
            self.guestPrivacyAcceptBlock?(true)
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
                                                  withSocketId: nil)
            
            self.guestPrivacyAcceptBlock?(true)
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
                
                ///拦截非法卡片消息
                guard msgBody.cardType != nil && msgType == 10  else { return }
                
                print(_dic ?? "--")
                
                let message = MessageModel()
                message.timestamp = TGSUIModel.localUnixTimeForInt() * 1000
                //message.timeFormatInfo = TGSUIModel.setIMMessageTimeFor(LastTime: message.timestamp)
                message.renderMemberType = MessageDirection.send.rawValue
                message.cMid = NSUUID().uuidString
                message.mType = msgType
                message.messageBody = msgBody
                
                self.tableView.beginUpdates()
                
                self.dataArray.append(message)
                self.saveRealmFor(Data: message)
                self.tableView.insertRows(at: [IndexPath.init(row: dataArray.count-1, section: 0)], with: .none)
                self.tableView.endUpdates()
                
                self.efScrollToLastCell()
                
                /// 发送
                VXIChatViewModel.conversationSendFor(Type: msgType,
                                                     andClientMessageId: VXIUIConfig.shareInstance.getClientMIdFor(Mid: message.cMid),
                                                     andBody: _dic!,
                                                     andisLoading: true,
                                                     withPublishSubject: nil) {[weak self] (_isOk:Bool, _msg:String) in
                    guard let self = self else { return }
                    if _isOk {
                        //                        VXIUIConfig.shareInstance.keyWindow().showSuccessInfo(at: _msg)
                        debugPrint("发送消息成功！详见：\(_msg)")
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
    ///开启定时器
    private func startTimer(){
        /// 定时更新未读消息
        startUnreadMessageTimer()
        // 将订阅添加到disposeBag中以自动管理其生命周期
        unReadMessageSubscription?.disposed(by: rx.disposeBag)
    }
    
    //MARK: 排队
    /// 排队信息更新
    private func updateLineupFor(Model _m:GuestqueuepromptModel) {
        if let _str = _m.promptWord,let _c = _m.queueNumber {
            self.labLineUpInfo.attributedText = TGSUIModel.createAttributed(textString: _str,
                                                                            normalFont: self.labLineUpInfo.font,
                                                                            normalColor: self.labLineUpInfo.textColor,
                                                                            highLightString:"\(_c)",
                                                                            highLightFont:self.labLineUpInfo.font,
                                                                            highLightColor: self.labLineUpInfo.textColor)
        }
    }
    
    //MARK: 创建UI
    /// 创建UI
    private func setUI(){
        self.view.addSubview(self.navView)
        
        /// app将要进入前台
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification, object: nil).subscribe {[weak self] (_:Event<Notification>) in
            guard let self = self else { return }
            NSLog("我进入前台了")
            /*修复bug 非SDK页面出现loading
             1.进入客服页面
             2.返回手机页面，保持CFD app后台运行
             3.再次进入 CFD app
             就会出现这个loading效果
             */
            if (self.isViewLoaded && (self.view.window != nil)) {
                print("我在SDK的里面屏幕上，正常loading加载数据")
                self.isViewWillAppend = true
                self.loadData(isReload: true)
                self.isViewWillAppend = false
                
                if VXISocketManager.share.socketManager?.status.active == false {
                    debugPrint("SocketManager 连接已关闭，需要重连")
                    self.shePromptInfoBy(Text: "正在重新连接客服...",andisShow: true)
                    
                    //重连
                    VXISocketManager.share.cliectReconnect()
                }
                ///进入前台开启定时器
                self.startTimer()
            }else{
                return
            }
            
        }.disposed(by: rx.disposeBag)
        
        /// app将要进入后台
        NotificationCenter.default.rx.notification(UIApplication.willResignActiveNotification, object: nil).subscribe {[weak self] (_:Event<Notification>) in
            guard let self = self else { return }
            NSLog("我进入后台了")
            self.stopUnreadMessageTimer()
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
        
        /// 埋点透传
        NotificationCenter.default.rx.notification(VXIUIConfig.shareInstance.getBuryingPoint(), object: nil).subscribe {[weak self] (_input:Event<Notification>) in
            guard let self = self else { return }
            let _userInfo = _input.element?.userInfo
            if let _eventName = _userInfo?["name"] as? String,
               let _points = _userInfo?["points"] as? [String:String] {
                self.conversionDelegate?.trackEvent(name: _eventName, attributes: _points)
            }
        }.disposed(by: rx.disposeBag)
        
        /// 进入会话结果
        VXISocketManager.share.viewModel.enterSectionPublishSubject
        //.take(until: viewDisappearObs)
            .subscribe { [weak self] (_input:Event<Any>) in
                guard let self = self else { return }
                guard let (_isOK,_msg) = _input.element as? (Bool,String) else { return }
                if _isOK == false {
                    VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
                }
                else if _isOK == true {
                    NSLog("enterSectionPublishSubject-进入会话成功")
                    if self.isViewWillAppend == true {
                        self.loadData(isReload: true)
                        NSLog("loadData:我加载了-YES")
                        self.isViewWillAppend = false
                    }
                    else{
                        NSLog("loadData:我加载了-NO")
                        
                        //进线卡片 :放到加载完历史数据
                        if VXISocketManager.share.callBack != nil {
                            VXISocketManager.share.callBack?()
                            VXISocketManager.share.callBack = nil
                        }
                    }
                    
                    //进入到CS界面埋点(延迟5秒)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        VXIShenCeConfig.shareInstance.isFiveSecondLater = true
                        let _dic = VXIShenCeConfig.shareInstance.getAdditionalInformationBy(Messages: self.dataArray)
                        VXIShenCeConfig.shareInstance.scViewBuryingPointBy(CSType: self.getCSType(),
                                                                           andCardType: self.getCardTypeBy(Messages: self.dataArray),
                                                                           andisHasRG: self.getisHasRG(),
                                                                           andisHasWelcome: self.getisHasWelcomeBy(Messages: self.dataArray),
                                                                           withAdditionalInformation: _dic,
                                                                           andSessionId: self.sessionId ?? "")
                    }
                }
            }
            .disposed(by: rx.disposeBag)
        
        /// 定时更新未读消息
        self.startTimer()
        
        //        /// 定时更新未读消息
        //        Observable<Int>.timer(RxTimeInterval.seconds(VXIUIConfig.shareInstance.getThrottleTimeinterval()),         //首次产生第一个指的时间
        //                              period: RxTimeInterval.seconds(VXIUIConfig.shareInstance.getThrottleTimeinterval()), //时间间隔
        //                              scheduler: MainScheduler.instance).subscribe {[weak self] (_input:Event<Int>) in
        //            guard let self = self else { return }
        //            self.unReadActionFor(Direction: nil, andArram: nil)
        //        }.disposed(by: rx.disposeBag)
        
        /// 消息通知
        NotificationCenter.default.rx.notification(VXIUIConfig.shareInstance.getSocketMessage(), object: nil).subscribe {[weak self] (_input:Event<Notification>) in
            guard let self = self else { return }
            guard let _userInfo = _input.element?.userInfo else { return }
            self.socketReceiveMessageFor(Event: _userInfo["event"] as? SocketReceiveEvent,
                                         andMessageInfo: _userInfo["messageInfo"] as? [Any])
        }.disposed(by: rx.disposeBag)
        
        /// 连接状态
        NotificationCenter.default.rx.notification(VXIUIConfig.shareInstance.getSocketManagerConnect(), object: nil).subscribe {[weak self] (_input:Event<Notification>) in
            guard let self = self else { return }
            guard let _userInfo = _input.element?.userInfo else { return }
            self.socketConnectChangeFor(ClientEvent: _userInfo["clientEvent"] as? SocketClientEvent,
                                        andSocketIOStatus: _userInfo["socketIOStatus"] as? SocketIOStatus)
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
    
    //MARK: 隐私政策
    /// 检查隐私政策
    private func privacyCheckBy(EntryId _eid:String,
                                andUserMappings _um:UserMappingModel,
                                andFinishBlock _fb:(()->Void)?){
        //是否需要调用隐私检测
        if _um.identity_id == nil || _um.identity_id?.isEmpty == true {
            VXISocketManagerViewModel.getAccessAuthorizeFor(XEntry: _eid,
                                                            andTenantId: nil,
                                                            andEntryName: _um.visitor_name ?? "",
                                                            andPhone: _um.phone ?? "",
                                                            andEmail: _um.email ?? "",
                                                            andDeviceId: _um.deviceId,
                                                            withRACSubscriber: nil) {[weak self] (_gid:String?, _msg:String) in
                guard let self = self else { return }
                if _gid != nil && _gid?.isEmpty == false {
                    VXIChatViewModel.getPrivacyCheck(Loading: true,
                                                     andEntryId: _eid,
                                                     andDeviceId: _gid!,
                                                     andPublishSubject: nil) {[weak self] (_isOk:Bool, _result:Any?) in
                        guard let self = self else { return }
                        if _isOk {
                            let _m = _result as? VXIGuestPrivacyCheckModel
                            //已确认，放行
                            if _m?.accepted != nil {
                                _fb?()
                                self.guestPrivacyAcceptBlock?(true)
                            }
                            //当访客未确认任何隐私协议信息时该字段返回内容为Null
                            else{
                                let _v = CustomAlertBoxView.init(title: "隐私政策",
                                                                 andSubtitle: _m?.privacy?.content ?? "为了确保服务质量和更好解答您的问题，客户服务可能收集您的个人信息，并保存聊天记录。",
                                                                 andLeft: "拒绝",
                                                                 withRight: "同意并继续")
                                
                                let _pop = zhPopupController.init(view: _v,
                                                                  size: _v.frame.size)
                                _pop.layoutType = .center
                                _pop.dismissOnMaskTouched = false
                                
                                _pop.willDismissBlock = { (pop) in
                                    _v.removeFromSuperview()
                                }
                                
                                //拒绝
                                _v.leftBlock = {[weak self] in
                                    guard let self = self else { return }
                                    _pop.dismiss()
                                    
                                    //返回
                                    self.backAction()
                                    self.guestPrivacyAcceptBlock?(false)
                                }
                                
                                //同意
                                _v.rightBlock = {[weak self] in
                                    guard let self = self else { return }
                                    _pop.dismiss()
                                    
                                    //调用同意接口
                                    VXIChatViewModel.submitPrivacyAcceptBy(Version: _m?.privacy?.version ?? "v_dpp2024",
                                                                           andEntryId: _eid,
                                                                           andDeviceId: _gid!,
                                                                           andLoading: false) {[weak self] (_isOk:Bool, _msg:String) in
                                        guard let self = self else { return }
                                        if _isOk {
                                            //放行
                                            _fb?()
                                            self.guestPrivacyAcceptBlock?(true)
                                        }
                                        else{
                                            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
                                            
                                            //返回
                                            self.backAction()
                                            self.guestPrivacyAcceptBlock?(false)
                                        }
                                    }
                                }
                                
                                _pop.show()
                            }
                        }
                        else{
                            self.guestPrivacyAcceptBlock?(false)
                            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _result as? String ?? "隐私政策加载失败")
                        }
                    }
                }
                else{
                    debugPrint("privacyCheckBy-失败！详见：{_gid:\(_gid ?? "--"),_msg:\(_msg)}")
                    VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
                    
                    //返回
                    self.backAction()
                    self.guestPrivacyAcceptBlock?(false)
                }
            }
        }
        //放行
        else{
            _fb?()
            self.guestPrivacyAcceptBlock?(true)
        }
    }
    
    /// 返回
    private func backAction(){
        ///结束编辑状态
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: 埋点辅助信息
    /// 所显示的其他卡片类型
    private func getCardTypeBy(Messages _msgs:[MessageModel]?) -> VXISCCardType {
        if _msgs?.firstIndex(where: { $0.messageBody?.cardType == 1 }) != nil && _msgs?.firstIndex(where: { $0.messageBody?.cardType == 2 }) != nil {
            return .All
        }
        else {
            if _msgs?.firstIndex(where: { $0.messageBody?.cardType == 1 }) != nil {
                return .Order
            }
            else if _msgs?.firstIndex(where: { $0.messageBody?.cardType == 2 }) != nil {
                return .Product
            }
        }
        
        return .NULL
    }
    
    /// 是否有转人工入口
    private func getisHasRG() -> VXISCRG {
        if self.artificialBtn.isHidden == false {
            return .True
        }
        
        return .False
    }
    
    /// 当前对话进行是机器人还是人工
    private func getCSType() -> VXISCCSType {
        return self.serviceNavType == .lineing ? .RG : .robot
    }
    
    /// 是否有欢迎卡片
    private func getisHasWelcomeBy(Messages _msgs:[MessageModel]?) -> VXISCWelcome {
        if _msgs?.firstIndex(where: { $0.mType == MessageBodyType.machineAnswer.rawValue }) != nil {
            return .True
        }
        return .False
    }
}


//MARK: - 会话
extension CCKFApi {
    
    //MARK: 会话状态处理
    /// 会话状态处理
    private func updateConversationFor(Model _m: GuestSessionModel){
        self.sessionId = _m.sessionId
        self.eid = _m.eId
        
        //本会话信息
        let _current_receptionistId = _m.receptionistId?.lowercased()
        let oldReceptionID = self._receptionistId
        self._receptionistId = _current_receptionistId
        
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
            self.labPageTitle.text = VXIUIConfig.shareInstance.pageName()
        }
        
        // 如果排队中，显示取消排队按钮
        if _m.sessionStatus == SessionStatus.isQueuing.rawValue && _m.sessionType == SessionType.queuing.rawValue {
            self.serviceNavType = .lineup
        }
        
        // 如果咨询中，显示结束会话按钮
        if _m.sessionStatus == SessionStatus.isSuccess.rawValue {
            self.serviceNavType = .lineing
            self.labPageTitle.text = VXIUIConfig.shareInstance.pageName()
            serviceNavNameLabel.text = _m.receptionistName
            
            //切换对话类型埋点
            if VXIShenCeConfig.shareInstance.isFiveSecondLater == true {
                //                if self.shenCeCardType != .All {
                
                let _reportBlock = {[weak self] in
                    guard let self = self else { return }
                    let _ct = self.getCardTypeBy(Messages: self.dataArray)
                    //                        if _ct != self.shenCeCardType {
                    //                            self.shenCeCardType = _ct
                    
                    let _dic = VXIShenCeConfig.shareInstance.getAdditionalInformationBy(Messages: self.dataArray)
                    VXIShenCeConfig.shareInstance.scViewBuryingPointBy(CSType: self.getCSType(),
                                                                       andCardType: _ct,
                                                                       andisHasRG: self.getisHasRG(),
                                                                       andisHasWelcome: self.getisHasWelcomeBy(Messages: self.dataArray),
                                                                       withAdditionalInformation: _dic,
                                                                       andSessionId: self.sessionId ?? "")
                    //                        }
                }
                
                if (_current_receptionistId == "system" || _current_receptionistId == "robot") && (oldReceptionID != "system" && oldReceptionID != "robot")  {
                    //                        self._receptionistId = _current_receptionistId
                    _reportBlock()
                }
                else if (_current_receptionistId != "system" && _current_receptionistId != "robot") && (oldReceptionID == "system" || oldReceptionID == "robot") {
                    //                        self._receptionistId = _current_receptionistId
                    _reportBlock()
                }
                //                }
            }
        }
        else if _m.sessionStatus == SessionStatus.isTerminated.rawValue {
            let _ct = self.getCardTypeBy(Messages: self.dataArray)
            let _dic = VXIShenCeConfig.shareInstance.getAdditionalInformationBy(Messages: self.dataArray)
            VXIShenCeConfig.shareInstance.scViewBuryingPointBy(CSType: self.getCSType(),
                                                               andCardType: _ct,
                                                               andisHasRG: .True,
                                                               andisHasWelcome: self.getisHasWelcomeBy(Messages: self.dataArray),
                                                               withAdditionalInformation: _dic,
                                                               andSessionId: self.sessionId ?? "")
        }
    }
    
    private func reloadRows(_index: Int) throws -> Void {
        tableView.reloadRows(at: [IndexPath.init(row: _index, section: 0)], with: .none)
    }
    //MARK: 新会话消息处理
    /// 新会话消息处理
    /// - Parameter _d: <#_d description#>
    private func newMessageActionFor(Data _d:[String:Any]){
        //消息时间，服务端编号更新
        if let _mid = _d["mId"] as? Int64,
           let _cMid = _d["cMid"] as? String,
           let _createTime = _d["createTime"] as? Double {
            let _index:Int? = self.dataArray.firstIndex(where: { $0.cMid == _cMid })
            if _index != nil {
                let _m = self.dataArray[_index!]
                //do{
                //RLMRealm.default().beginWriteTransaction()
                _m.mId = _mid
                //_m?.cMid = "\(_mid)"
                _m.createTime = _createTime
                //更新状态
                if let _s = _d["mStatus"] as? Int {
                    if _m.mStatus != _s {
                        _m.mStatus = _s
                        //列更新
                        
                        let isInRows = self.tableView.indexPathsForVisibleRows?.contains(IndexPath.init(row: _index!, section: 0))
                        
                        let lastRow = self.tableView.numberOfRows(inSection: 0) - 1
                        debugPrint("tableView.numberOfSections.UP: DataIndex:\(_index!) LastRow:\(lastRow) IsInRows:\(String(describing: isInRows)) \(String(describing: self.tableView.indexPathsForVisibleRows))")
                        
                        if lastRow >= _index! {
                            self.tableView.reloadRows(at: [IndexPath.init(row: _index!, section: 0)], with: .none)
                        }
                        
                    }
                }
                
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
                        
                        if _result.messageBody?.content?.contains("撤回") == true && _result.mType == 7 {
                            NSLog("撤回消息又被重新推送过来过滤:{mId:\(_result.mId ?? 0),createTime:\(_result.createTime ?? 0),mType:\(_result.mType ?? 0),renderMemberType:\(_result.renderMemberType ?? 0),_result:\(_result),mStatus:\(_result.mStatus ?? 0)}")
                        }
                        else{
                            if _index == nil {
                                //                                if self.dataArray.isEmpty {
                                //                                    self.dataArray = [_result]
                                //                                    self.saveLocationUpdateFor(Size: self.dataArray.count - 1)
                                //                                } else {
                                //                                    let _rct =  _result.createTime ?? TGSUIModel.localUnixTimeDouble()
                                //                                _result.timeFormatInfo = TGSUIModel.setIMMessageTimeFor(LastTime: _rct)
                                //                                    if let _dalct = self.dataArray.last?.createTime, _rct > _dalct {

                                
//                                UIView.performWithoutAnimation
                                
                                DispatchQueue.main.async {
                                    self.dataArray.append(_result)
                                    
                                    let lastRow = self.tableView.numberOfRows(inSection: 0) - 1
                                    let i = max(self.dataArray.count - 1,0)
                                    debugPrint("tableView.numberOfSections.LN: IndexPath:\(i) LastRow\(lastRow) \(String(describing: self.tableView.indexPathsForVisibleRows))")
                                    UIView.performWithoutAnimation{
                                        self.tableView.beginUpdates()
                                        self.tableView.insertRows(at: [.init(row: i, section: 0)], with: .none)
                                        self.tableView.endUpdates()
                                    }
                                    self.tableView.scrollToRow(at: .init(row: i, section: 0), at: .bottom, animated: true)
                                }

                                //                                        self.saveRealmFor(Data: _result)
                                //                                        self.saveLocationUpdateFor(Size: self.dataArray.count - 1)
                                
                                NSLog("会话消息已新增:{mId:\(_result.mId ?? 0),createTime:\(_result.createTime ?? 0)，mType:\(_result.mType ?? 0),renderMemberType:\(_result.renderMemberType ?? 0),_result:\(_result),mStatus:\(_result.mStatus ?? 0)}")
                                //                                    }
                                //                                    //排序
                                //                                    else{
                                //                                        if let _index = self.dataArray.lastIndex(where: { _rct <= $0.createTime ?? .zero }) {
                                //                                            self.dataArray.insert(_result, at: _index)
                                //                                            self.saveRealmFor(Data: _result)
                                //                                            self.saveLocationUpdateFor(Size: _index)
                                //                                            NSLog("会话消息已插入新增:{\(_index),mId:\(_result.mId ?? 0),createTime:\(_result.createTime ?? 0),mType:\(_result.mType ?? 0),renderMemberType:\(_result.renderMemberType ?? 0),_result:\(_result),mStatus:\(_result.mStatus ?? 0)}")
                                //                                        }
                                //                                    }
                                //                                }
                            }
                            else if self.dataArray.count > _index! {
                                let localModel = self.dataArray[_index!]
                                _result.timeFormatInfo = localModel.timeFormatInfo
                                self.dataArray[_index!] = _result
                                ///本地存在语音路径
                                if let _voiceLocalPath = localModel.messageBody?.voiceLocalPath{
                                    NSLog("本地存在语音路径 SSSSSS")
                                    self.dataArray[_index!].messageBody?.voiceLocalPath = _voiceLocalPath
                                }
                                
                                NSLog("会话消息已更新:{index:\(_index!),mStatus:\(_result.mStatus ?? 0)}")
                            }
                        }
                        
                        //订单/商品卡片埋点
                        if VXIShenCeConfig.shareInstance.isFiveSecondLater == true {
                            if _result.messageBody?.cardType == 1 || _result.messageBody?.cardType == 2 {
                                let _ct = self.getCardTypeBy(Messages: [_result])
                                if _ct != self.shenCeCardType {
                                    self.shenCeCardType = _ct
                                    
                                    let _dic = VXIShenCeConfig.shareInstance.getAdditionalInformationBy(Messages: [_result])
                                    VXIShenCeConfig.shareInstance.scViewBuryingPointBy(CSType: self.getCSType(),
                                                                                       andCardType: _ct,
                                                                                       andisHasRG: self.getisHasRG(),
                                                                                       andisHasWelcome: self.getisHasWelcomeBy(Messages: [_result]),
                                                                                       withAdditionalInformation: _dic,
                                                                                       andSessionId: _result.sessionId ?? self.sessionId ?? "")
                                }
                            }
                        }
                        
                        
                        
                        debugPrint("MessageModel:\(_result)")
                        debugPrint("isScrollToBottom:\(self.isScrollToBottom())")
                        debugPrint("visibleCells:\(self.tableView.visibleCells.count) \(self.tableView.visibleSize.height)")
                        ///新消息滚动到最底部
                        
                        
                        
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
                //                self.setisShowFor(ArrData: &self.dataArray)
                //                self.tableView.reloadData()
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
            
            let _m = self.dataArray[_index]
            _m.messageBody?.content = "对方撤回了一条消息"
            if MessageDirection.init(rawValue: _m.renderMemberType ?? 0).isSend() == true {
                _m.messageBody?.content = "我撤回了一条消息"
            }
            _m.mStatus = 3
            _m.mType = 7
            _m.renderMemberType = 16
            
            if _index > 0 {
                self.saveLocationUpdateFor(Size: _index - 1)
            }
            else{
                self.saveLocationUpdateFor(Size: 0)
            }
            NSLog("消息撤回:{mId:\(_mid),_index:\(_index)}-移除")
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


//MARK: - 消息、状态处理
extension CCKFApi  {
    
    /// SocketIO 状态处理
    private func socketConnectChangeFor(ClientEvent _ce: SocketIO.SocketClientEvent?,
                                        andSocketIOStatus _ss: SocketIO.SocketIOStatus?) {
        switch _ss {
        case .some(.connected):
            self.shePromptInfoBy(Text: "客服已连接成功",andisShow: false)
            break
            
        case .some(.notConnected):
            self.shePromptInfoBy(Text: "客服的连接已断开=",andisShow: true)
            break
            
        case .some(.disconnected):
            self.shePromptInfoBy(Text: "客服的连接已关闭",andisShow: true)
            VXISocketManager.share.socketManager?.reconnect()
            break
            
        case .some(.connecting):
            if _ce == .reconnectAttempt {
                self.shePromptInfoBy(Text: "尝试重新连接客服...",andisShow: true)
            }
            else{
                self.shePromptInfoBy(Text: "正在连接到客服...",andisShow: true)
            }
            break
            
        default:
            break
        }
    }
    
    
    /// SocketIO 消息处理
    private func socketReceiveMessageFor(Event _ce: SocketReceiveEvent?,
                                         andMessageInfo _msg: [Any]?) {
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
                
                debugPrint("SRE.updateGuestSessionStatus: eId:\(self.eid ?? 0) -> \(_model.eId ?? 0) | sessionType:\(_model.sessionType ?? 0),sessionStatus:\(_model.sessionStatus ?? 0), \((_model.eId ?? 0) > (self.eid ?? 0) ? "PASS" : "DISCARD")")
                
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
