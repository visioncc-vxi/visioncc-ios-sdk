//
//  VXIChatViewModel.swift
//  Tool
//
//  Created by apple on 2024/1/12.
//

import UIKit
import RxSwift
import Alamofire
import RealmSwift
@_implementationOnly import VisionCCiOSSDKEngine


/// 会话ViewModel
final class VXIChatViewModel: BaseViewModel {
    
    /// 转人工
    lazy var convertArtificialPublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_skillId,isLoading) = _input as? (Int,Bool) else { return }
            self.convertArtificialFor(SkillId: _skillId,
                                      andisLoading: isLoading,
                                      withPublishSubject: self.convertArtificialPublishSubject)
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
    
    
    /// 发送消息
    lazy var conversationSendPublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_type,_mcid,_mBody,_isLoading) = _input as? (Int,String,[String:Any],Bool) else { return }
            VXIChatViewModel.conversationSendFor(Type: _type,
                                                 andClientMessageId: _mcid,
                                                 andBody: _mBody,
                                                 andisLoading: _isLoading,
                                                 withPublishSubject: self.conversationSendPublishSubject)
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
    
    //MARK: 历史数据加载
    /// 历史数据加载
    lazy var loadConversationHistoryPublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_direction,_mid,_isLoading) = _input as? (String,Int64,Bool) else { return }
            self.loadConversationHistoryFor(Direction: _direction,
                                            andMessageId: _mid  > 0 ? _mid : nil,
                                            andLoading: _isLoading,
                                            andPublishSubject: self.loadConversationHistoryPublishSubject)
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
    
    //MARK: 未读消息
    /// 未读消息设置为已读
    lazy var messageReadPublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_lid,_isLoading,_count) = _input as? (Int64,Bool,Int) else { return }
            self.messageReadFor(LastMessageId: _lid,
                                andLoading: _isLoading,
                                andUnreadCount: _count,
                                andPublishSubject: self.messageReadPublishSubject)
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
    
    
    //MARK: 消息撤回
    /// 消息撤回
    lazy var messageRevokePublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_mid,_isLoading) = _input as? (Int64,Bool) else { return }
            self.messageRevokeFor(MessageId: _mid,
                                  andLoading: _isLoading,
                                  andPublishSubject: self.messageRevokePublishSubject)
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
    
    
    //MARK: 满意度
    /// 查询默认满意度配置
    lazy var evaluatLoadConfigPublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_isLoading,_isSave) = _input as? (Bool,Bool) else { return }
            self.evaluatLoadConfigFor(PublishSubject: self.evaluatLoadConfigPublishSubject,
                                      andisLoading: _isLoading,
                                      andNeedSavaLoacl: _isSave)
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
    
    /// 提交满意度
    lazy var evaluatSubmitPublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_isLoading,_sid,_pt,_main,_options,_mid) = _input as? (Bool,String,Int,[String:Any],[String:Any],Int64) else { return }
            self.evaluatFadebackFor(SessionId: _sid,
                                    andPushType: _pt,
                                    withMainata: _main,
                                    withOptions: _options,
                                    andPublishSubject: self.evaluatSubmitPublishSubject,
                                    adisLoading: _isLoading,
                                    andMessageId: _mid)
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
    
    /// 修改满意度评价
    lazy var evaluatupUpdatePublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_satisfactionId_,_isLoading,_sid,_pt,_main,_options,_mid) = _input as? (Int64,Bool,String,Int,[String:Any],[String:Any],Int64) else { return }
            self.evaluatUpdateFadebackBy(SatisfactionId: _satisfactionId_,
                                         andSessionId: _sid,
                                         andPushType: _pt,
                                         withMainata: _main,
                                         withOptions: _options,
                                         andPublishSubject: self.evaluatupUpdatePublishSubject,
                                         adisLoading: _isLoading,
                                         andMessageId: _mid)
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
    
    /// 获取满意度回显数据
    lazy var evaluatFeedbackDataPublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_sid,_mid,_isLoading) = _input as? (String,Int64,Bool) else { return }
            self.evaluatGetFeedbackDataBy(SessionId: _sid,
                                          andLoading: _isLoading,
                                          andMessageId: _mid,
                                          andPublishSubject: self.evaluatFeedbackDataPublishSubject)
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
    
    
    //MARK: 留言配置
    /// 查询默认留言配置
    lazy var leaveMessageLoadConfigPublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_isLoading,_isSave) = _input as? (Bool,Bool) else { return }
            self.leaveMessageLoadConfigFor(PublishSubject: self.leaveMessageLoadConfigPublishSubject,
                                           andisLoading: _isLoading,
                                           andNeedSavaLoacl: _isSave)
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
    
    
    /// 提交留言
    lazy var leaveMessageSubmitPublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_isLoading,_sid,_tid,_mid,_content,_options) = _input as? (Bool,String,Int64,Int64,[String:Any],[String:Any]?) else { return }
            self.leaveMessageSubmitFor(SessionId: _sid,
                                       andTemplateId: _tid,
                                       andMessageId: _mid,
                                       withContent: _content,
                                       withAttachments: _options,
                                       andPublishSubject: self.leaveMessageSubmitPublishSubject,
                                       andisLoading: _isLoading)
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
    
    //MARK: 问题点击
    /// 问题点击
    lazy var questionClickPublishSubject:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_isLoading,_qid,_qt) = _input as? (Bool,String,String) else { return }
            self.questionClickBy(QuestionId: _qid,
                                 andQuestionTitle: _qt,
                                 andPublishSubject: self.questionClickPublishSubject,
                                 andisLoading: _isLoading)
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
    
    /// 有/无帮助提交
    lazy var questionCommentSubmitPublishSubjct:PublishSubject<Any> = {[unowned self] in
        let _ps = PublishSubject<Any>()
        _ps.subscribe(onNext: {[weak self] _input in
            guard let self = self else { return }
            guard let (_isLoading,_mid,_c,_ishelp) = _input as? (Bool,Int64,String,Bool) else { return }
            self.questionCommentSubmit(MessageId: _mid,
                                       andOptionHelop: _ishelp,
                                       andLoading: _isLoading,
                                       andContent: _c.isEmpty ? nil : _c,
                                       andPublishSubject: self.questionCommentSubmitPublishSubjct)
        },
                      onError: nil,
                      onCompleted: nil,
                      onDisposed: nil)
        .disposed(by: rx.disposeBag)
        
        return _ps
    }()
}


