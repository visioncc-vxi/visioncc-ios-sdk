//
//  BaseChatVC.swift
//  YLBaseChat
//
//  Created by yl on 17/5/12.
//  Copyright © 2017年 yl. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Photos
import AVKit
import Alamofire
@_implementationOnly import VisionCCiOSSDKEngine

/// 会话基类
public class BaseChatVC: UIViewController {
    
    /// 事件订阅委托
    public var conversionDelegate:CCKFApiConversationDelegate? = nil
    
    // 上一次播放的语音
    fileprivate lazy var oldChatVoiceMessagemId:Int64? = nil
    
    /// 会话编号
    internal lazy var sessionId:String? = nil
    internal lazy var eid:Int64? = nil
    
    deinit {
        UIDevice.current.isProximityMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self)
        print("====\(self)=====>被释放")
    }
    
    //MARK: - override
    public override func viewWillAppear(_ animated: Bool) {
        
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = VXIUIConfig.shareInstance.appViewControlelrBackgroundColor()
        
        layoutUI()
        
        //禁用黑夜模式
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        
        //网络状态监听
        NetworkReachabilityManager.default?.startListening(onUpdatePerforming: { status in
            //true 有网
            if status != .notReachable {
                self.shePromptInfoBy(Text: "网络连接正常", andisShow: false)
                
                if VXISocketManager.share.socketManager?.status.active == false {
                    debugPrint("SocketManager 连接已关闭，需要重连")
                    self.shePromptInfoBy(Text: "SocketIO 正在重连...",andisShow: true)
                    
                    //重连
                    VXISocketManager.share.cliectReconnect()
                }
            }
            else{
                self.shePromptInfoBy(Text: "当前网络不可用，请检查你的网络设置", andisShow: true)
            }
        })
        
    }
    
    public override func updateViewConstraints() {
        
        if self.view.subviews.contains(self.chatView){
            self.chatView.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.edges.equalTo(self.view)
            }
        }
        
        if self.chatView.subviews.contains(self.btnUnread){
            self.btnUnread.snp.makeConstraints { make in
                make.height.equalTo(32)
                make.width.equalTo(147)
                make.centerX.equalToSuperview()
                make.top.equalTo(VXIUIConfig.shareInstance.xp_navigationFullHeight() + VXIUIConfig.shareInstance.topAdditionalViewHeight() + 12)
            }
        }
        
        if self.chatView.subviews.contains(self.labReconnect){
            self.labReconnect.snp.makeConstraints { make in
                make.height.equalTo(32)
                make.left.right.equalTo(0)
                make.top.equalTo(VXIUIConfig.shareInstance.xp_navigationFullHeight() + VXIUIConfig.shareInstance.topAdditionalViewHeight())
            }
        }
        
        super.updateViewConstraints()
    }
    
    //MARK: - init
    fileprivate func layoutUI() {
        
        self.view.addSubview(self.chatView)
        self.chatView.insertSubview(self.tableView, at: 0)
        self.chatView.addSubview(self.btnUnread)
        self.chatView.addSubview(self.labReconnect)
        
        /// 监听用户耳朵靠近手机或者远离手机
        NotificationCenter.default.rx.notification(UIDevice.proximityStateDidChangeNotification, object: nil).subscribe { (_:Event<Notification>) in
            if UIDevice.current.proximityState == true {
                VoiceManager.shared.isProximity(false)
            }else {
                VoiceManager.shared.isProximity(true)
            }
        }.disposed(by: rx.disposeBag)
        
        //MARK: 下拉加载历史
        //[S]下拉加载更多消息
        let header:JRefreshNormalHeader = JRefreshNormalHeader.headerWithRefreshingBlock({[weak self] in
            guard let self = self else { return }
            if self.dataArray.count <= 0 {
                self.loadData()
            }
            else{
                self.loadData(isReload: false)
            }
        }) as! JRefreshNormalHeader
        
        //隐藏时间
        header.lastUpdatedTimeLabel.isHidden = true
        
        //设置文字
        header.setTitle("下拉加载历史", JRefreshState.Idle)
        header.setTitle("开始加载历史数据",JRefreshState.Pulling)
        header.setTitle("拉取历史数据中 ...",JRefreshState.Refreshing)
        
        self.tableView.header = header
        //[E]
        
        /// 滚动监听
        self.tableView.rx.contentOffset.subscribe {[weak self] (_input:Event<CGPoint>) in
            guard let self = self else { return }
            guard let _offset = _input.element else { return }
            if _offset.y <= 0 {
                self.btnUnread.isHidden = true
            }
        }.disposed(by: rx.disposeBag)
    }
    
    internal lazy var viewModel:VXIChatViewModel = {
        return VXIChatViewModel.init()
    }()
    
    internal func bindViewModel(){
        
        /// 满意度评价
        self.viewModel.evaluatSubmitPublishSubject.subscribe {[weak self] (_input:Event<Any>) in
            guard let self = self else { return }
            guard let (_isOK,_msg,_mid) = _input.element as? (Bool,String,Int64) else { return }
            if !_isOK {
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
            }
            //评价成功
            else{
                //更新状态
                if let _index = self.dataArray.firstIndex(where: { $0.mId == _mid }) {
                    self.dataArray[_index].messageBody?.isEvaluated = true
                    self.saveLocationUpdateFor(Size: _index)
                }
            }
            self.evaluatePopupController.dismiss()
        }.disposed(by: rx.disposeBag)
        
        /// 满意度评价修改
        self.viewModel.evaluatupUpdatePublishSubject.subscribe {[weak self] (_input:Event<Any>) in
            guard let self = self else { return }
            guard let (_isOK,_msg,_mid) = _input.element as? (Bool,String,Int64) else { return }
            if !_isOK {
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
            }
            //评价成功
            else{
                //更新状态
                if let _index = self.dataArray.firstIndex(where: { $0.mId == _mid }) {
                    self.dataArray[_index].messageBody?.isEvaluated = true
                    self.saveLocationUpdateFor(Size: _index)
                }
            }
        }.disposed(by: rx.disposeBag)
        
        /// 未读消息状态处理
        self.viewModel.messageReadPublishSubject.subscribe {[weak self] (_input:Event<Any>) in
            guard let self = self else { return }
            guard let (_isOk,_,_lastMessageId,_unreadCount) = _input.element as? (Bool,String,Int64,Int) else { return }
            if _isOk,_unreadCount > 0 {
                self._message_count = 0
                self._lastMessageId = _lastMessageId
                if let _cell = self.getCellByMessage(_lastMessageId),self.tableView.visibleCells.contains(_cell) == false {
                    self.btnUnread.setTitle("\(_unreadCount)条未读消息", for: .normal)
                    self.btnUnread.isHidden = false
                }
            }
            
            if _isOk {
                self.conversionDelegate?.unReadMessageCountEvent(count: _unreadCount)
            }
        }.disposed(by: rx.disposeBag)
        
        /// 有/无帮助
        self.viewModel.questionCommentSubmitPublishSubjct.subscribe {[weak self] (_input:Event<Any>) in
            guard let self = self else { return }
            guard let (_isOk,_msg,_mid,_isHelp) = _input.element as? (Bool,String,Int64,Bool) else { return }
            if !_isOk {
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
            }
            else{
                if _isHelp == false,
                   self.commentIndex != nil,
                   let _index = self.arrComment.firstIndex(where: { $0 == self.commentIndex! }) {
                    self.arrComment.remove(at: _index)
                    let _m = self.dataArray[self.commentIndex!]
                    _m.optionSelected = _isHelp ? "up":"down"
                    self.dataArray[self.commentIndex!] = _m
                    self.tableView.reloadRows(at: [IndexPath.init(row: self.commentIndex!, section: 0)], with: .none)
                }
                else if _isHelp == true,let _index = self.dataArray.firstIndex(where: { $0.mId == _mid }) {
                    let _m = self.dataArray[_index]
                    _m.optionSelected = _isHelp ? "up":"down"
                    self.dataArray[_index] = _m
                    self.tableView.reloadRows(at: [IndexPath.init(row: _index, section: 0)], with: .none)
                }
            }
        }.disposed(by: rx.disposeBag)
    }
    
    //MARK: 输入面板
    /// 聊天主视图
    internal lazy var chatView:ChatView = {
        let _v = ChatView(frame: CGRect.zero)
        _v.delegate = self
        return _v
    }()
    
    //MARK: 会话列表
    internal lazy var isFirst = true
    
    /// 表单
    internal lazy var tableView:UITableView = {[weak self] in
        let _tbv = UITableView(frame: CGRect.zero, style: .plain)
        
        //适配平板
        _tbv.cellLayoutMarginsFollowReadableWidth = false
        
        //防止顶部空白
        if #available(iOS 11.0, *) {
            _tbv.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        }
        
        if #available(iOS 15.0, *) {
            _tbv.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        _tbv.register(ChatTextCell.self, forCellReuseIdentifier: MessageBodyCellIdentify.ChatTextCell.rawValue)
        _tbv.register(ChatImageCell.self, forCellReuseIdentifier: MessageBodyCellIdentify.ChatImageCell.rawValue)
        _tbv.register(ChatVoiceCell.self, forCellReuseIdentifier: MessageBodyCellIdentify.ChatVoiceCell.rawValue)
        _tbv.register(ChatMachineBaseCell.self, forCellReuseIdentifier: MessageBodyCellIdentify.ChatMachineBaseCell.rawValue)
        _tbv.register(ChatMachineTabCell.self, forCellReuseIdentifier: MessageBodyCellIdentify.ChatMachineTabCell.rawValue)
        _tbv.register(ChatProductCell.self, forCellReuseIdentifier: MessageBodyCellIdentify.ChatProductCell.rawValue)
        _tbv.register(ChatAnnexCell.self, forCellReuseIdentifier: MessageBodyCellIdentify.ChatAnnexCell.rawValue)
        _tbv.register(ChatVideoCell.self, forCellReuseIdentifier: MessageBodyCellIdentify.ChatVideoCell.rawValue)
        _tbv.register(ChatOrdersTableViewCell.self, forCellReuseIdentifier: MessageBodyCellIdentify.ChatOrdersCell.rawValue)
        _tbv.register(ChatCardSingleCell.self, forCellReuseIdentifier: MessageBodyCellIdentify.ChatCardSingleCell.rawValue)
        _tbv.register(ChatCardMutableCell.self, forCellReuseIdentifier: MessageBodyCellIdentify.ChatCardMutableCell.rawValue)
        _tbv.register(ChatLikeTextCell.self, forCellReuseIdentifier: MessageBodyCellIdentify.ChatLikeTextCell.rawValue)
        _tbv.register(ChatEventTextCell.self, forCellReuseIdentifier: MessageBodyCellIdentify.ChatEventTextCell.rawValue)
        _tbv.register(ChatEvaluatCell.self, forCellReuseIdentifier: MessageBodyCellIdentify.ChatEvaluatCell.rawValue)
        _tbv.register(ChatLinkTableViewCell.self, forCellReuseIdentifier: MessageBodyCellIdentify.ChatLinkTableViewCell.rawValue)
        
        _tbv.rowHeight = UITableView.automaticDimension
        _tbv.estimatedRowHeight = 100
        
        _tbv.delegate = self
        _tbv.dataSource = self
        
        _tbv.backgroundColor = VXIUIConfig.shareInstance.cellBackgroundColor()
        _tbv.tableFooterView = UIView()
        _tbv.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        return _tbv
    }()
    
    internal lazy var lastMId:Int64? = nil
    
    /// 会话列表数组
    internal lazy var dataArray:Array<MessageModel> = Array<MessageModel>() {
        didSet{
            if self.dataArray.count - oldValue.count >= 1 {
                self._message_count += 1
            }
        }
    }
    
    //MARK: 未读消息
    /// 未读消息
    private lazy var btnUnread:UIButton = {
        let _f:CGFloat = TGSUIModel.getThemFontsConfig()?.cckf_unread_text_size ?? 14
        let _btn = TGSUIModel.createBtn(rect: .zero,
                                        strTitle: "0条未读消息",
                                        titleColor: .white,
                                        txtFont: .systemFont(ofSize: _f, weight: .regular),
                                        image: UIImage(named: "tool_back_up", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil),
                                        backgroundColor: .init().colorFromHexInt(hex: 0x000000, alpha: 0.5))
        
        _btn.contentHorizontalAlignment = .center
        _btn.contentVerticalAlignment = .center
        _btn.layer.cornerRadius = 16
        
        _btn.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            //点击回到顶部
            if self.dataArray.count > 0 {
                self.tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)
            }
            self.btnUnread.isHidden = true
        }.disposed(by: rx.disposeBag)
        
        _btn.isHidden = true
        return _btn
    }()
    private lazy var _lastMessageId:Int64? = nil
    
    /// 消息数量
    private lazy var _message_count:Int = 0 {
        didSet{
            if self._message_count >= VXIUIConfig.shareInstance.getThrottleTimeinterval() {
                self.unReadActionFor(Direction: nil, andArram: nil)
            }
        }
    }
    
    //MARK: 评价信息
    /// 评价BoxView
    private lazy var evaluateBoxView:EvaluateBoxView = {[unowned self] in
        let _v = EvaluateBoxView.init(andViewModel: self.viewModel)
        _v.closeBlock = {[weak self] in
            guard let self = self else { return }
            self.evaluatePopupController.dismiss()
        }
        
        _v.submitBlock = {[weak self] (_pushType,_dicTemp,_dicOptions,_mid,_sid) in
            guard let self = self else { return }
            self.viewModel.evaluatSubmitPublishSubject.onNext((false,_sid ?? self.sessionId ?? "",_pushType,_dicTemp,_dicOptions,_mid))
        }
        
        return _v
    }()
    
    private lazy var evaluatePopupController:zhPopupController = {[unowned self] in
        let _pop = zhPopupController.init(view: self.evaluateBoxView,
                                          size: self.evaluateBoxView.frame.size)
        _pop.layoutType = .bottom
        _pop.presentationStyle = .fromBottom
        
        _pop.willPresentBlock = {[weak self] (pop) in
            guard let self = self else { return }
            self.evaluateBoxView.preView()
        }
        
        _pop.willDismissBlock = {[weak self] (pop) in
            guard let self = self else { return }
            self.evaluateBoxView.removeFromSuperview()
        }
        
        return _pop
    }()
    
    //MARK: 留言信息
    private lazy var leaveMessaheBoxView:LeaveMessageBoxView = {[unowned self] in
        let _v = LeaveMessageBoxView.init(ViewModel: self.viewModel)
        _v.closeBlock = {[weak self] in
            guard let self = self else { return }
            self.leaveMessagePopupController.dismiss()
        }
        
        return _v
    }()
    
    internal lazy var leaveMessagePopupController:zhPopupController = {[unowned self] in
        let _pop = zhPopupController.init(view: self.leaveMessaheBoxView,
                                          size: self.leaveMessaheBoxView.frame.size)
        _pop.layoutType = .bottom
        _pop.presentationStyle = .fromBottom
        
        _pop.willPresentBlock = {[weak self] (pop) in
            guard let self = self else { return }
            VXIUIConfig.shareInstance.initConfigThreadLabs()
            IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        }
        
        _pop.willDismissBlock = {[weak self] (pop) in
            guard let self = self else { return }
            self.leaveMessaheBoxView.clearInfo()
            self.leaveMessaheBoxView.removeFromSuperview()
        }
        
        return _pop
    }()
    
    //MARK: 重连
    private lazy var labReconnect:YYLabel = {
        let _bgc:UIColor = UIColor.init().colorFromHexString(hex: TGSUIModel.getThemColorsConfig()?.cckf_chat_remind_bg ?? "#fee3e6")
        let _fc:UIColor = UIColor.init().colorFromHexString(hex: TGSUIModel.getThemColorsConfig()?.cckf_chat_remind_text_color ?? "#fc596a")
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "SocketIO 正在重连...",
                                          textColor: _fc,
                                          font: .systemFont(ofSize: 14, weight: .regular),
                                          backgroundColor:_bgc,
                                          andTextAlign: .center)
        
        _lab.isHidden = true
        _lab.alpha = 0
        _lab.textVerticalAlignment = .center
        return _lab
    }()
    
    //MARK: 点赞设置
    /// 点赞正在操作的列索引集合
    private lazy var arrComment = [Int]()
    private lazy var commentIndex:Int? = nil
}

