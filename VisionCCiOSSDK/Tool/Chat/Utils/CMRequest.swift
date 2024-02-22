//
//  CMRequest.swift
//  SwiftDemo
//
//  Created by mac on 2020/4/27.
//  Copyright © 2020 yimiSun. All rights reserved.
//


import Alamofire
import Foundation
import UIKit
@_implementationOnly import VisionCCiOSSDKEngine

/**
 * 网络请求
 * Alamofire 5 的使用 - 基本用法
 * https://www.jianshu.com/p/4381fe8e10b6
 */
struct CMRequest {
    
    public typealias SuccessBlock  = (_ responseData:Any?) -> (Void)
    public typealias FinishBlock   = (_ responseData:Data?) -> (Void)
    public typealias FailureBlock  = (_ responseString:String?) -> (Void)
    public typealias ProgressBlock = (_ progress:Double) -> (Void)
    
    private static let _request = CMRequest.init()
    static func shareInstance() -> CMRequest {
        return _request
    }
    
    private struct DecodableType: Decodable { }
    
    //MARK: - errorHandle
    private func errorHandle(Error e:NSError?,
                             statusCode:Int?,
                             andErrormsg ems:inout String?) {
        let code:Int? = e?.code
        debugPrint("error code:\(code ?? 0),statusCode:\(statusCode ?? 0)")
        
        //https://www.jb51.net/article/105163.htm
        switch statusCode {
        case .some(302):
            ems = "请求被重定向"
            
        case .some(400):
            ems = "发送的请求有语法错误"
            
        case .some(401):
            ems = "访问没有授权"
            
        case .some(403):
            ems = "没有权限访问"
            
        case .some(404):
            ems = "请求地址不存在"
            
        case .some(405):
            ems = "请求方式不存在"
            
        case .some(408),.some(504):
            ems = "请求超时,请检查网络或重试"
            
        case .some(502):
            ems = "服务器正在重启"
            
        case .some(500):
            ems = "服务器内部异常,无法完成请求处理"
            
        case .some(507):
            ems = "服务器无法存储完成请求所必须的内容"
            
        case .some(509):
            ems = "服务器达到带宽限制"
            
        case .some(510):
            ems = "获取资源所需要的策略并没有没满足"
            
        case .some(10):
            ems = ems ?? "未能读取数据，因为它的格式不正确"
            
        default:
            break
        }
        
        switch code {
        case .some(-1001):
            ems = "请求超时"
            
            //token 过期
        case .some(-1011),.some(3),.some(9):
            if statusCode == 401 {
                ems = "未登录或已在别处登录"
            }
            
        case .some(-32700):
            ems = "类型转换错误"
            
        case .some(-32600):
            ems = "无效的请求"
            
        case .some(-32601):
            ems = "没有找到方法"
            
        case .some(-32602):
            ems = "无效的参数"
            
        case .some(-32603),.some(-1009),.some(13):
            ems = "网络异常，请检查网络"
            
        default:
            break
        }
    }
    