//MARK: -
extension VXIChatViewModel {
    
    
    /// 转人工
    /// - Parameters:
    ///   - _sid: Int 技能Id，传0就是走的入口技能
    ///   - _isloading: <#_isloading description#>
    ///   - _subject: <#_subject description#>
    private func convertArtificialFor(SkillId _sid:Int,
                                      andisLoading _isloading:Bool,
                                      withPublishSubject _subject:PublishSubject<Any>?) {
        let _strUrl = VXIUrlSetting.shareInstance.convertArtificial() + "\(_sid)"
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name:"Accept", value: "application/json"),
            HTTPHeader.init(name:"Content-Type", value: "application/json;charset=UTF-8"),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: VXISocketManager.share.xentry ?? ""),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: VXISocketManager.share.deviceId ?? "")
        ]
        
        let _dicParams = [
            "ipAddress": "127.0.0.1"
        ]
        
        CMRequest.shareInstance().postRequestWithBodyFor(strUrl: _strUrl,
                                                         WithBody: TGSUIModel.getJsonDataFor(Any: _dicParams),
                                                         AndRequestHeaders: _headers,
                                                         AndSuccessBack: { responseData in
            _subject?.onNext((true,"排队请求成功"))
            debugPrint("convertArtificialFor-成功！详见：\(responseData ?? "--")")
        },
                                                         AndFailureBack: { responseString in
            debugPrint("convertArtificialFor-异常！详见：\(responseString ?? "--")")
            _subject?.onNext((false,responseString ?? "排队请求失败"))
        },
                                                         WithisLoading: _isloading)
    }
    
    
    /// 发送消息
    /// - Parameters:
    ///   - _mType: MessageBodyType(消息类型：1-文本、2-图片、3-语音、4-短视频、5-文件、6-链接...)
    ///   - _cMId: String 客户端生成的随机消息编号
    ///   - _mbody: [String:Any] 消息内容，用json对象键值对表示(具体参考：聊天消息格式新版.pdf)
    ///   - _isloading: Bool true 加载动画
    ///   - _subject: PublishSubject<Any>?
    static func conversationSendFor(Type _mType:Int,
                                    andClientMessageId _cMId:String,
                                    andBody _mbody:[String:Any],
                                    andisLoading _isloading:Bool,
                                    withPublishSubject _subject:PublishSubject<Any>?,
                                    andFinishBlock:((Bool,String)->Void)? = nil) {
        let _strUrl = VXIUrlSetting.shareInstance.conversationSend()
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name:"Accept", value: "application/json"),
            HTTPHeader.init(name:"Content-Type", value: "application/json;charset=UTF-8"),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: VXISocketManager.share.xentry ?? ""),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: VXISocketManager.share.deviceId ?? "")
        ]
        
        let _dicParams:[String:Any] = [
            "mBody":_mbody,           //消息内容，用json对象键值对表示
            "mType":_mType,           //消息类型：1-文本、2-图片、3-语音、4-短视频、5-文件、6-链接...
            "cMId":_cMId,             //客户端消息Id
        ]
        
        CMRequest.shareInstance().postRequestWithBodyFor(strUrl: _strUrl,
                                                         WithBody: TGSUIModel.getJsonDataFor(Any: _dicParams),
                                                         AndRequestHeaders: _headers,
                                                         AndSuccessBack: { responseData in
            debugPrint("conversationSendFor-消息发送成功:\(responseData ?? "--")")
            _subject?.onNext((true,"消息发送成功",responseData as? [String:Any]))
            andFinishBlock?(true,"消息发送成功")
        },
                                                         AndFailureBack: { responseString in
            debugPrint("conversationSendFor-消息发送异常！详见：\(responseString ?? "--")")
            _subject?.onNext((false,responseString ?? "消息发送失败",[String:Any].self))
            andFinishBlock?(false,responseString ?? "消息发送失败")
        },
                                                         WithisLoading: _isloading)
    }
    
    
    //MARK: - 满意度
    /// 查询默认满意度设置
    /// - Parameters:
    ///   - _subject: PublishSubject<Any>?
    ///   - _isloading: true 加载动画
    ///   - _save: true 需要保存本地
    private func evaluatLoadConfigFor(PublishSubject _subject:PublishSubject<Any>?,
                                      andisLoading _isloading:Bool,
                                      andNeedSavaLoacl _save:Bool) {
        let _strUrl = VXIUrlSetting.shareInstance.evaluatDefaultConfig()
        CMRequest.shareInstance().getRequestForServerData(strUrl: _strUrl,
                                                          WithParameters: nil,
                                                          AndSuccessBack: { responseData in
            debugPrint("evaluatLoadConfigFor-请求成功详见：\(responseData ?? "--")")
            if responseData != nil {
                if let _data = TGSUIModel.getJsonDataFor(Any: responseData!) {
                    do{
                        let result = try JSONDecoder.init().decode(EvaluatModel.self, from: _data)
                        _subject?.onNext((true,result,"请求成功"))
                        
                        if _save {
                            String.writeLocalCacheData(data: _data, key: VXIUIConfig.shareInstance.getEvaluatDefaultKey())
                        }
                    }
                    catch(let _error){
                        _subject?.onNext((false,EvaluatModel.self,_error.localizedDescription))
                        debugPrint("evaluatLoadConfigFor-保存数据异常！详见：\(_error)")
                    }
                }
                else{
                    _subject?.onNext((false,EvaluatModel.self,"数据转换失败"))
                }
            }
            else{
                _subject?.onNext((false,EvaluatModel.self,"默认满意度设置数据不存在"))
            }
        },
                                                          AndFailureBack: { responseString in
            debugPrint("evaluatLoadConfigFor-请求异常详见：\(responseString ?? "--")")
            _subject?.onNext((false,EvaluatModel.self,responseString ?? "默认满意度设置加载异常"))
        },
                                                          WithisLoading: _isloading)
    }
    
    
    /// 添加满意度
    /// - Parameters:
    ///   - _sid: 会话ID
    ///   - _pt: 满意度推送类型，0：未知，1：系统自动推送，2：访客主动评价，4：坐席主动推送
    ///   - _main: 会话满意度信息
    ///   - _subject: PublishSubject<Any>?
    ///   - _isloading: Bool true 加载动画
    private func evaluatFadebackFor(SessionId _sid:String,
                                    andPushType _pt:Int,
                                    withMainata _main:[String:Any],
                                    withOptions _options:[String:Any],
                                    andPublishSubject _subject:PublishSubject<Any>?,
                                    adisLoading _isloading:Bool,
                                    andMessageId _mid:Int64){
        let strUrl = VXIUrlSetting.shareInstance.evaluatFadeback()
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name:"Accept", value: "application/json"),
            HTTPHeader.init(name:"Content-Type", value: "application/json;charset=UTF-8"),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: VXISocketManager.share.xentry ?? ""),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: VXISocketManager.share.deviceId ?? "")
        ]
        
        let _dicParams:[String:Any] = [
            "sessionId":_sid,
            "pushType":_pt,
            "main":_main,
            "options":[
                _options,
            ],
            "messageId":_mid
        ]
        
        CMRequest.shareInstance().postRequestWithBodyFor(strUrl: strUrl,
                                                         WithBody: TGSUIModel.getJsonDataFor(Any: _dicParams),
                                                         AndRequestHeaders: _headers,
                                                         AndSuccessBack: { responseData in
            debugPrint("evaluatFadebackFor-请求成功！详见：\(responseData ?? "--")")
            _subject?.onNext((true,"请求成功",_mid))
        },
                                                         AndFailureBack: { responseString in
            debugPrint("evaluatFadebackFor-请求异常！详见：\(responseString ?? "--")")
            _subject?.onNext((false,responseString ?? "请求失败",_mid))
        },
                                                         WithisLoading: _isloading)
    }
    
    
    /// 修改满意度评价
    /// - Parameters:
    ///   - satisfactionId:Int64 满意度评价id
    ///   - _sid: 会话ID
    ///   - _pt: 满意度推送类型，0：未知，1：系统自动推送，2：访客主动评价，4：坐席主动推送
    ///   - _main: 会话满意度信息
    ///   - _subject: PublishSubject<Any>?
    ///   - _isloading: Bool true 加载动画
    private func evaluatUpdateFadebackBy(SatisfactionId:Int64,
                                         andSessionId _sid:String,
                                         andPushType _pt:Int,
                                         withMainata _main:[String:Any],
                                         withOptions _options:[String:Any],
                                         andPublishSubject _subject:PublishSubject<Any>?,
                                         adisLoading _isloading:Bool,
                                         andMessageId _mid:Int64){
        let strUrl = VXIUrlSetting.shareInstance.evaluateFaceback(satisfactionId: SatisfactionId)
        
        let _dicParams:[String:Any] = [
            "sessionId":_sid,
            "satisfactionId":SatisfactionId,
            "pushType":_pt,
            "main":_main,
            "options":[
                _options,
            ],
            "messageId":_mid
        ]
        
        CMRequest.shareInstance().putRequestWithBodyFor(strUrl: strUrl,
                                                        WithBody: TGSUIModel.getJsonDataFor(Any: _dicParams),
                                                        AndSuccessBack: { responseData in
            debugPrint("evaluatUpdateFadebackBy-请求成功！详见：\(responseData ?? "--")")
            _subject?.onNext((true,"请求成功",_mid))
        },
                                                        AndFailureBack: { responseString in
            debugPrint("evaluatUpdateFadebackBy-请求异常！详见：\(responseString ?? "--")")
            _subject?.onNext((false,responseString ?? "请求失败",_mid))
        },
                                                        WithisLoading: _isloading)
    }
    
    
    /// 获取满意度评价回显数据
    /// - Parameters:
    ///   - _sid: String 会话id
    ///   - _loading: Bool 是否加载动画
    ///   - _mid: Int64 会话消息编号(每个会话是唯一的)
    ///   - _subject: <#_subject description#>
    private func evaluatGetFeedbackDataBy(SessionId _sid:String,
                                          andLoading _loading:Bool,
                                          andMessageId _mid:Int64,
                                          andPublishSubject _subject:PublishSubject<Any>?){
        let strUrl = VXIUrlSetting.shareInstance.evaluatFadeback()
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name:"Accept", value: "application/json"),
            HTTPHeader.init(name:"Content-Type", value: "application/json;charset=UTF-8"),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: VXISocketManager.share.xentry ?? ""),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: VXISocketManager.share.deviceId ?? "")
        ]
        
        let _dicParams:[String:Any] = [
            "sessionId":_sid
        ]
        
        CMRequest.shareInstance().getRequestForServerData(strUrl: strUrl,
                                                          WithParameters: _dicParams,
                                                          AndSuccessBack: { responseData in
            if responseData != nil,
               let _data = TGSUIModel.getJsonDataFor(Any: responseData!) {
                do {
                    let _result = try JSONDecoder.init().decode(EvaluatResultModel.self, from: _data)
                    _subject?.onNext((true,_result,_mid))
                }
                catch(let _error){
                    debugPrint(_error.localizedDescription)
                    _subject?.onNext((false,_error.localizedDescription,_mid))
                }
            }
            else{
                _subject?.onNext((false,"数据请求失败",_mid))
                debugPrint("getFeedbackDataBy-请求失败！详见：\(responseData ?? "--")")
            }
        },
                                                          AndFailureBack: { responseString in
            _subject?.onNext((false,responseString ?? "数据请求失败",_mid))
            debugPrint("getFeedbackDataBy-请求异常！详见：\(responseString ?? "--")")
        },
                                                          WithisLoading: _loading,
                                                          AndRequestHeaders: _headers)
    }
    
    
    //MARK: - 加载历史数据
    /// 加载历史数据
    /// - Parameters:
    ///   - _d: String方向 new:新消息;old:历史消息;
    ///   - _mid: 消息Id 首次进来传 null
    ///   - _loading: <#_loading description#>
    ///   - _subject: <#_subject description#>
    private func loadConversationHistoryFor(Direction _d:String,
                                            andMessageId _mid:Int64?,
                                            andLoading _loading:Bool,
                                            andPublishSubject _subject:PublishSubject<Any>?){
        let _strUrl = VXIUrlSetting.shareInstance.conversationtHistory()
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name:"Accept", value: "application/json"),
            HTTPHeader.init(name:"Content-Type", value: "application/json;charset=UTF-8"),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: VXISocketManager.share.xentry ?? ""),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: VXISocketManager.share.deviceId ?? "")
        ]
        
        var _dicParams = [
            "direction":_d,
            "size":VXIUIConfig.shareInstance.cellPageSize()
        ] as [String : Any]
        
        if _mid != nil {
            _dicParams["messageId"] = _mid!
        }
        
        CMRequest.shareInstance().postRequestWithBodyFor(strUrl: _strUrl,
                                                         WithBody: TGSUIModel.getJsonDataFor(Any: _dicParams),
                                                         AndRequestHeaders: _headers,
                                                         AndSuccessBack: { responseData in
            if responseData != nil,let _data = TGSUIModel.getJsonDataFor(Any: responseData!) {
                do{
                    let _result = try JSONDecoder.init().decode([MessageModel].self, from: _data)
                    _subject?.onNext((true,_result,"加载成功",_d))
                }
                catch(let _error){
                    debugPrint(_error)
                    _subject?.onNext((false,[MessageModel].self,_error.localizedDescription,_d))
                }
            }
            else{
                _subject?.onNext((false,[MessageModel].self,"数据加载失败",_d))
            }
        },
                                                         AndFailureBack: { responseString in
            debugPrint("loadConversationHistoryFor-请求异常！详见：\(responseString ?? "--")")
            _subject?.onNext((false,[MessageModel].self,responseString ?? "请求异常",_d))
        },
                                                         WithisLoading: _loading)
    }
    
    //MARK: - 未读消
    /// 未读消置为已读
    /// - Parameters:
    ///   - _lmd: Int64 最后一条消息Id
    ///   - _loading: Bool
    ///   - _uc: Int 未读消息数
    ///   - _subject: <#_subject description#>
    private func messageReadFor(LastMessageId _lmd:Int64,
                                andLoading _loading:Bool,
                                andUnreadCount _uc:Int,
                                andPublishSubject _subject:PublishSubject<Any>?){
        
        let _strUrl = VXIUrlSetting.shareInstance.messageReadFor(LastMessageId: _lmd)
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name:"Accept", value: "application/json"),
            HTTPHeader.init(name:"Content-Type", value: "application/json;charset=UTF-8"),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: VXISocketManager.share.xentry ?? ""),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: VXISocketManager.share.deviceId ?? "")
        ]
        
        CMRequest.shareInstance().patchRequestWithBodyFor(strUrl: _strUrl,
                                                          WithBody: nil,
                                                          AndRequestHeaders: _headers,
                                                          AndSuccessBack: { responseData in
            debugPrint("messageReadFor-请求成功！详见：\(responseData ?? "--")")
            _subject?.onNext((true,"操作成功",_lmd,_uc))
        },
                                                          AndFailureBack: { responseString in
            debugPrint("messageReadFor-请求异常！详见：\(responseString ?? "--")")
            _subject?.onNext((false,responseString ?? "请求异常",_lmd,_uc))
        },
                                                          WithisLoading: _loading)
    }
    
    
    //MARK: - 消息撤回
    /// 消息撤回处理
    /// - Parameters:
    ///   - _mid: Int64 需要撤回的消息编号
    ///   - _loading: Bool 加载动画
    ///   - _subject: <#_subject description#>
    private func messageRevokeFor(MessageId _mid:Int64,
                                  andLoading _loading:Bool,
                                  andPublishSubject _subject:PublishSubject<Any>?){
        
        let _strUrl = VXIUrlSetting.shareInstance.messageRevokeFor(MessageId: _mid)
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name:"Accept", value: "application/json"),
            HTTPHeader.init(name:"Content-Type", value: "application/json;charset=UTF-8"),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: VXISocketManager.share.xentry ?? ""),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: VXISocketManager.share.deviceId ?? "")
        ]
        
        CMRequest.shareInstance().patchRequestWithBodyFor(strUrl: _strUrl,
                                                          WithBody: nil,
                                                          AndRequestHeaders: _headers,
                                                          AndSuccessBack: { responseData in
            debugPrint("messageRevokeFor-请求成功！详见：\(responseData ?? "--")")
            _subject?.onNext((true,"操作成功",_mid))
        },
                                                          AndFailureBack: { responseString in
            debugPrint("messageRevokeFor-请求异常！详见：\(responseString ?? "--")")
            _subject?.onNext((false,responseString ?? "请求异常",_mid))
        },
                                                          WithisLoading: _loading)
    }
    
    
    //MARK: - 留言
    /// 查询默认留言设置
    /// - Parameters:
    ///   - _subject: PublishSubject<Any>?
    ///   - _isloading: true 加载动画
    ///   - _save: true 需要保存本地
    private func leaveMessageLoadConfigFor(PublishSubject _subject:PublishSubject<Any>?,
                                           andisLoading _isloading:Bool,
                                           andNeedSavaLoacl _save:Bool) {
        let _strUrl = VXIUrlSetting.shareInstance.leaveMessageDefaultConfig()
        CMRequest.shareInstance().getRequestForServerData(strUrl: _strUrl,
                                                          WithParameters: nil,
                                                          AndSuccessBack: { responseData in
            debugPrint("leaveMessageLoadConfigFor-请求成功详见：\(responseData ?? "--")")
            if responseData != nil {
                if let _data = TGSUIModel.getJsonDataFor(Any: responseData!) {
                    do{
                        let result = try JSONDecoder.init().decode(LeaveMessageModel.self, from: _data)
                        _subject?.onNext((true,result,"请求成功"))
                        
                        if _save {
                            String.writeLocalCacheData(data: _data, key: VXIUIConfig.shareInstance.getLeaveMessageDefaultKey())
                        }
                    }
                    catch(let _error){
                        _subject?.onNext((false,LeaveMessageModel.self,_error.localizedDescription))
                        debugPrint("leaveMessageLoadConfigFor-保存数据异常！详见：\(_error)")
                    }
                }
                else{
                    _subject?.onNext((false,LeaveMessageModel.self,"数据转换失败"))
                }
            }
            else{
                _subject?.onNext((false,LeaveMessageModel.self,"默认留言设置数据不存在"))
            }
        },
                                                          AndFailureBack: { responseString in
            debugPrint("leaveMessageLoadConfigFor-请求异常详见：\(responseString ?? "--")")
            _subject?.onNext((false,LeaveMessageModel.self,responseString ?? "默认留言设置加载异常"))
        },
                                                          WithisLoading: _isloading)
    }
    
    
    /// 提交留言
    /// - Parameters:
    ///   - _sid: String 会话Id
    ///   - _tid: Int64 留言模板Id
    ///   - _mid: Int64 留言按钮对应的消息Id
    ///   - _content: [String:Any] 留言内容 {"你的名字":"张三","手机号":"13012345678"}
    ///   - _attachments: [String:Any]? 附件信息
    ///   - _subject: <#_subject description#>
    ///   - _isloading: <#_isloading description#>
    private func leaveMessageSubmitFor(SessionId _sid:String,
                                       andTemplateId _tid:Int64,
                                       andMessageId _mid:Int64,
                                       withContent _content:[String:Any],
                                       withAttachments _attachments:[String:Any]?,
                                       andPublishSubject _subject:PublishSubject<Any>?,
                                       andisLoading _isloading:Bool){
        let strUrl = VXIUrlSetting.shareInstance.leaveMessageSutmit()
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name:"Accept", value: "application/json"),
            HTTPHeader.init(name:"Content-Type", value: "application/json;charset=UTF-8"),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: VXISocketManager.share.xentry ?? ""),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: VXISocketManager.share.deviceId ?? "")
        ]
        
        var _dicParams:[String:Any] = [
            "sessionId":_sid,
            "templateId":_tid,
            "content":_content,
            "messageId":_mid,
        ]
        
        //附件
        if _attachments != nil && (_attachments?.keys.count ?? 0) > 0 {
            _dicParams["attachments"] = [_attachments]//数组
        }
        
        CMRequest.shareInstance().postRequestWithBodyFor(strUrl: strUrl,
                                                         WithBody: TGSUIModel.getJsonDataFor(Any: _dicParams),
                                                         AndRequestHeaders: _headers,
                                                         AndSuccessBack: { responseData in
            debugPrint("leaveMessageSubmitFor-请求成功！详见：\(responseData ?? "--")")
            _subject?.onNext((true,"请求成功"))
        },
                                                         AndFailureBack: { responseString in
            debugPrint("leaveMessageSubmitFor-请求异常！详见：\(responseString ?? "--")")
            _subject?.onNext((false,responseString ?? "请求失败"))
        },
                                                         WithisLoading: _isloading)
    }
    
    //MARK: - 点击问题
    /// 点击问题
    /// - Parameters:
    ///   - _qid: String 问题Id
    ///   - _qt: String 问题标题
    ///   - _subject: PublishSubject<Any>?
    ///   - _isloading: Bool true 加载动画
    private func questionClickBy(QuestionId _qid:String,
                                 andQuestionTitle _qt:String,
                                 andPublishSubject _subject:PublishSubject<Any>?,
                                 andisLoading _isloading:Bool){
        let strUrl = VXIUrlSetting.shareInstance.questionClick() + _qid
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name:"Accept", value: "application/json"),
            HTTPHeader.init(name:"Content-Type", value: "application/json;charset=UTF-8"),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: VXISocketManager.share.xentry ?? ""),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: VXISocketManager.share.deviceId ?? "")
        ]
        
        let _dicParams:[String:Any] = [
            "questionTitle":_qt,
        ]
        
        CMRequest.shareInstance().postRequestWithBodyFor(strUrl: strUrl,
                                                         WithBody: TGSUIModel.getJsonDataFor(Any: _dicParams),
                                                         AndRequestHeaders: _headers,
                                                         AndSuccessBack: { responseData in
            debugPrint("questionClickSubmitBy-请求成功！详见：\(responseData ?? "--")")
            _subject?.onNext((true,"请求成功"))
        },
                                                         AndFailureBack: { responseString in
            debugPrint("questionClickSubmitBy-请求异常！详见：\(responseString ?? "--")")
            _subject?.onNext((false,responseString ?? "请求失败"))
        },
                                                         WithisLoading: _isloading)
    }
    
    
    /// 有/无帮助提交
    /// - Parameters:
    ///   - _mid: Int64 消息Id
    ///   - _op: Bool true 有帮助 Bool
    ///   - _loading: Bool true 加载动画
    ///   - _c: String? 无帮助的评论内容
    ///   - _subject: PublishSubject<Any>?
    private func questionCommentSubmit(MessageId _mid:Int64,
                                       andOptionHelop _op:Bool,
                                       andLoading _loading:Bool,
                                       andContent _c:String?,
                                       andPublishSubject _subject:PublishSubject<Any>?){
        
        let _strUrl = VXIUrlSetting.shareInstance.questionComment(MessageId: _mid)
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name:"Accept", value: "application/json"),
            HTTPHeader.init(name:"Content-Type", value: "application/json;charset=UTF-8"),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: VXISocketManager.share.xentry ?? ""),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: VXISocketManager.share.deviceId ?? "")
        ]
        
        var _dicParams = [
            "option":_op ? "up":"down"
        ]
        
        if _c != nil && _c?.isEmpty == false {
            _dicParams["content"] = _c!
        }
        
        CMRequest.shareInstance().patchRequestWithBodyFor(strUrl: _strUrl,
                                                          WithBody: TGSUIModel.getJsonDataFor(Any: _dicParams),
                                                          AndRequestHeaders: _headers,
                                                          AndSuccessBack: { responseData in
            debugPrint("questionCommentSubmit-请求成功！详见：\(responseData ?? "--")")
            _subject?.onNext((true,"操作成功",_mid,_op))
        },
                                                          AndFailureBack: { responseString in
            debugPrint("questionCommentSubmit-请求异常！详见：\(responseString ?? "--")")
            _subject?.onNext((false,responseString ?? "请求异常",_mid,_op))
        },
                                                          WithisLoading: _loading)
    }
}