//MARK: -
extension BaseChatVC{
    
    //MARK: 提示信息
    /// 提示信息
    internal func shePromptInfoBy(Text _t:String?,
                                  andisShow _show:Bool = true){
        self.labReconnect.isHidden = !_show
        UIView.animate(withDuration: TimeInterval.init(floatLiteral: 0.2)) {
            self.labReconnect.alpha = _show ? 1 : 0
        } completion: { _resault in
            if _resault {
                self.labReconnect.text = _t
            }
        }
        
    }
    
    //MARK: 数据加载
    /// 加载数据
    /// socketIO推送 updateGuestSessionStatus事件后 你才可以调用messages的接口
    /// https://yapi.vxichina.cn/project/1476/interface/api/226317
    /// - Parameter isReload: <#isReload description#>
    internal func loadData(isReload:Bool = true) {
        
        self.isFirst = true
        tableView.isScrollEnabled = false
        
        var _mid:Int64 = 0
        if isReload == false,let _id = self.lastMId {
            _mid = _id
            self.isFirst = false
        }
        
        self.viewModel.loadConversationHistoryPublishSubject.onNext((
            isReload ? MessageHistoryDirection.new.rawValue : MessageHistoryDirection.old.rawValue,
            _mid,
            isReload))
        tableView.isScrollEnabled = true
    }
    