    /// 请求头公共处理
    /// - Parameter _hander: <#_hander description#>
    private func requestReprocess(HttpHander _handers:inout HTTPHeaders?) {
        
        if _handers == nil {
            _handers = [
                "Accept":"application/json",
                "Content-Type":"application/json;charset=UTF-8"
            ]
        }
        
        //x-entry
        if let userLoginToken: String = UserDefaults.standard.string(forKey: VXIUIConfig.shareInstance.appUserLoginToken()),
           userLoginToken != "",
           _handers?.first(where: { $0.name == VXIUIConfig.shareInstance.userToken() }) == nil {
            _handers?.add(HTTPHeader.init(name: VXIUIConfig.shareInstance.userToken(), value: userLoginToken))
        }
        
        //x-device-id
        if let _deviceId:String = VXISocketManager.share.deviceId,_deviceId.isEmpty == false,
           _handers?.first(where: { $0.name == VXIUIConfig.shareInstance.userDeviceId() }) == nil {
            _handers?.add(HTTPHeader.init(name: VXIUIConfig.shareInstance.userDeviceId(), value: _deviceId))
        }
        
        //UserAgent
        if _handers?.first(where: { $0.name == "user-agent" }) == nil {
            let _sdk_version = CCKFApi.getSDKVersion()
            let brand: String = UIDevice.current.model
            let model: String = UIDevice.current.modelName
            let phoneVersion: String = UIDevice.current.systemVersion
            _handers?.add(HTTPHeader.init(name: "user-agent", value: "VxiChatSDK/\(_sdk_version)(\(brand); \(model); \(phoneVersion))"))
        }
        
        //appkey
        if _handers?.first(where: { $0.name == "Authorization" }) == nil,
           let _ak = VXISocketManager.share.appKey,_ak.isEmpty == false {
            _handers?.add(HTTPHeader.init(name: "Authorization", value:"bearer \(_ak)"))
        }
        
        //accept-language
        if _handers?.first(where: { $0.name == "accept-language" }) == nil,
           let _ak = VXISocketManager.share.appKey,_ak.isEmpty == false {
            _handers?.add(HTTPHeader.init(name: "accept-language", value:"zh-CN"))
        }
        
        debugPrint(_handers ?? "--")
    }
    
    
    //MARK: -
    /// GET请求
    /// - Parameters:
    ///   - strUrl: 请求地址
    ///   - paras: 请求参数
    ///   - successBack: 成功回调
    ///   - failureBack: 失败回到
    ///   - isLoading: 是否加载动画
    func getRequestForServerData(strUrl:String,
                                 WithParameters paras:[String:Any]?,
                                 AndSuccessBack successBack:@escaping SuccessBlock,
                                 AndFailureBack failureBack:@escaping FailureBlock,
                                 WithisLoading isLoading:Bool = true,
                                 AndRequestHeaders _headers:HTTPHeaders? = nil){
        
        var _strUrl = strUrl
        if paras != nil && paras!.count > 0 {
            _strUrl = "\(strUrl)?\(paras!.map({ return "\($0.key)=\($0.value)"}).joined(separator: "&"))"
            debugPrint("请求地址：\(_strUrl)")
        }
        else{
            debugPrint("请求地址：\(strUrl)")
        }
        
        if isLoading == true {
            VXIUIConfig.shareInstance.keyWindow().showHud(at: VXIUIConfig.shareInstance.appLoadInfo())
        }
        
        var nh:HTTPHeaders? = _headers
        self.requestReprocess(HttpHander: &nh)
        
        AF.request(strUrl,
                   method: .get,
                   parameters: paras,
                   headers: nh,
                   requestModifier: { $0.timeoutInterval = VXIUIConfig.shareInstance.appRequestTimeOut() })
        .validate()
        .validate(contentType: VXIUIConfig.shareInstance.appAcceptableContenttypes())
        .responseDecodable(of: DecodableType.self, completionHandler: { response in
            
            if isLoading == true {
                SVProgressHUD.dismiss()
            }
            
            let _statusCode:Int? = response.response?.statusCode
            var msg:String? = response.error?.localizedDescription ?? ""
            self.errorHandle(Error: response.error as NSError?,
                             statusCode: _statusCode,
                             andErrormsg: &msg)
            
            self.setReturnValueFor(Data: response.data,
                                   withStatusCode: _statusCode,
                                   andSuccessBack: successBack,
                                   andFailureBack: failureBack,
                                   andMessage: msg)
        })
    }
    
    
    /// post 接口请求
    /// - Parameter strUrl: 请求地址
    /// - Parameter paras: 请求参数
    /// - Parameter headers: 请求头
    /// - Parameter successBack: 成功回调
    /// - Parameter failureBack: 失败回调
    /// - Parameter isLoading: 是否加载动画
    func postRequestWithParamsFor(strUrl:String,
                                  WithParameters paras:[String:Any]?,
                                  AndRequestHeaders _headers:HTTPHeaders?,
                                  AndSuccessBack successBack:@escaping SuccessBlock,
                                  AndFailureBack failureBack:@escaping FailureBlock,
                                  WithisLoading isLoading:Bool = true,
                                  AndLoadMessage msg:String = VXIUIConfig.shareInstance.appLoadInfo()){
        
        debugPrint("请求地址：\(strUrl)?\(paras?.map({ return "\($0.key)=\($0.value)"}).joined(separator: "&") ?? "--")")
        
        if isLoading == true {
            VXIUIConfig.shareInstance.keyWindow().showHud(at: msg)
        }
        
        var _nh = _headers
        self.requestReprocess(HttpHander: &_nh)
        
        AF.request(strUrl,
                   method: .post,
                   parameters: paras,
                   headers: _nh,
                   requestModifier: { $0.timeoutInterval = VXIUIConfig.shareInstance.appRequestTimeOut() })
        .validate()
        .validate(contentType: VXIUIConfig.shareInstance.appAcceptableContenttypes())
        .responseDecodable(of: DecodableType.self, completionHandler: { response in
            
            if isLoading == true {
                SVProgressHUD.dismiss()
            }
            
            let _statusCode:Int? = response.response?.statusCode
            var msg:String? = response.error?.localizedDescription ?? ""
            self.errorHandle(Error: response.error as NSError?,
                             statusCode: _statusCode,
                             andErrormsg: &msg)
            
            self.setReturnValueFor(Data: response.data,
                                   withStatusCode: _statusCode,
                                   andSuccessBack: successBack,
                                   andFailureBack: failureBack,
                                   andMessage: msg)
        })
    }
    
    
    /**!
     * post 接口请求
     * @para strUrl   String 请求地址
     * @para body     Data? 请求参数
     * @para successBack  成功回调
     * @para failureBack  失败回调
     */
    func postRequestWithBodyFor(strUrl:String,
                                WithBody body:Data?,
                                AndRequestHeaders _headers:HTTPHeaders?,
                                AndSuccessBack successBack:@escaping SuccessBlock,
                                AndFailureBack failureBack:@escaping FailureBlock,
                                WithisLoading isLoading:Bool = true,
                                AndLoadMessage msg:String = VXIUIConfig.shareInstance.appLoadInfo(),
                                AndTimeOut tm:TimeInterval = VXIUIConfig.shareInstance.appRequestTimeOut()) {
        
        if body != nil {
            print("请求地址：\(strUrl),参数：\(NSString.init(data: body!, encoding: String.Encoding.utf8.rawValue) ?? "暂无参数")")
        }
        else{
            debugPrint("请求地址：\(strUrl),暂无参数")
        }
        
        if isLoading == true {
            VXIUIConfig.shareInstance.keyWindow().showHud(at: msg)
        }
        
        var _nh = _headers
        if _nh == nil {
            _nh = [
                "Accept":"application/json",
                "Content-Type":"application/json;charset=UTF-8"
            ]
        }
        self.requestReprocess(HttpHander: &_nh)
        
        AF.request(strUrl,
                   method: .post,
                   headers: _nh,
                   requestModifier: {
            $0.timeoutInterval = tm
            $0.httpBody = body
        })
        .validate()
        .validate(contentType: VXIUIConfig.shareInstance.appAcceptableContenttypes())
        .responseDecodable(of: DecodableType.self, completionHandler: { response in
            
            if isLoading == true {
                SVProgressHUD.dismiss()
            }
            
            let _statusCode:Int? = response.response?.statusCode
            var msg:String? = response.error?.localizedDescription ?? ""
            self.errorHandle(Error: response.error as NSError?,
                             statusCode: _statusCode,
                             andErrormsg: &msg)
            
            self.setReturnValueFor(Data: response.data,
                                   withStatusCode: _statusCode,
                                   andSuccessBack: successBack,
                                   andFailureBack: failureBack,
                                   andMessage: msg)
        })
    }
    
    
    /// patch 接口请求
    /// - Parameters:
    ///   - strUrl: String
    ///   - body: Data?
    ///   - _headers: HTTPHeaders?
    ///   - successBack: (_ responseData:Any?) -> (Void)
    ///   - failureBack:  (_ responseString:String?) -> (Void)
    ///   - isLoading: Bool true 加载动画
    ///   - msg: String
    ///   - tm: TimeInterval
    func patchRequestWithBodyFor(strUrl:String,
                                 WithBody body:Data?,
                                 AndRequestHeaders _headers:HTTPHeaders?,
                                 AndSuccessBack successBack:@escaping SuccessBlock,
                                 AndFailureBack failureBack:@escaping FailureBlock,
                                 WithisLoading isLoading:Bool = true,
                                 AndLoadMessage msg:String = VXIUIConfig.shareInstance.appLoadInfo(),
                                 AndTimeOut tm:TimeInterval = VXIUIConfig.shareInstance.appRequestTimeOut()) {
        
        if body != nil {
            print("请求地址：\(strUrl),参数：\(NSString.init(data: body!, encoding: String.Encoding.utf8.rawValue) ?? "暂无参数")")
        }
        else{
            debugPrint("请求地址：\(strUrl),暂无参数")
        }
        
        if isLoading == true {
            VXIUIConfig.shareInstance.keyWindow().showHud(at: msg)
        }
        
        var _nh = _headers
        if _nh == nil {
            _nh = [
                "Accept":"application/json",
                "Content-Type":"application/json;charset=UTF-8"
            ]
        }
        self.requestReprocess(HttpHander: &_nh)
        
        AF.request(strUrl,
                   method: .patch,
                   headers: _nh,
                   requestModifier: {
            $0.timeoutInterval = tm
            $0.httpBody = body
        })
        .validate()
        .validate(contentType: VXIUIConfig.shareInstance.appAcceptableContenttypes())
        .responseDecodable(of: DecodableType.self, completionHandler: { response in
            
            if isLoading == true {
                SVProgressHUD.dismiss()
            }
            
            let _statusCode:Int? = response.response?.statusCode
            var msg:String? = response.error?.localizedDescription ?? ""
            self.errorHandle(Error: response.error as NSError?,
                             statusCode: _statusCode,
                             andErrormsg: &msg)
            
            self.setReturnValueFor(Data: response.data,
                                   withStatusCode: _statusCode,
                                   andSuccessBack: successBack,
                                   andFailureBack: failureBack,
                                   andMessage: msg)
        })
    }
    
    
    /**!
     * put 接口请求
     * @para strUrl   String 请求地址
     * @para paras    [String:Any] 请求参数
     * @para successBack  成功回调
     * @para failureBack  失败回调
     */
    func putRequestForServerData(strUrl:String,
                                 WithParameters paras:[String:Any]?,
                                 AndSuccessBack successBack:@escaping SuccessBlock,
                                 AndFailureBack failureBack:@escaping FailureBlock,
                                 WithisLoading isLoading:Bool = true){
        
        if paras != nil {
            debugPrint("请求地址：\(strUrl)?\(paras!.map({ return "\($0.key)=\($0.value)"}).joined(separator: "&"))")
        }
        else{
            debugPrint("请求地址：\(strUrl)")
        }
        
        if isLoading == true {
            VXIUIConfig.shareInstance.keyWindow().showHud(at: VXIUIConfig.shareInstance.appLoadInfo())
        }
        
        AF.request(strUrl,
                   method: .put,
                   parameters: paras,
                   requestModifier: { $0.timeoutInterval = VXIUIConfig.shareInstance.appRequestTimeOut() })
        .validate()
        .validate(contentType: VXIUIConfig.shareInstance.appAcceptableContenttypes())
        .responseDecodable(of: DecodableType.self, completionHandler: { response in
            
            if isLoading == true {
                SVProgressHUD.dismiss()
            }
            
            let _statusCode:Int? = response.response?.statusCode
            var msg:String? = response.error?.localizedDescription ?? ""
            self.errorHandle(Error: response.error as NSError?,
                             statusCode: _statusCode,
                             andErrormsg: &msg)
            
            self.setReturnValueFor(Data: response.data,
                                   withStatusCode: _statusCode,
                                   andSuccessBack: successBack,
                                   andFailureBack: failureBack,
                                   andMessage: msg)
        })
    }
    
    
    /**!
     * put 接口请求
     * @para strUrl   String 请求地址
     * @para body     Data 请求参数
     * @para successBack  成功回调
     * @para failureBack  失败回调
     */
    func putRequestWithBodyFor(strUrl:String,
                               WithBody body:Data?,
                               AndSuccessBack successBack:@escaping SuccessBlock,
                               AndFailureBack failureBack:@escaping FailureBlock,
                               WithisLoading isLoading:Bool = true) {
        
        print("请求地址：\(strUrl),参数：\(NSString.init(data: body!, encoding: String.Encoding.utf8.rawValue) ?? "暂无参数")")
        
        if isLoading == true {
            VXIUIConfig.shareInstance.keyWindow().showHud(at: VXIUIConfig.shareInstance.appLoadInfo())
        }
        
        guard let _url = URL.init(string: strUrl.yl_urlEncoded()) else {
            failureBack("请求失败有误")
            return
        }
        
        var request = URLRequest.init(url: _url)
        request.httpBody = body
        request.httpMethod = "PUT"
        request.timeoutInterval = VXIUIConfig.shareInstance.appRequestTimeOut()
        
        var _hedders:HTTPHeaders?
        self.requestReprocess(HttpHander: &_hedders)
        if _hedders != nil {
            for _hedder in _hedders! {
                request.setValue(_hedder.value, forHTTPHeaderField: _hedder.name)
            }
        }
        
        if  let userLoginToken: String = UserDefaults.standard.string(forKey: VXIUIConfig.shareInstance.appUserLoginToken()),userLoginToken != "" {
            request.setValue(userLoginToken, forHTTPHeaderField: VXIUIConfig.shareInstance.appUserLoginToken())
        }
        
        AF.request(request)
            .validate()
            .validate(contentType: VXIUIConfig.shareInstance.appAcceptableContenttypes())
            .responseDecodable(of: DecodableType.self, completionHandler: { response in
                
                if isLoading == true {
                    SVProgressHUD.dismiss()
                }
                
                let _statusCode:Int? = response.response?.statusCode
                var msg:String? = response.error?.localizedDescription ?? ""
                self.errorHandle(Error: response.error as NSError?,
                                 statusCode: _statusCode,
                                 andErrormsg: &msg)
                
                self.setReturnValueFor(Data: response.data,
                                       withStatusCode: _statusCode,
                                       andSuccessBack: successBack,
                                       andFailureBack: failureBack,
                                       andMessage: msg)
            })
    }
    
    
    /**!
     * delete 接口请求
     * @para strUrl   String 请求地址
     * @para body    Data? 请求参数
     * @para successBack  成功回调
     * @para failureBack  失败回调
     */
    func deleteRequestForServerData(strUrl:String,
                                    WithBody body:[String:Any]?,
                                    AndSuccessBack successBack:@escaping SuccessBlock,
                                    AndFailureBack failureBack:@escaping FailureBlock,
                                    WithisLoading isLoading:Bool = true,
                                    AndRequestHeaders _headers:HTTPHeaders? = nil){
        
        if body != nil {
            debugPrint("请求地址：\(strUrl)?\(body!.map({ return "\($0.key)=\($0.value)"}).joined(separator: "&"))")
        }
        else{
            debugPrint("请求地址：\(strUrl)")
        }
        
        if isLoading == true {
            VXIUIConfig.shareInstance.keyWindow().showHud(at: VXIUIConfig.shareInstance.appLoadInfo())
        }
        
        var _nh = _headers
        self.requestReprocess(HttpHander: &_nh)
        
        AF.request(strUrl,
                   method: .delete,
                   parameters: body,
                   encoding: URLEncoding.httpBody,
                   headers: _nh,
                   requestModifier: { $0.timeoutInterval = VXIUIConfig.shareInstance.appRequestTimeOut() })
        .validate()
        .validate(contentType: VXIUIConfig.shareInstance.appAcceptableContenttypes())
        .responseDecodable(of: DecodableType.self, completionHandler: { response in
            
            if isLoading == true {
                SVProgressHUD.dismiss()
            }
            
            let _statusCode:Int? = response.response?.statusCode
            var msg:String? = response.error?.localizedDescription ?? ""
            self.errorHandle(Error: response.error as NSError?,
                             statusCode: _statusCode,
                             andErrormsg: &msg)
            
            self.setReturnValueFor(Data: response.data,
                                   withStatusCode: _statusCode,
                                   andSuccessBack: successBack,
                                   andFailureBack: failureBack,
                                   andMessage: msg)
        })
    }
    
    
    /**!
     * delete 接口请求
     * @para strUrl   String 请求地址
     * @para paras    [String:Any] 请求参数
     * @para successBack  成功回调
     * @para failureBack  失败回调
     */
    func deleteRequestForServerData(strUrl:String,
                                    WithParameters paras:[String:Any]?,
                                    AndSuccessBack successBack:@escaping SuccessBlock,
                                    AndFailureBack failureBack:@escaping FailureBlock,
                                    WithisLoading isLoading:Bool = true,
                                    AndRequestHeaders _headers:HTTPHeaders? = nil){
        
        if paras != nil {
            debugPrint("请求地址：\(strUrl)?\(paras!.map({ return "\($0.key)=\($0.value)"}).joined(separator: "&"))")
        }
        else{
            debugPrint("请求地址：\(strUrl)")
        }
        
        if isLoading == true {
            VXIUIConfig.shareInstance.keyWindow().showHud(at: VXIUIConfig.shareInstance.appLoadInfo())
        }
        
        var nh:HTTPHeaders? = _headers
        self.requestReprocess(HttpHander: &nh)
        
        AF.request(strUrl,
                   method: .delete,
                   parameters: paras,
                   headers: nh,
                   requestModifier: { $0.timeoutInterval = VXIUIConfig.shareInstance.appRequestTimeOut() })
        .validate()
        .validate(contentType: VXIUIConfig.shareInstance.appAcceptableContenttypes())
        .responseDecodable(of: DecodableType.self,
                           completionHandler: { response in
            
            if isLoading == true {
                SVProgressHUD.dismiss()
            }
            
            let _statusCode:Int? = response.response?.statusCode
            var msg:String? = response.error?.localizedDescription ?? ""
            self.errorHandle(Error: response.error as NSError?,
                             statusCode: _statusCode,
                             andErrormsg: &msg)
            
            self.setReturnValueFor(Data: response.data,
                                   withStatusCode: _statusCode,
                                   andSuccessBack: successBack,
                                   andFailureBack: failureBack,
                                   andMessage: msg)
        })
    }
    
    
    /**!
     * 文件或图片上传
     * @para strUrl String 上传地址
     * @para uploadformDataBack 上传参数设置
     * @para successBack  成功回调
     * @para failureBack  失败回调
     */
    func postImageUploadToServer(strUrl:String,
                                 uploadformDataBack:@escaping(_ fData:MultipartFormData)->(Void),
                                 AndSuccessBack successBack:@escaping SuccessBlock,
                                 AndFailureBack failureBack:@escaping FailureBlock,
                                 AndProgressBlock progressBlock: ProgressBlock?,
                                 AndRequestHeaders _headers:HTTPHeaders? = nil,
                                 WithisLoading isLoading:Bool = true){
        
        debugPrint("上传地址：\(strUrl)")
        
        if isLoading == true {
            VXIUIConfig.shareInstance.keyWindow().showHud(at: VXIUIConfig.shareInstance.appLoadInfo())
        }
        
        var nh:HTTPHeaders? = _headers
        self.requestReprocess(HttpHander: &nh)
        
        AF.upload(multipartFormData: { (_multipartFormData:MultipartFormData) in
            //指定参数
            uploadformDataBack(_multipartFormData)
        },
                  to: strUrl,
                  headers: nh,
                  requestModifier: { $0.timeoutInterval = VXIUIConfig.shareInstance.appRequestTimeOut() })
        .responseDecodable(of: DecodableType.self, completionHandler: { response in
            if isLoading == true {
                SVProgressHUD.dismiss()
            }
            
            if response.error == nil {
                debugPrint("上传结果：\(response)")
                
                let _statusCode:Int? = response.response?.statusCode
                var msg:String? = response.error?.localizedDescription ?? ""
                self.errorHandle(Error: response.error as NSError?,
                                 statusCode: _statusCode,
                                 andErrormsg: &msg)
                
                self.setReturnValueFor(Data: response.data,
                                       withStatusCode: _statusCode,
                                       andSuccessBack: successBack,
                                       andFailureBack: failureBack,
                                       andMessage: msg)
            }
            else {
                var msg:String? = response.error?.localizedDescription ?? "上传异常"
                self.errorHandle(Error: response.error as NSError?,
                                 statusCode: response.response?.statusCode,
                                 andErrormsg: &msg)
                
                failureBack(msg)
            }
        })
        .uploadProgress { progress in
            debugPrint("upload Progress: \(progress.fractionCompleted)")
            progressBlock?(progress.fractionCompleted)
        }
        .validate()
    }
    
    
    /// 文件下载
    /// - Parameters:
    ///   - strUrl: String
    ///   - successBack: successBack description
    ///   - failureBack: failureBack description
    ///   - isLoading: isLoading description
    func downloadFileForServer(strUrl:String,
                               AndSuccessBack successBack:@escaping SuccessBlock,
                               AndFailureBack failureBack:@escaping FailureBlock,
                               AndProgressBlock progressBlock:ProgressBlock?,
                               WithisLoading isLoading:Bool = true){
        print("下载地址：\(strUrl)")
        
        if isLoading == true {
            VXIUIConfig.shareInstance.keyWindow().showHud(at: VXIUIConfig.shareInstance.appLoadInfo())
        }
        
        AF.download(strUrl,
                    requestModifier: { $0.timeoutInterval = VXIUIConfig.shareInstance.appRequestTimeOut() })
        .responseData{ _response in
            if isLoading == true {
                SVProgressHUD.dismiss()
            }
            
            if _response.error == nil {
                debugPrint(_response.error?.localizedDescription ?? "--")
                successBack(_response.value)
            }
            else {
                var msg:String? = _response.error?.localizedDescription ?? "下载异常"
                self.errorHandle(Error: _response.error as NSError?,
                                 statusCode: _response.response?.statusCode,
                                 andErrormsg: &msg)
                
                failureBack(msg)
            }
        }
        .downloadProgress{ progress in
            debugPrint("Download Progress: \(progress.fractionCompleted)")
            progressBlock?(progress.fractionCompleted)
        }
        .validate()
    }
    
    
    /// 结果处理
    /// - Parameters:
    ///   - _d: Data?
    ///   - _sc: <#_sc description#>
    ///   - successBack: <#successBack description#>
    ///   - failureBack: <#failureBack description#>
    ///   - msg: <#msg description#>
    private func setReturnValueFor(Data _d:Data?,
                                   withStatusCode _sc:Int?,
                                   andSuccessBack successBack:@escaping SuccessBlock,
                                   andFailureBack failureBack:@escaping FailureBlock,
                                   andMessage msg:String?){
        
        let jsonObj:[String:Any]? = TGSUIModel.getDicDataFor(Data: _d)
        if _d != nil {
            print("请求结果：" + (String.init(data: _d!, encoding: .utf8) ?? "--"))
        }
        else{
            print("请求结果：\(String(describing: jsonObj))")
        }
        
        //请求成功
        if VXIUIConfig.shareInstance.apiIsOk(rs: _sc) {
            if jsonObj != nil {
                successBack(jsonObj)
            }
            else if let _arrTemp = TGSUIModel.getArrDataFor(Data: _d) {
                successBack(_arrTemp)
            }
            else if _d != nil{
                successBack(String.init(data: _d!, encoding: .utf8))
            }
            else{
                successBack(_d)
            }
        }
        else{
            failureBack("\(jsonObj?[VXIUIConfig.shareInstance.apiResultMessage()] ?? msg ?? "请求失败")")
        }
    }
}

