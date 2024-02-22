//
//  VXIWebSocketManager.swift
//  Tool
//
//  Created by CQP-MacPro on 2023/12/19.
//

import UIKit
import SocketIO
import RxSwift
import Alamofire

//MARK: - 接收消息
/// 接收的消息类型
enum SocketReceiveEvent: String,CaseIterable {
    /// 新消息事件
    case message
    /// 会话状态变更
    case updateGuestSessionStatus
    /// 消息内容变更通知事件
    case updateMessage
    /// 全局配置更新事件
    case globalConfigUpdate
    /// 消息预览配置更新事件
    case switchSessionPreview
    /// 阅读回执事件
    case msgReadReceipt
    /// 消息撤回事件
    case msgRevoked
    /// 坐席输入状态事件
    case typing
    /// 满意度事件
    case pushSatisfaction
    /// 排队消息
    case guestQueuePrompt
}

//MARK: - 发送消息
/// 发送消息
enum SocketSendEvent: String,CaseIterable {
    /// 客户输入状态事件
    case typing
}


//MARK: 委托
/// 消息委托
protocol VXISocketManagerMessageDelegate {
    
    /// 接收Socket消息
    /// - Parameters:
    ///   - _ce: SocketReceiveEvent 消息类型
    ///   - _msg: Any? 消息数据
    func socketReceiveMessageFor(Event _ce:SocketReceiveEvent?,andMessageInfo _msg:[Any]?)
    
}

/// 连接状态委托
protocol VXISocketManagerConnectDelegate {
    
    /// 连接状态通知
    /// - Parameters:
    ///   - _ce: SocketClientEvent? 客户端事件状态
    ///   - _ss: SocketIOStatus? 连接状态
    func socketConnectChangeFor(ClientEvent _ce:SocketClientEvent?,andSocketIOStatus _ss:SocketIOStatus?)
}


//MARK: - Sockit.Io 对象
final class VXISocketManager: NSObject {
    
    static let share = VXISocketManager()
    
    //MARK: - override
    private override init() {
        super.init()
        self.bindViewModel()
    }
    
    
    //MARK: bindViewModel
    /// bindViewModel
    private func bindViewModel(){
        
        /// 获取系统配置结果
        self.viewModel.socketIOConfigPublishSubject.subscribe {[weak self] (_input:Event<Any>) in
            guard let self = self else { return }
            guard let (_isOK,_any,_msg) = _input.element as? (Bool,Any?,String) else { return }
            
            if _isOK {
                //用户授权
                if _any != nil,
                   let _data = TGSUIModel.getJsonDataFor(Any: _any!),
                   let tenantId = ((_any as? [String:Any])?["guest"] as? [String:Any])?["tenantId"] as? Int {
                    self.viewModel.accessAuthorizePublishSubject.onNext((
                        self.xentry ?? "",
                        (self.uMolde?.identity_id == nil || self.uMolde?.identity_id?.isEmpty == true) ? "\(tenantId)" : self.uMolde!.identity_id,
                        self.uMolde?.visitor_name ?? "",//entryName?
                        self.uMolde?.phone ?? "",//phone?
                        self.uMolde?.email ?? "",//email?
                        false
                    ))
                    
                    //保存配置数据
                    String.writeLocalCacheData(data: _data,
                                               key: VXIUIConfig.shareInstance.getGlobalCgaKey(),
                                               andOtherData: _any as? [String:Any])
                }
                //[E]
            }
            else{
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
            }
        }.disposed(by: rx.disposeBag)
        
        /// 获取用户授权结果
        self.viewModel.accessAuthorizePublishSubject.subscribe {[weak self] (_input:Event<Any>) in
            guard let self = self else { return }
            guard let (_guestId, _msg) = _input.element as? (String?, String) else { return }
            
            if let gid = _guestId?.replacingOccurrences(of: "\"", with: ""),gid.isEmpty == false {
                self.deviceId = gid
                debugPrint("accessAuthorizePublishSubject-deviceId:\(self.deviceId ?? "--")")
                
                //发送进线消息
                if self.callBack != nil {
                    self.callBack?()
                    self.callBack = nil
                }
                
                self.socketManager = self.createSocketIOManager()
                self.socketIOListenInfo()
                
                self.socketIOClient?.connect(withPayload: [
                    "deviceType":self.xentry ?? "",
                    "deviceId":gid
                ])
            }
            else{
                self.deviceId = nil
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
            }
        }.disposed(by: rx.disposeBag)
        
        /// 关闭会话(并不是关闭 SocketIO)
        self.viewModel.closeStockIOPublishSubject.subscribe { (_input:Event<Any>) in
            guard let (_isOk,_any) = _input.element as? (Bool,Any) else { return }
            if _isOk == false {
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _any as? String ?? "会话关闭异常")
            }
            
            NotificationCenter.default.post(name: VXIUIConfig.shareInstance.getCloseSectionKey(),
                                            object: nil,
                                            userInfo: [
                                                "isClosed" : _isOk,
                                                "messaeg":_any as? String ?? "会话关闭异常"
                                            ])
        }.disposed(by: rx.disposeBag)
        
    }
    
    
    //MARK: lazy load
    /// VXISocketManagerViewModel
    private(set) lazy var viewModel:VXISocketManagerViewModel = {
        return VXISocketManagerViewModel.init()
    }()
    
    /// SocketManager?
    public private(set) lazy var socketManager:SocketManager? = nil
    
    /// SocketIOClient?
    public var socketIOClient:SocketIOClient? {
        get{
            return self.socketManager?.defaultSocket
        }
    }
    
    /// 入口编号
    public private(set) lazy var xentry:String? = nil
    
    /// 访客Id
    public private(set) lazy var deviceId:String? = nil
    
    public lazy var appKey:String? = nil
    public lazy var uMolde:UserMappingModel? = nil
    
    /// SocketIO消息委托
    private var socketMessageDelegate:VXISocketManagerMessageDelegate?
    
    /// 连接状态委托
    private var socketManagerConnectDelegate:VXISocketManagerConnectDelegate?
    
    /// 进线发送消息回调
    internal lazy var callBack:(()->Void)? = nil
}