    /// 关闭动画
    /// - Parameters:
    ///   - ir: 是否刷新 true 刷新 false 加载更多
    ///   - hnp: 是否有下一页 true 有 false 没有
    internal func stopAnimationFor(Refresh ir:Bool,
                                   andHasNextPage hnp:Bool){
        self.isFirst = false
        
        //结束刷新
        if let _header = self.tableView.header {
            _header.endRefreshing()
            _header.isHidden = !hnp
        }
        
        //首页才滚到底部
        if ir {
            efScrollToLastCell()
        }
        
    }
    
    //MARK: 列定位
    // 滚到最后一行
    internal func efScrollToLastCell() {
        if dataArray.count > 1 {
            tableView.scrollToRow(at: IndexPath(row: dataArray.count-1, section: 0), at: UITableView.ScrollPosition.middle, animated: true)
        }
    }
    
    /// 消息定位更新
    internal func saveLocationUpdateFor(Size s:Int){
        self.tableView.reloadData()
        if self.isFirst == true {
            self.tableView.yl_scrollToBottom(Animated: true)
        }
        else{
            if self.dataArray.count > s {
                if self.isScrollToBottom() {
                    debugPrint("1、s:\(s),dataArray.count:\(self.dataArray.count)")
                    efScrollToLastCell()
                }
                else{
                    debugPrint("2、s:\(s),dataArray.count:\(self.dataArray.count)")
                    self.tableView.selectRow(at: IndexPath.init(row: s - 1, section: 0),
                                             animated: false,
                                             scrollPosition: .top)
                }
            }
        }
    }
    