//MARK: - 静态方法
extension VXIChatViewModel {
    
    
    /// 客户推送主动评价
    /// - Parameters:
    ///   - _isloading: <#_isloading description#>
    ///   - _fb: <#_fb description#>
    static func sessionSatisfactionPushFor(isLoading _isloading:Bool,
                                           withFinishblock _fb:@escaping((Bool,String)->Void)){
        let strUrl = VXIUrlSetting.shareInstance.satisfactionPush()
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name:"Accept", value: "application/json"),
            HTTPHeader.init(name:"Content-Type", value: "application/json;charset=UTF-8"),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: VXISocketManager.share.xentry ?? ""),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: VXISocketManager.share.deviceId ?? "")
        ]
        
        CMRequest.shareInstance().postRequestWithBodyFor(strUrl: strUrl,
                                                         WithBody: nil,
                                                         AndRequestHeaders: _headers,
                                                         AndSuccessBack: { responseData in
            debugPrint("sessionSatisfactionPushFor-请求成功！详见：\(responseData ?? "--")")
            _fb(true,"请求成功")
        },
                                                         AndFailureBack: { responseString in
            debugPrint("sessionSatisfactionPushFor-请求异常！详见：\(responseString ?? "--")")
            _fb(false,responseString ?? "请求失败")
        },
                                                         WithisLoading: _isloading)
    }
    
    
    /// 文件上传
    /// - Parameters:
    ///   - _fd: Data
    ///   - _fn: String 文件名
    ///   - fb: ((Bool,String)->Void)
    ///   - _loading: <#_loading description#>
    static func conversationUploadFor(FileData _fd:Data,
                                      andFileName _fn:String,
                                      andMimeType _type:String,
                                      withFinishblock _fb:@escaping((Bool,String,Data,String)->Void),
                                      andProgressBlock _progressBlock:((_ progress:Double) -> (Void))?,
                                      andLoading _loading:Bool = false,
                                      andisFullPath _ifp:Bool = true){
        let _strUrl = VXIUrlSetting.shareInstance.conversationUpload()
        
        let _headers:HTTPHeaders = [
            HTTPHeader.init(name:"Accept", value: "*/*"),
            HTTPHeader.init(name:"Content-Type", value: "multipart/form-data"),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: VXISocketManager.share.xentry ?? ""),
            HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: VXISocketManager.share.deviceId ?? "")
        ]
        debugPrint(_headers)
        
        CMRequest.shareInstance().postImageUploadToServer(strUrl: _strUrl,
                                                          uploadformDataBack: { fData in
            fData.append(_fd, withName: "file", fileName: _fn,mimeType: _type)
            debugPrint("formData-file:{fileName:\(_fn),mimeType:\(_type)}")
        }, AndSuccessBack: { responseData in
            debugPrint("conversationUploadFor-文件上传成功！详见：\(responseData ?? "")")
            if let dicTemp = responseData as? [String:Any],
               let _url = dicTemp["url"] as? String,_url != "" {
                let _actualContentType = dicTemp["actualContentType"] as? String ?? ""
                if _ifp {
                    //绝对路径
                    _fb(true,TGSUIModel.getFileRealUrlFor(Path: _url, andisThumbnail: false),_fd,_actualContentType)
                }
                else{
                    //相对路径
                    _fb(true,_url,_fd,_actualContentType)
                }
            }
            else{
                _fb(false,"上传失败，请稍后再试",_fd,"")
            }
        }, AndFailureBack: { responseString in
            print("conversationUploadFor-文件上传失败！详见：\(responseString ?? "--")")
            _fb(false,responseString ?? "",_fd,"")
        }, AndProgressBlock: { progress in
            if _progressBlock != nil {
                _progressBlock?(progress)
            }
        },
                                                          AndRequestHeaders: _headers,
                                                          WithisLoading: _loading)
    }
    
    
    /// 批量文件上传
    /// - Parameters:
    ///   - _arr: <#_arr description#>
    ///   - _arr_name: <#_arr_name description#>
    ///   - ld: <#ld description#>
    ///   - fb: <#fb description#>
    static func conversationUploadFor(FilesData _arr:[Data],
                                      andFilesName _arr_name:[String],
                                      andMimeType _types:[String],
                                      andProgressBlocks _progressBlock:((_ _progress:Double,_ _total:Int) -> (Void))?,
                                      withFinishBlock _fb:@escaping((_ _imgUrls:[Data:String],_ _total:Int)->(Void)),
                                      andisFullPath _ifp:Bool = true,
                                      andLoading _ld:Bool = true){
        
        if _ld {
            VXIUIConfig.shareInstance.keyWindow().showHud(at: "上传中...")
        }
        
        let groupQueue = DispatchGroup.init()
        var _arrUploadUrls = [Data:String]()
        
        var _p:Double = 0
        for _i in 0..<_arr.count {
            groupQueue.enter()
            let queue = DispatchQueue(label: "file_upload_\(_i)",
                                      qos: .default,
                                      attributes: .concurrent,
                                      autoreleaseFrequency: .inherit,
                                      target: nil)
            queue.async(group: groupQueue, qos: .default, flags: []) {
                let _f_n:String = "\(Int64(Date.init().timeIntervalSince1970 * 1000))_\(_i)"
                conversationUploadFor(FileData: _arr[_i],
                                      andFileName: _arr_name.count > _i ? _arr_name[_i] : _f_n,
                                      andMimeType: (_types.count > _i ? _types[_i] : _types.first) ?? "*/*",
                                      withFinishblock: { (_isOk:Bool, _url:String,_data:Data,_actualContentType) in
                    groupQueue.leave()
                    if _isOk {
                        _arrUploadUrls[_data] = _url
                    }
                }, andProgressBlock: { _progress in
                    _p += _progress
                    _progressBlock?(_p,_arr.count)
                },
                                      andLoading: false,
                                      andisFullPath: _ifp)
            }
        }
        
        groupQueue.notify(queue: .main) {
            SVProgressHUD.dismiss()
            _fb(_arrUploadUrls,_arr.count)
        }
    }
}