//MARK: -
extension VXISocketManager{
    
    /// 发起重连
    func cliectReconnect(){
        self.socketIOClient?.setReconnecting(reason: "手动重连中...")
    }
    
    //MARK: 开启SocketIO
    /// 开启
    func startSocketIOFor(XEntry _xentry:String?,
                          andConnectDelegate _cd:VXISocketManagerConnectDelegate? = nil,
                          withMessageDelegate _md:VXISocketManagerMessageDelegate? = nil){
        if _xentry == nil || _xentry?.replacingOccurrences(of: " ", with: "").isEmpty == true {
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "XEntry 信息不存在")
            return
        }
        
        self.socketMessageDelegate = _md
        self.socketManagerConnectDelegate = _cd
        
        self.xentry = _xentry
        self.viewModel.socketIOConfigPublishSubject.onNext((false,self.xentry ?? "",false))
        
        //发送快捷语通知更新
        NotificationCenter.default.post(name: VXIUIConfig.shareInstance.getInputQuickReplyHandleKey(),
                                        object: nil,
                                        userInfo: ["isShow" : true])
    }
    
    
    /// 进入会话
    /// - Parameters:
    ///   - _eid: EntryId String
    ///   - _did: DeviceId String
    ///   - _sid: String?
    func enterSectionBy(EntryId _eid:String,
                        andDeviceId _did:String,
                        withSocketId _sid:String?,
                        andViewController _vc:UIViewController? = nil){
        if self.socketMessageDelegate == nil && _vc != nil {
            self.socketMessageDelegate = _vc as? any VXISocketManagerMessageDelegate
        }
        
        if self.socketManagerConnectDelegate == nil && _vc != nil {
            self.socketManagerConnectDelegate = _vc as? any VXISocketManagerConnectDelegate
        }
        
        self.viewModel.enterSectionPublishSubject.onNext((_eid,_did,false,_sid))
    }
    
    //MARK: 监听消息
    /// 监听信息
    private func socketIOListenInfo(){
        self.socketIOClient?.on(clientEvent: .connect, callback: { (data:[Any], ack:SocketAckEmitter) in
            debugPrint("Socket.IO:开启[connect] => {data:\(data),ack:\(ack)}")
            
            var _ss:SocketIOStatus?
            if let _sst = data.first as? SocketIOStatus {
                _ss = _sst
            }
            self.socketManagerConnectDelegate?.socketConnectChangeFor(ClientEvent: .connect, andSocketIOStatus: _ss)
            
            //进入会话
            let _sid:String? = (data.last as? [String:Any])?["sid"] as? String
            self.enterSectionBy(EntryId: self.xentry ?? "",
                                andDeviceId: self.deviceId ?? "",
                                withSocketId: _sid)
        })
        
        self.socketIOClient?.on(clientEvent: .disconnect, callback: { (data:[Any], ack:SocketAckEmitter) in
            debugPrint("Socket.IO:关闭[disconnect] => {data:\(data),ack:\(ack)}")
            var _ss:SocketIOStatus?
            if let _sst = data.first as? SocketIOStatus {
                _ss = _sst
            }
            self.socketManagerConnectDelegate?.socketConnectChangeFor(ClientEvent: .disconnect, andSocketIOStatus: _ss)
        })
        
        self.socketIOClient?.on(clientEvent: .error, callback: { (data:[Any], ack:SocketAckEmitter) in
            debugPrint("Socket.IO:异常[error] => {data:\(data),ack:\(ack.debugDescription)}")
            
            var _ss:SocketIOStatus?
            if let _sst = data.first as? SocketIOStatus {
                _ss = _sst
            }
            self.socketManagerConnectDelegate?.socketConnectChangeFor(ClientEvent: .error, andSocketIOStatus: _ss)
        })
        
        self.socketIOClient?.on(clientEvent: .ping, callback: { (data:[Any], ack:SocketAckEmitter) in
            debugPrint("Socket.IO:心跳包[ping] => {data:\(data),ack:\(ack)}")
        })
        
        self.socketIOClient?.on(clientEvent: .pong, callback: { (data:[Any], ack:SocketAckEmitter) in
            debugPrint("Socket.IO:心跳包[pong] => {data:\(data),ack:\(ack)}")
        })
        
        self.socketIOClient?.on(clientEvent: .reconnect, callback: { (data:[Any], ack:SocketAckEmitter) in
            debugPrint("Socket.IO:开始重连[reconnect] => {data:\(data),ack:\(ack)}")
            var _ss:SocketIOStatus?
            if let _sst = data.first as? SocketIOStatus {
                _ss = _sst
            }
            self.socketManagerConnectDelegate?.socketConnectChangeFor(ClientEvent: .reconnect, andSocketIOStatus: _ss)
        })
        
        self.socketIOClient?.on(clientEvent: .reconnectAttempt, callback: { (data:[Any], ack:SocketAckEmitter) in
            debugPrint("Socket.IO:尝试重连[reconnectAttempt] => {data:\(data),ack:\(ack)}")
            var _ss:SocketIOStatus?
            if let _sst = data.first as? SocketIOStatus {
                _ss = _sst
            }
            self.socketManagerConnectDelegate?.socketConnectChangeFor(ClientEvent: .reconnectAttempt, andSocketIOStatus: _ss)
        })
        
        self.socketIOClient?.on(clientEvent: .statusChange, callback: { (data:[Any], ack:SocketAckEmitter) in
            debugPrint("Socket.IO:状态改变[statusChange] => {data:\(data),ack:\(ack)}")
            
            var _ss:SocketIOStatus?
            if let _sst = data.first as? SocketIOStatus {
                _ss = _sst
            }
            self.socketManagerConnectDelegate?.socketConnectChangeFor(ClientEvent: .statusChange, andSocketIOStatus: _ss)
        })
        
        self.socketIOClient?.on(clientEvent: .websocketUpgrade, callback: { (data:[Any], ack:SocketAckEmitter) in
            debugPrint("Socket.IO:将http连接升级为websocket连接[websocketUpgrade] => {data:\(data),ack:\(ack)}")
            var _ss:SocketIOStatus?
            if let _sst = data.first as? SocketIOStatus {
                _ss = _sst
            }
            self.socketManagerConnectDelegate?.socketConnectChangeFor(ClientEvent: .reconnectAttempt, andSocketIOStatus: _ss)
        })
        
        //MARK: 消息处理
        for _event_msg in SocketReceiveEvent.allCases {
            self.socketIOClient?.on(_event_msg.rawValue, callback: { (data:[Any], ack:SocketAckEmitter) in
                print("Socket.IO:消息事件[\(_event_msg.rawValue)] => {data:\(data),ack:\(ack)}")
                self.socketMessageDelegate?.socketReceiveMessageFor(Event: _event_msg, andMessageInfo: data)
            })
        }
        
    }
    
    //MARK: 关闭会话
    /// 关闭SocketIo会话
    /// - Parameter _in: true 返回关闭(SocketIO 对象关闭) false(关闭人工会话和取消排队调用，此时SocketIO 对象不销毁)
    func stopSocketIO(isNavgationback _in:Bool){
        //关闭SocketIO 对象
        if _in == true {
            self.socketIOClient?.didDisconnect(reason: "用户手动关闭退出会话")
            self.socketManager?.didDisconnect(reason: "用户手动关闭退出会话")
            self.socketManager = nil
            
            self.socketMessageDelegate = nil
            self.socketManagerConnectDelegate = nil
        }
        //关闭人工会话和取消排队调用，此时SocketIO 对象不销毁
        else {
            self.viewModel.closeStockIOPublishSubject.onNext((self.xentry ?? "",self.deviceId ?? "",false))
        }
    }
    
    
    //MARK: 创建SockitIO 对象
    /// 创建SockitIO 对象
    /// - Parameter _did: Stirng (授权返回的字符信息 参见文档：7.2)
    /// - Returns: SocketManager?
    private func createSocketIOManager() -> SocketManager? {
        var socketManager:SocketManager?
        if let _url:URL = URL.init(string: VXIUrlSetting.shareInstance.getSocketIOHost()) {
            socketManager = SocketManager.init(socketURL: _url,
                                               config: [
                                                .log(true),
                                                .compress,
                                                .path(VXIUrlSetting.shareInstance.getSocketIOPath()),
                                                .reconnects(true),         //自动重连
                                                .reconnectWait(1),         //尝试重连前等待的最小秒数
                                                .reconnectWaitMax(Int(VXIUIConfig.shareInstance.appRequestTimeOut())),//尝试重连前等待的最大秒数
                                                .reconnectAttempts(-1),    //一直重连(never give up)
                                                .forceWebsockets(true),    //指定传输协议
                                                .secure(true),             //安全传输
                                                .enableSOCKSProxy(true),
                                                .version(.three),
                                               ])
        }
        return socketManager
    }
    
}