    /// 是否需要滚到底部
    /// - Returns: true 需要，fasle 不需要
    internal func isScrollToBottom() -> Bool {
        if self.isFirst == true { return true}
        
        let _arrIndexs:[Int] = self.tableView.visibleCells.compactMap({ $0.contentView.tag })
        let _lastIndex = self.dataArray.count
        if _lastIndex > 0 {
            if _arrIndexs.contains(_lastIndex - 1) || _arrIndexs.contains(_lastIndex - 2) {
                //最新的数据在可见区域，需要滚动到底部；反之在查看历史，不用滚动到底部
                return true
            }
        }
        
        return false
    }
    
    
    //MARK: 未读消息处理
    /// 未读消息处理
    /// - Parameters:
    ///   - _direction: String?(首次拉取历史需要传值）
    ///   - _arr: [MessageModel]?(首次拉取历史需要传值）
    internal func unReadActionFor(Direction _direction:String?,
                                  andArram _arr:[MessageModel]?){
        //[S]未读消息处理(针对列表里面的新消息)
        if _direction != nil && _arr != nil && MessageHistoryDirection.new.rawValue == _direction {
            let _arrTemp = _arr!.filter({ MessageDirection(rawValue: $0.renderMemberType ?? 0).isSend() == false && MessageReadStatus.init(rawValue: $0.mStatus ?? 0) != .read })
            if _arrTemp.count >= 20,let _mid = _arrTemp.last?.mId {
                let _count = _arrTemp.count
                self.viewModel.messageReadPublishSubject.onNext((_mid,false,_count))
            }
        }
        else if self._lastMessageId != nil, self.dataArray.count > 0 {
            let _arrTemp = self.dataArray.filter({ MessageDirection(rawValue: $0.renderMemberType ?? 0).isSend() == false && MessageReadStatus.init(rawValue: $0.mStatus ?? 0) != .read && ($0.mId ?? 0) > self._lastMessageId! })
            if _arrTemp.count >= 20,let _mid = _arrTemp.last?.mId {
                let _count = _arrTemp.count
                self.viewModel.messageReadPublishSubject.onNext((_mid,false,_count))
            }
        }
        //[E]
    }
    
    
    //MARK: 语音播放
    // 开始播放录音
    fileprivate func startPlaying(_ message:MessageModel) {
        if message.mType == MessageBodyType.voice.rawValue {
            
            stopPlaying()
            self.oldChatVoiceMessagemId = message.mId
            if let cell = getCellByMessage(message.mId) as? ChatVoiceCell {
                cell.messageAnimationVoiceImageView.startAnimating()
                
                //本地语音
                if let _path = message.messageBody?.voiceLocalPath,
                   let range = _path.range(of: "Caches") {
                    let path = NSHomeDirectory() + "/Library/" + _path.dropFirst(range.lowerBound.utf16Offset(in: _path))
                    
                    VoiceManager.shared.play(path, {[weak self] in
                        self?.stopPlaying()
                    })
                }
                //线上语音
                else if let _murl = message.messageBody?.mediaUrl,_murl.isEmpty == false {
                    let _path = TGSUIModel.getFileRealUrlFor(Path: _murl, andisThumbnail: false)
                    VoiceManager.shared.play(_path, {[weak self] in
                        self?.stopPlaying()
                    })
                }
            }
        }
    }
    
    // 停止播放录音
    fileprivate func stopPlaying() {
        
        if let oldMessageuuid = self.oldChatVoiceMessagemId {
            if let oldChatVoiceCell = getCellByMessage(oldMessageuuid) as? ChatVoiceCell {
                oldChatVoiceCell.messageAnimationVoiceImageView.stopAnimating()
                VoiceManager.shared.stopPlay()
            }
            self.oldChatVoiceMessagemId = nil
        }
        
    }
    
    // 根据message 获取 cell
    fileprivate func getCellByMessage(_ _mid:Int64?) -> BaseChatCell? {
        if let index = self.dataArray.firstIndex(where: { $0.mId == _mid }) {
            return tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? BaseChatCell
        }
        return nil
    }
}


// MARK: - UITableViewDelegate,UITableViewDataSource
extension BaseChatVC:UITableViewDelegate,UITableViewDataSource {
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:BaseChatCell!
        if self.dataArray.count > indexPath.row {
            let message = dataArray[indexPath.row]
            
            //中间
            if MessageDirection(rawValue: message.renderMemberType ?? 0).isMiddle() == true {
                cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatEventTextCell.rawValue) as! ChatEventTextCell
            }
            else{
                switch message.mType {
                    //MARK: 文本消息
                case MessageBodyType.text.rawValue:
                    //MARK: 赞踩
                    if (message.messageBody?.options?.count ?? 0) > 0 {
                        cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatLikeTextCell.rawValue) as! ChatLikeTextCell
                        
                        //更新列
                        (cell as? ChatLikeTextCell)?.cellUpdateBack = {[weak self] _indexPath in
                            guard let self = self else { return }
                            if _indexPath != nil,self.arrComment.contains(_indexPath!.row) == false {
                                self.arrComment.append(_indexPath!.row)
                                self.tableView.reloadRows(at: [_indexPath!], with: .none)
                            }
                        }
                        
                        //提交
                        (cell as? ChatLikeTextCell)?.submitCallback = {[weak self] (_ _mid:Int64,_ _isHelp:Bool,_ _content:String?,_index:Int?) in
                            guard let self = self else { return }
                            self.commentIndex = _index
                            self.viewModel.questionCommentSubmitPublishSubjct.onNext((false,_mid,_content,_isHelp))
                        }
                    }
                    //普通消息
                    else{
                        cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatTextCell.rawValue) as! ChatTextCell
                    }
                    break
                    
