//
//  VXIUrlSetting.swift
//  Tool
//
//  Created by apple on 2024/1/28.
//

import Foundation

//MARK: - 地址配置
/// 地址配置文件
struct VXIUrlSetting {
    
    static let shareInstance = VXIUrlSetting.init()
    
    /// http 域名配置
    /// https://vcc-sdk.vxish.cn
    private let host:String = {
        return UserDefaults.standard.string(forKey: VXIUIConfig.shareInstance.getHostKey()) ?? "https://vcc-sdk.vxish.cn"
    }()
    
    /// 文件域名
    let fileHost:String = {
        return (UserDefaults.standard.string(forKey: VXIUIConfig.shareInstance.getHostKey()) ?? "https://vcc-sdk.vxish.cn") + "/api/file"
    }()
    
    /// socketIO 地址
    func getSocketIOHost() -> String  {
        return "wss://vcc-sdk.vxish.cn"
    }
    
    func getSocketIOPath() -> String {
        return "/api/internalConnector"
    }
    
    /// 获取配置接口(get)
    func configGlobalCga() -> String {
        return host + "/api/chat/setting/config/global/cga/"
    }
    
    /// 用户授权接口(post)
    func accessAuthorize() -> String {
        return host + "/api/chat/outside/access/authorize"
    }
    
    /// 关闭会话(delete)
    func cloaseStockIo() -> String {
        return host + "/api/chat/outside/guest/session/close"
    }
    
    /// 创建接待会话/进入聊天(post)
    func sectionEnter() -> String {
        return host + "/api/chat/outside/guest/session/enter"
    }
    
    /// 转人工(post)
    func convertArtificial() -> String {
        return host + "/api/chat/outside/guest/session/skill/"
    }
    
    /// 发送消息(post)
    func conversationSend() -> String {
        return host + "/api/chat/outside/guest/message"
    }
    
    /// 文件上传(语音、图片、视频、附件等)
    func conversationUpload() -> String {
        return host + "/api/chat/outside/guest/file/upload"
    }
    
    /// 会话历史消息
    func conversationtHistory() -> String {
        return host + "/api/chat/outside/guest/session/messages"
    }
    
    /// 消息已读
    func messageReadFor(LastMessageId _lid:Int64) -> String {
        return host + "/api/chat/outside/guest/session/message/\(_lid)/read"
    }
    
    /// 消息撤回
    func messageRevokeFor(MessageId _mid:Int64) -> String {
        return host + "/api/chat/outside/guest/session/message/\(_mid)/revoke"
    }
    
    /// 留言默认配置信息
    func leaveMessageDefaultConfig() -> String {
        return host + "/api/chat/setting/leavewords/form"
    }
    
    /// 提交留言
    func leaveMessageSutmit() -> String {
        return host + "/api/chat/outside/leavewords"
    }
    
    /// 客户推送主动评价
    func satisfactionPush() -> String {
        return host + "/api/chat/outside/guest/session/satisfaction/push"
    }
    
    //MARK: 问题
    /// 问题点击
    func questionClick() -> String {
        return host + "/api/chat/outside/guest/session/question/"
    }
    
    ///有/无帮助点击处理
    func questionComment(MessageId _mid:Int64) -> String {
        return host + "/api/chat/outside/guest/session/message/\(_mid)/like"
    }
    
    //MARK: 满意度
    /// 默认满意度设置
    func evaluatDefaultConfig() -> String {
        return host + "/api/chat/setting/satisfaction/default"
    }
    
    /// 添加满意度反馈(提交)
    func evaluatFadeback() -> String {
        return host + "/api/chat/outside/satisfaction/feedback"
    }
    
    /// 修改满意度 评价
    func evaluateFaceback(satisfactionId:Int64) -> String {
        return host + "/api/chat/outside/satisfaction/feedback/\(satisfactionId)"
    }
    
}
