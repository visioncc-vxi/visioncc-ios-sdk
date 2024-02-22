//
//  VXISocketManagerViewModel.swift
//  Tool
//
//  Created by apple on 2024/1/11.
//

import Foundation
import RxSwift
import Alamofire

protocol ViewModelProtocol {
    /** 初始化 */
    func initialize()
}

internal class BaseViewModel : NSObject,ViewModelProtocol {
    
    override init() {
        super.init()
        self.initialize()
    }
    
    func initialize() {
        
    }
    
    deinit {
        debugPrint("\(self.classForCoder) 已销毁")
    }
    
}


/// VXISocketManagerViewModel
class VXISocketManagerViewModel : BaseViewModel {
    
    /// 获取配置
    lazy var socketIOConfigPublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (isModel,xentry,isLoading) = _input as? (Bool,String,Bool) else { return }
            VXISocketManagerViewModel.getSocketIOConfigFor(XEntry: xentry,
                                                           andisModel: isModel,
                                                           andisLoading: isLoading,
                                                           withRACSubscriber: self.socketIOConfigPublishSubject)
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
    
    /// 用户授权
    lazy var accessAuthorizePublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_xentry,_tenantId,_entryName,_phone,_email,_isLoading) = _input as? (String,String,String?,String?,String?,Bool) else { return }
            self.getAccessAuthorizeFor(XEntry: _xentry,
                                       andTenantId: _tenantId,
                                       andEntryName: _entryName,
                                       andPhone: _phone,
                                       andEmail: _email,
                                       andLoading: _isLoading,
                                       withRACSubscriber: self.accessAuthorizePublishSubject)
            
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
    
    /// 关闭会话(关闭人工会话和取消排队调用，此时SocketIO 对象不销毁)
    lazy var closeStockIOPublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_xentry,_deviceId,_isLoading) = _input as? (String,String,Bool) else { return }
            self.closeStockIOFor(XEntry: _xentry,
                                 andDeviceId: _deviceId,
                                 andLoading: _isLoading,
                                 withRACSubscriber: self.closeStockIOPublishSubject)
            
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
    
    /// 创建会话
    lazy var enterSectionPublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_xentry,_deviceId,_isLoading,_sid) = _input as? (String,String,Bool,String?) else { return }
            self.sectionEnterFor(XEntry: _xentry,
                                 andDeviceId: _deviceId,
                                 andLoading: _isLoading,
                                 andSocketId: _sid,
                                 withRACSubscriber: self.enterSectionPublishSubject)
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
}