                    //MARK: 超链(有细分支)
                case MessageBodyType.link.rawValue:
                    // 链接描述(* 描述和图片Url都有的时候按照卡片渲染否则按超链文字渲染)
                    if message.messageBody?.link_description != nil && message.messageBody?.link_description?.isEmpty == false
                        && message.messageBody?.imageUrl != nil && message.messageBody?.imageUrl?.isEmpty == false {
                        //MARK: 商品卡片
                        cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatProductCell.rawValue) as! ChatProductCell
                        (cell as? ChatProductCell)?.clickCellBlock = { _link_url in
                            if _link_url != nil && _link_url?.isEmpty == false {
                                TGSUIModel.gotoWebViewFor(Path: _link_url)
                            }
                        }
                    }
                    else {
                        cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatLinkTableViewCell.rawValue) as! ChatLinkTableViewCell
                        (cell as? ChatLinkTableViewCell)?.viewModel = self.viewModel
                        (cell as? ChatLinkTableViewCell)?.cellLeaveMessageBlock = {[weak self] (_msgId,_sessionId) in
                            guard let self = self else { return }
                            if _msgId == nil || (_msgId ?? 0) <= 0 {
                                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "消息编号不存在")
                                return
                            }
                            self.leaveMessaheBoxView.sessionId = _sessionId ?? self.sessionId
                            self.leaveMessaheBoxView.messageId = _msgId
                            self.leaveMessagePopupController.show(in: UIApplication.shared.keyWindow?.rootViewController?.view ?? self.view, completion: nil)
                        }
                    }
                    break
                    
                    //MARK: 消息事件
                case MessageBodyType.event.rawValue:
                    //细分
                    if message.messageBody?.customMenus?.first?.command == MessageCardsBranchType.leaveWordReminder.rawValue {
                        cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatLinkTableViewCell.rawValue) as! ChatLinkTableViewCell
                        (cell as? ChatLinkTableViewCell)?.viewModel = self.viewModel
                        (cell as? ChatLinkTableViewCell)?.cellLeaveMessageBlock = {[weak self] (_msgId,_sessionId) in
                            guard let self = self else { return }
                            if _msgId == nil || (_msgId ?? 0) <= 0 {
                                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "消息编号不存在")
                                return
                            }
                            self.leaveMessaheBoxView.sessionId = _sessionId ?? self.sessionId
                            self.leaveMessaheBoxView.messageId = _msgId
                            self.leaveMessagePopupController.show(in: UIApplication.shared.keyWindow?.rootViewController?.view ?? self.view, completion: nil)
                        }
                    }
                    //欢迎语
                    else if MessageDirection(rawValue: message.renderMemberType ?? 0).isMiddle() == false {
                        cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatTextCell.rawValue) as! ChatTextCell
                    }
                    else{
                        cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatEventTextCell.rawValue) as! ChatEventTextCell
                    }
                    break
                    
                    //MARK: 图片消息
                case MessageBodyType.image.rawValue:
                    cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatImageCell.rawValue) as! ChatImageCell
                    break
                    
                    //MARK: 附件
                case MessageBodyType.annex.rawValue:
                    cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatAnnexCell.rawValue) as! ChatAnnexCell
                    
                    (cell as? ChatAnnexCell)?.clickCellBlock = {[weak self] (_path,_name) in
                        //本地文件
                        if let _p = _path,_p.isEmpty == false {
                            VXIDownLoadFileManager.share.previewFile(filePath: _p,
                                                                     andFileName: _name,
                                                                     withDelegate: self)
                        }
                        else{
                            VXIProgressHUD.showToastHUD(type: VXIProgressHUD.VXIHUDToastType.tipToastType,
                                                        showText: "附件地址不存在")
                        }
                    }
                    break
                    
                    //MARK: 视频
                case MessageBodyType.video.rawValue:
                    cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatVideoCell.rawValue) as! ChatVideoCell
                    
                    (cell as? ChatVideoCell)?.clickCellBlock = { (_localPath:String?,_videoPath:String?) in
                        if _localPath != nil && _localPath?.isEmpty ==  false {
                            let _url = NSURL.init(fileURLWithPath: _localPath!)
                            let vc = AVPlayerViewController.init()
                            vc.player = AVPlayer.init(url: _url as URL)
                            self.present(vc, animated: true)
                        }
                        else if _videoPath != nil && _videoPath?.isEmpty == false,
                                let _url = URL.init(string: _videoPath!.yl_urlEncoded()) {
                            let vc = AVPlayerViewController.init()
                            vc.player = AVPlayer.init(url: _url)
                            self.present(vc, animated: true)
                        }
                        else{
                            VXIProgressHUD.showToastHUD(type: VXIProgressHUD.VXIHUDToastType.tipToastType,
                                                        showText: "视频数据不存在")
                        }
                    }
                    break
                    
                    //MARK: 语音消息
                case MessageBodyType.voice.rawValue:
                    cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatVoiceCell.rawValue) as! ChatVoiceCell
                    break
                    
                    //MARK: 机器人问答消息
                case MessageBodyType.machineAnswer.rawValue:
                    //此处有细分(热点问题列表，分栏菜单)
                    if (message.messageBody?.question_group?.count ?? 0) > 1 {
                        //MARK: 机器人回答热点问tab列表
                        cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatMachineTabCell.rawValue) as! ChatMachineTabCell
                        (cell as? ChatMachineTabCell)?.clickCellBlock = {[weak self](tabIndex, tabTitle, cellIndex, cellStr,_item) in
                            guard let self = self else { return }
                            self.viewModel.questionClickPublishSubject.onNext((false,_item?.id ?? "",_item?.title ?? ""))
                        }
                        (cell as? ChatMachineTabCell)?.clickChangeNewBlock = {
                            VXIProgressHUD.showToastHUD(type: VXIProgressHUD.VXIHUDToastType.tipToastType,
                                                        showText: "点了换一批按钮")
                        }
                    }
                    else{
                        cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatMachineBaseCell.rawValue) as! ChatMachineBaseCell
                        (cell as? ChatMachineBaseCell)?.clickCellBlock = {[weak self] (_:Int,_item:MessageGroupItems) in
                            guard let self = self else { return }
                            self.viewModel.questionClickPublishSubject.onNext((false,_item.id ?? "",_item.title ?? ""))
                        }
                    }
                    break
                    
                    //MARK: 满意度(此处有细分类型)
                case MessageBodyType.evaluat.rawValue:
                    //消息气泡
                    if message.messageBody?.styleType == 2 {
                        cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatEvaluatCell.rawValue) as! ChatEvaluatCell
                        (cell as? ChatEvaluatCell)?.viewModel = self.viewModel
                    }
                    //文本
                    else {
                        cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatLinkTableViewCell.rawValue) as! ChatLinkTableViewCell
                        (cell as? ChatLinkTableViewCell)?.viewModel = self.viewModel
                        
                        (cell as? ChatLinkTableViewCell)?.cellEvaluateMessageBlock = {[weak self] (_styleType,_data,_stfTemplateId,_title,_pushType,_mid,_sid) in
                            guard let self = self else { return }
                            //1：浮沉窗口，2：消息气泡，3：自定义页面(已在里面处理不会到外面来)，4：回复数字评价
                            if _styleType != 3 {
                                self.evaluatePopupController.show(in: UIApplication.shared.keyWindow?.rootViewController?.view ?? self.view, completion: nil)
                                
                                if (self.sessionId == nil || self.sessionId?.isEmpty == true) && _sid != nil &&  _sid?.isEmpty == false {
                                    self.sessionId = _sid
                                }
                                self.evaluateBoxView.setValueFor(Data: _data,
                                                                 andSTFTemplateId: _stfTemplateId,
                                                                 withTitle: _title,
                                                                 andPushType: _pushType,
                                                                 andMessageid: _mid,
                                                                 andSessionid: _sid)
                            }
                        }
                    }
                    break
                    
                    //MARK: 卡片消息(有细分分支)
                case MessageBodyType.cards.rawValue:
                    //排队超时，系统发出的留言
                    if message.messageBody?.customItems?.first?.customMenus?.first?.command == MessageCardsBranchType.leaveWordReminder.rawValue {
                        cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatLinkTableViewCell.rawValue) as! ChatLinkTableViewCell
                        (cell as? ChatLinkTableViewCell)?.viewModel = self.viewModel
                        (cell as? ChatLinkTableViewCell)?.cellLeaveMessageBlock = {[weak self] (_msgId,_sessionId) in
                            guard let self = self else { return }
                            if _msgId == nil || (_msgId ?? 0) <= 0 {
                                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "消息编号不存在")
                                return
                            }
                            self.leaveMessaheBoxView.sessionId = _sessionId ?? self.sessionId
                            self.leaveMessaheBoxView.messageId = _msgId
                            self.leaveMessagePopupController.show(in: UIApplication.shared.keyWindow?.rootViewController?.view ?? self.view, completion: nil)
                        }
                    }
                    //留言成功展示
                    else if message.messageBody?.customItems?.first?.customCardName?.contains("留言") == true {
                        cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatTextCell.rawValue) as! ChatTextCell
                    }
                    //                //MARK: 订单
                    //                else if message.messageBody?.cardType == 1 {
                    //                    cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatOrdersCell.rawValue) as! ChatOrdersTableViewCell
                    //                    (cell as? ChatOrdersTableViewCell)?.clickCellBlock = { (_chirdIndex) in
                    //                        VXIProgressHUD.showToastHUD(type: VXIProgressHUD.VXIHUDToastType.tipToastType,
                    //                                                    showText: "订单被点击:\(_chirdIndex)")
                    //                    }
                    //                }
                    //MARK: 商品
                    else{
                        cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatCardMutableCell.rawValue) as! ChatCardMutableCell
                        (cell as? ChatCardMutableCell)?.cellParentDidBlock = { (m:MessageCustomMenus?,_cardLink:String?) in
                            if let _link = _cardLink,_link.isEmpty == false {
                                TGSUIModel.gotoWebViewFor(Path: _link)
                                return
                            }
                            
                            //1:打开Url 3: 内部处理，4：传递上层应用
                            switch m?.type {
                            case .some(1):
                                if let _link = _cardLink,_link.isEmpty == false {
                                    TGSUIModel.gotoWebViewFor(Path: _link)
                                }
                                break
                                
                            case .some(3):
                                //发起留言
                                if let _command = m?.command,_command == MessageCardsBranchType.leaveWordReminder.rawValue {
                                    VXIChatViewModel.sessionSatisfactionPushFor(isLoading: false) { (_isOK:Bool, _msg:String) in
                                        if _isOK == false {
                                            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
                                        }
                                    }
                                }
                                break
                                
                            default:
                                break
                            }
                        }
                    }
                    break
                    
                default:
                    break
                }
            }
            
            //加载气泡满意度回显数据
            if message.mType == MessageBodyType.evaluat.rawValue && message.messageBody?.styleType == 2 {
                self.viewModel.evaluatFeedbackDataPublishSubject.onNext((message.sessionId,message.mId,false))
            }
            
            //显示时间处理
            cell.updateTime(FormatTme: message.timeFormatInfo,
                            andLastmessageId: self._lastMessageId)
            
            // 检测语音是否结束
            if self.oldChatVoiceMessagemId == message.mId {
                (cell as? ChatVoiceCell)?.messageAnimationVoiceImageView.startAnimating()
            }
            
            if self.arrComment.contains(indexPath.row) && cell.isKind(of: ChatLikeTextCell.self) {
                cell.updateMessage(message, idx: indexPath, isSelect: true)
            }
            else{
                cell.updateMessage(message, idx: indexPath)
            }
        }
        
        if cell == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellIdentify.ChatEventTextCell.rawValue) as! ChatEventTextCell
        }
        
        cell.contentView.tag = indexPath.row
        cell.delegate = self
        return cell
    }
    
}


// MARK: - BaseChatCellDelegate
extension BaseChatVC:BaseChatCellDelegate {
    
    /// 消息撤回
    func epMessageRevoke(_ _messageId: Int64) {
        self.viewModel.messageRevokePublishSubject.onNext((_messageId,false))
    }
    
    /// 发送消息
    func epSendMessage(_ _type: Int, _ _cMid: String, _ _dicPanras: [String : Any]) {
        //发送
        self.viewModel.conversationSendPublishSubject.onNext((
            _type,                 //消息类型
            //消息编号(客户端的)
            VXIUIConfig.shareInstance.getClientMIdFor(Mid: _cMid),
            _dicPanras,            //消息对象
            false
        ))
    }
    
    /// 语音点击播放
    func epDidVoiceClick(_ message: MessageModel) {
        if self.oldChatVoiceMessagemId == message.mId {
            stopPlaying()
            return
        }
        
        startPlaying(message)
    }
    
    
    //MARK: 图片点击预览
    /// 图片预览
    /// - Parameters:
    ///   - aob: 图片的绝对地址或者UIImage对象
    ///   - fv: 点击开始预览的UIView
    ///   - tv: UIViewController.navigationController.view
    ///   - muuid: 消息唯一标识
    func epDidImageClick(FromView fv: UIView,
                         andToView tv: UIView,
                         andMessageUUId muuid: String?,
                         andMessagecmid cmid: String?,
                         andFinishBlock fb: ((YYPhotoBrowseView) -> Void)?) {
        
        var arrGroup = [YYPhotoGroupItem]()
        let imageDataArray = dataArray.filter { $0.mType == MessageBodyType.image.rawValue }
        
        //当前预览图片索引
        var ci:Int? = imageDataArray.firstIndex { $0.messageUUId ==  muuid }
        if ci == nil {
            ci = imageDataArray.firstIndex { $0.cMid == cmid }
        }
        
        for i in 0..<imageDataArray.count {
            let m = imageDataArray[i]
            let gitem:YYPhotoGroupItem = YYPhotoGroupItem.init()
            
            //网路图片预览原图
            if let _pth = m.messageBody?.mediaUrl, _pth.isEmpty == false {
                let _url = TGSUIModel.getFileRealUrlFor(Path: _pth, andisThumbnail: false)
                gitem.imgOrUrl = TGSUIModel.getFileRealUrlFor(Path: _pth, andisThumbnail: true)
                gitem.largeImageURL = URL.init(string:_url)
                if let _data = m.messageBody?.image, let _img = UIImage.init(data: _data)  {
                    gitem.thumbView = UIImageView.init(image: _img)
                }
                arrGroup.append(gitem)
            }
            //本地图片
            else if let data = m.messageBody?.image,let image = UIImage(data: data) {
                gitem.imgOrUrl = image
                gitem.thumbView = UIImageView.init(image: image)
                arrGroup.append(gitem)
            }
        }
        
        if arrGroup.count <= 0 {
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "没有可预览的图片")
            return
        }
        