//MARK: -
extension VXISocketManagerViewModel {
    
    
    /// 获取配置(接口 7.1)
    /// - Parameters:
    ///   - _xentry: String
    ///   - _isModel: Bool true 返回Model,false 返回原始数据
    ///   - _subscriber: PublishSubject<((_dicTemp:[String:Any]?,_m:GlobalCgaModel?, _msg:String))>?
    static func getSocketIOConfigFor(XEntry _xentry:String,
                                     andisModel _isModel:Bool = true,
                                     andisLoading _loading:Bool = false,
                                     withRACSubscriber _subscriber:PublishSubject<Any>?,
                                     andFinishBlock:((Bool,Any?)->Void)? = nil){
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: _xentry)
        ]
        let _url = VXIUrlSetting.shareInstance.configGlobalCga()
        CMRequest.shareInstance().getRequestForServerData(strUrl: _url,
                                                          WithParameters: nil,
                                                          AndSuccessBack: { responseData in
            if _isModel {
                do{
                    let decode = JSONDecoder.init()
                    if responseData != nil, let _data = TGSUIModel.getJsonDataFor(Any: responseData!) {
                        let result = try decode.decode(GlobalCgaModel.self, from: _data)
                        _subscriber?.onNext((true,result,"请求数据成功"))
                        andFinishBlock?(true,result)
                    }
                    else{
                        andFinishBlock?(true,responseData)
                        _subscriber?.onNext((true,responseData as? [String:Any],"数据获取成功"))
                    }
                }
                catch(let _error){
                    debugPrint(_error)
                    andFinishBlock?(false,_error.localizedDescription)
                    _subscriber?.onNext((false,responseData as? [String:Any],_error.localizedDescription))
                }
            }
            else{
                _subscriber?.onNext((true,responseData as? [String:Any],"数据获取失败"))
                andFinishBlock?(false,"数据获取失败")
            }
        },
                                                          AndFailureBack: { responseString in
            _subscriber?.onNext((false,[String:Any](),responseString ?? "请求异常"))
            andFinishBlock?(false,responseString ?? "请求异常")
        },
                                                          WithisLoading: _loading,
                                                          AndRequestHeaders: _headers)
    }
    
    
    /// 用户授权(接口7.2)
    /// - Parameters:
    ///   - _xentry: String
    ///   - _tid: String Guest 编号
    ///   - _en: String? 昵称
    ///   - _p: String? 电话
    ///   - _email: String? 邮箱
    ///   - _subscriber: PublishSubject<((_guestId:String?, _msg:String))>?
    private func getAccessAuthorizeFor(XEntry _xentry:String,
                                       andTenantId _tid:String,
                                       andEntryName _en:String?,
                                       andPhone _p:String?,
                                       andEmail _email:String?,
                                       andLoading _loading:Bool = false,
                                       withRACSubscriber _subscriber:PublishSubject<Any>?){
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name:"Accept", value: "application/json"),
            HTTPHeader.init(name:"Content-Type", value: "application/json;charset=UTF-8"),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: _xentry),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: "\(_tid)")
        ]
        
        var dicParams:[String:Any] = [
            "identity_id":_tid,
            "device_id":TGSUIModel.getDeviceUUID()
        ]
        
        if _en != nil && _en?.isEmpty == false {
            dicParams["visitor_name"] = _en!
        }
        
        if _p != nil && _p?.isEmpty == false {
            dicParams["phone"] = _p!
        }
        
        if _email != nil && _email?.isEmpty == false {
            dicParams["email"] = _email!
        }
        
        let _url = VXIUrlSetting.shareInstance.accessAuthorize()
        CMRequest.shareInstance().postRequestWithBodyFor(strUrl: _url,
                                                         WithBody: TGSUIModel.getJsonDataFor(Any: dicParams),
                                                         AndRequestHeaders: _headers,
                                                         AndSuccessBack: { responseData in
            if let _gid = responseData as? String,_gid.replacingOccurrences(of: " ", with: "").count > 0 {
                _subscriber?.onNext((_gid,"请求成功"))
            }
            else{
                _subscriber?.onNext(("","数据不存在"))
            }
        },
                                                         AndFailureBack: { responseString in
            _subscriber?.onNext(("",responseString ?? "请求失败"))
        },
                                                         WithisLoading: _loading)
    }
    
    
    /// 关闭会话
    /// - Parameters:
    ///   - _xentry: String
    ///   - _tid: Int
    ///   - _loading: Bool
    ///   - _subscriber: PublishSubject<((Bool, Any?))>?
    private func closeStockIOFor(XEntry _xentry:String,
                                 andDeviceId _did:String,
                                 andLoading _loading:Bool = false,
                                 withRACSubscriber _subscriber:PublishSubject<Any>?){
        
        let _url = VXIUrlSetting.shareInstance.cloaseStockIo()
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name:"Accept", value: "application/json"),
            HTTPHeader.init(name:"Content-Type", value: "application/json; charset=utf-8"),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: _xentry),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: _did)
        ]
        
        let _dicParams = [
            "ipAddress": "127.0.0.1"
        ]
        
        CMRequest.shareInstance().deleteRequestForServerData(strUrl: _url,
                                                             WithBody: _dicParams,
                                                             AndSuccessBack: { responseData in
            debugPrint("closeStockIOFor-\(responseData ?? "--")")
            var _ok:Bool? = responseData as? Bool
            if _ok == nil && (responseData as? String)?.uppercased() == "TRUE" {
                _ok = true
            }
            if _ok == true {
                _subscriber?.onNext((true,"关闭会话成功"))
            }
            else{
                _subscriber?.onNext((false,"关闭会话失败"))
            }
        }, AndFailureBack: { responseString in
            debugPrint("closeStockIOFor-\(responseString ?? "--")")
            _subscriber?.onNext((false,responseString))
        },WithisLoading: _loading,
                                                             AndRequestHeaders: _headers)
    }
    
    
    /// 创建接待会话/进入聊天
    /// - Parameters:
    ///   - _xentry: String
    ///   - _did: String
    ///   - _loading: Bool
    ///   - _sid: String?
    ///   - _subscriber: <#_subscriber description#>
    private func sectionEnterFor(XEntry _xentry:String,
                                 andDeviceId _did:String,
                                 andLoading _loading:Bool = false,
                                 andSocketId _sid:String? = nil,
                                 withRACSubscriber _subscriber:PublishSubject<Any>?){
        
        let _url = VXIUrlSetting.shareInstance.sectionEnter()
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name:"Accept", value: "application/json"),
            HTTPHeader.init(name:"Content-Type", value: "application/json; charset=utf-8"),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: _xentry),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: _did)
        ]
        
        let dicParams:[String:Any] = [
            "socketId": _sid ?? _xentry,
        ]
        
        CMRequest.shareInstance().postRequestWithBodyFor(strUrl: _url,
                                                         WithBody: TGSUIModel.getJsonDataFor(Any: dicParams),
                                                         AndRequestHeaders: _headers,
                                                         AndSuccessBack: { responseData in
            _subscriber?.onNext((true,"创建成功"))
        },
                                                         AndFailureBack: { responseString in
            _subscriber?.onNext((false,"",responseString ?? "请求失败"))
        },
                                                         WithisLoading: _loading)
    }
    
}