        let groupView:YYPhotoBrowseView = YYPhotoBrowseView.init(groupItems: arrGroup)
        groupView.present(fromImageView: fv,
                          toContainer: tv,
                          animated: true,
                          completion: nil)
        groupView.setShowFirstViewFor(ci ?? 0)
        fb?(groupView)
    }
    
}

// MARK: - ChatViewDelegate
extension BaseChatVC:ChatViewDelegate {
    
    /// 发送文本消息
    func epSendMessageText(_ text: String) {
        
        let message = MessageModel()
        message.timestamp = TGSUIModel.localUnixTimeForInt() * 1000
        message.renderMemberType = MessageDirection.send.rawValue
        message.cMid = NSUUID().uuidString
        
        let messageBody = MessageBody()
        message.mType = MessageBodyType.text.rawValue
        messageBody.content = text
        
        message.messageBody = messageBody
        
        self.dataArray.append(message)
        self.saveRealmFor(Data: message)
        
        tableView.insertRows(at: [IndexPath.init(row: dataArray.count-1, section: 0)], with: UITableView.RowAnimation.bottom)
        
        efScrollToLastCell()
        
        //普通链接发送
        if let (_arrUrls,_txt) = text.yl_mateUrlFor(Rang: NSMakeRange(0, text.utf16.count)),_arrUrls.count > 0 {
            self.viewModel.conversationSendPublishSubject.onNext((
                //消息类型
                MessageBodyType.link.rawValue,
                //消息编号(客户端的)
                VXIUIConfig.shareInstance.getClientMIdFor(Mid: message.cMid),
                //消息对象
                [
                    "linkUrl":_arrUrls.first!,
                    "title":_txt,
                ],
                false
            ))
        }
        //文本消息发送
        else{
            self.viewModel.conversationSendPublishSubject.onNext((
                MessageBodyType.text.rawValue,//消息类型
                //消息编号(客户端的)
                VXIUIConfig.shareInstance.getClientMIdFor(Mid: message.cMid),
                [
                    "content":text
                ],                            //消息对象
                false
            ))
        }
    }
    
    /// 发送图片消息
    func epSendMessageImage(_ images:[UIImage]?,_ names:[String]?) {
        
        if let imgs = images,imgs.count > 0 {
            var indexPaths = Array<IndexPath>()
            var _i = 0
            for img in imgs {
                
                let message = MessageModel()
                message.timestamp = TGSUIModel.localUnixTimeForInt() * 1000
                message.renderMemberType = MessageDirection.send.rawValue
                message.cMid = NSUUID().uuidString
                
                let messageBody = MessageBody()
                message.mType = MessageBodyType.image.rawValue
                messageBody.image = img.jpegData(compressionQuality: VXIUIConfig.shareInstance.imageCompressionQuality())
                if (names?.count ?? 0) > _i {
                    messageBody.name = names![_i]
                }
                else{
                    messageBody.name = NSUUID().uuidString + ".jpg"
                }
                message.messageBody = messageBody
                
                self.dataArray.append(message)
                self.saveRealmFor(Data: message)
                
                indexPaths.append(IndexPath.init(row: dataArray.count-1, section: 0))
                _i += 1
            }
            
            tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.bottom)
            efScrollToLastCell()
        }
    }
    
    /// 发送自定义表情图片
    func epSendMessageFaceImage(_ _name: String, _ _mediaUrl: String) {
        let message = MessageModel()
        message.timestamp = TGSUIModel.localUnixTimeForInt() * 1000
        message.renderMemberType = MessageDirection.send.rawValue
        message.cMid = NSUUID().uuidString
        
        let messageBody = MessageBody()
        message.mType = MessageBodyType.image.rawValue
        messageBody.mediaUrl = _mediaUrl
        
        message.messageBody = messageBody
        
        self.dataArray.append(message)
        self.saveRealmFor(Data: message)
        
        tableView.insertRows(at: [IndexPath.init(row: dataArray.count-1, section: 0)], with: UITableView.RowAnimation.bottom)
        
        efScrollToLastCell()
        
        self.viewModel.conversationSendPublishSubject.onNext((
            MessageBodyType.image.rawValue,//消息类型
            //消息编号(客户端的)
            VXIUIConfig.shareInstance.getClientMIdFor(Mid: message.cMid),
            [
                "name":_name,
                "mediaUrl": _mediaUrl as Any,
            ],
            false
        ))
    }
    
    /// 发送语音
    func ePSendMessageVoice(_ path: String? ,_ _duration: Double) {
        if let path = path {
            
            let message = MessageModel()
            message.timestamp = TGSUIModel.localUnixTimeForInt() * 1000
            message.renderMemberType = MessageDirection.send.rawValue
            message.cMid = NSUUID().uuidString
            message.mType = MessageBodyType.voice.rawValue
            
            let messageBody = MessageBody()
            messageBody.voiceLocalPath = path
            messageBody.duration = _duration
            
            message.messageBody = messageBody
            
            self.dataArray.append(message)
            self.saveRealmFor(Data: message)
            
            tableView.insertRows(at: [IndexPath.init(row: dataArray.count-1, section: 0)],
                                 with: UITableView.RowAnimation.bottom)
            
            efScrollToLastCell()
        }
    }
    
    /// 发送附件消息
    func epSendMessageFile(_ _path:String?,_ _data: Data, _ _fileName: String, _ _fileSize: Double) {
        let message = MessageModel()
        message.timestamp = TGSUIModel.localUnixTimeForInt() * 1000
        message.renderMemberType = MessageDirection.send.rawValue
        message.cMid = NSUUID().uuidString
        
        let messageBody = MessageBody()
        message.mType = MessageBodyType.annex.rawValue
        messageBody.fileName = _fileName
        messageBody.annexLocalPath = _path?.yl_urlEncoded()
        messageBody.annexLocalData = _data
        messageBody.fileSize = _fileSize //KB为单位
        
        message.messageBody = messageBody
        
        self.dataArray.append(message)
        self.saveRealmFor(Data: message)
        
        tableView.insertRows(at: [IndexPath.init(row: dataArray.count-1, section: 0)], with: UITableView.RowAnimation.bottom)
        
        efScrollToLastCell()
    }
    
    /// 发送视频消息
    func epSendMessageVideo(_ _localPath: String, _ _videoName: String, _ _coverImage: UIImage, _ _duration: TimeInterval, _ _imgSize: CGSize) {
        
        let message = MessageModel()
        message.timestamp = TGSUIModel.localUnixTimeForInt() * 1000
        message.renderMemberType = MessageDirection.send.rawValue
        message.cMid = NSUUID().uuidString
        message.mType = MessageBodyType.video.rawValue
        
        let messageBody = MessageBody()
        messageBody.videoLocalPath = _localPath
        messageBody.width = Float(_imgSize.width)
        messageBody.height = Float(_imgSize.height)
        messageBody.videoCoverImage = _coverImage.jpegData(compressionQuality: VXIUIConfig.shareInstance.imageCompressionQuality())
        messageBody.duration = _duration
        message.messageBody = messageBody
        
        self.dataArray.append(message)
        self.saveRealmFor(Data: message)
        tableView.insertRows(at: [IndexPath.init(row: dataArray.count-1, section: 0)], with: UITableView.RowAnimation.bottom)
        
        efScrollToLastCell()
    }
    
    /// 统一事件消息(该类型主要用来接收，非客户端主动发送)
    func epSendMessageTextSystem(_ _text: String) {
        let message = MessageModel()
        message.timestamp = TGSUIModel.localUnixTimeForInt() * 1000
        message.renderMemberType = MessageDirection.send.rawValue
        message.cMid = NSUUID().uuidString
        
        let messageBody = MessageBody()
        message.mType = MessageBodyType.event.rawValue
        messageBody.content = _text
        message.messageBody = messageBody
        
        self.dataArray.append(message)
        self.saveRealmFor(Data: message)
        
        tableView.insertRows(at: [IndexPath.init(row: dataArray.count-1, section: 0)], with: UITableView.RowAnimation.bottom)
        
        efScrollToLastCell()
        
        self.viewModel.conversationSendPublishSubject.onNext((
            MessageBodyType.event.rawValue,//消息类型
            //消息编号(客户端的)
            VXIUIConfig.shareInstance.getClientMIdFor(Mid: message.cMid),
            [
                "content":_text
            ],                            //消息对象
            false
        ))
    }
    
    /// 评价消息
    func epSendMessageEvaluate() {
        //主动评价
        self.evaluatePopupController.show(in: UIApplication.shared.keyWindow?.rootViewController?.view ?? self.view, completion: nil)
        self.viewModel.evaluatLoadConfigPublishSubject.onNext((false,false))
    }
    
    /// 留言
    func epSendLeaveMessage() {
        self.leaveMessaheBoxView.sessionId = self.sessionId
        self.leaveMessaheBoxView.messageId = 0//底部快捷-发起留言 传0
        self.leaveMessagePopupController.show(in: UIApplication.shared.keyWindow?.rootViewController?.view ?? self.view, completion: nil)
        
        //加载留言配置
        self.viewModel.leaveMessageLoadConfigPublishSubject.onNext((false,true))
    }
    
    func epSendMessageEvaluate(_ _dic: [String : Any]?) {
        let message = MessageModel()
        message.timestamp = TGSUIModel.localUnixTimeForInt() * 1000
        message.renderMemberType = MessageDirection.send.rawValue
        message.cMid = NSUUID().uuidString
        message.mType = MessageBodyType.evaluat.rawValue
        
        let messageBody = MessageBody()
        message.messageBody = messageBody
        
        self.dataArray.append(message)
        self.saveRealmFor(Data: message)
        
        tableView.insertRows(at: [IndexPath.init(row: dataArray.count-1, section: 0)], with: UITableView.RowAnimation.bottom)
        
        efScrollToLastCell()
    }
    
    
    //MARK: private
    internal func setisShowFor(ArrData arr:inout [MessageModel]) {
        //排序(正常应该按 createTime 降序排序,即：最新(大)的时间在最底下)
        arr = arr.sorted { ($0.createTime ?? 0) <= ($1.createTime ?? 0) }
    }
    
    internal func saveRealmFor(Data m:MessageModel){
        //[S] 保存到数据库
        //let _conversation = Conversation.init()
        //_conversation.messages.append(m)
        //RealmManagers.shared.addSynModel(_conversation)
        //[E]
    }
}

// MARK: - UIScrollViewDelegate
extension BaseChatVC:UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        chatView.efPackUpInputView()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if (scrollView.contentOffset.y == -64){
            loadData()
        }
        
    }
    
}


//MARK: - UIDocumentInteractionControllerDelegate
extension BaseChatVC : UIDocumentInteractionControllerDelegate {
    
    public func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
        print("[BaseChatVC][willBeginSendingToApplication]")
    }
    
    public func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        print("[BaseChatVC][didEndSendingToApplication]")
    }
    
    public func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        print("[BaseChatVC][DidDismissOpenInMenu]")
    }
    
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
