//
//  ConversationMessageModel.swift
//  Tool
//
//  Created by apple on 2024/1/12.
//

import Foundation


/// 会话状态
public enum SessionStatus:Int {
    /// 无效标识
    case isInvalid = 0
    /// 未接入
    case isNotAccess = 1
    /// 排队中
    case isQueuing = 2
    /// 转移中
    case isTransferring = 3
    /// 咨询中
    case isSuccess = 4
    /// 已分配
    case isAllocated = 5
    /// 已转移
    case isTransferred = 6
    /// 已超时
    case isTimeOut = 7
    /// 已完成
    case isEnded = 8
    /// 已终止
    case isTerminated = 9
    /// 已离线
    case isOffline = 10
}

/// 会话类型
public enum SessionType:Int {
    /// 黑名单会话
    case blackList = 0
    /// 系统会话
    case system = 1
    /// 机器人会话
    case ai = 2
    /// 原始在线咨询会话
    case original = 3
    /// 转移在线咨询会话
    case transfer = 4
    /// 在线咨询排队
    case queuing = 5
    /// 离线留言
    case leavingMessage = 6
    // 手动认领会话
    case claim = 7
    /// 主动邀请会话
    case invitation = 8
    /// 溢出在线咨询会话
    case overflow = 9
    /// 离线会话
    case offline = 10
    /// 企业微信归档
    case epWeChat = 11
    /// 视频聊天
    case videoChat = 12
    /// 预约会话
    case reservation = 13
}


//MARK: 排队消息模型
/// 排队消息模型
public struct GuestqueuepromptModel : Codable {
    public var isQueuing:Bool?
    public var promptWord:String?//当前正在排队中，前面等待人数 1
    public var queueNumber:Int?
    public var queueWaitTime:Int?
    
    public init(isQueuing: Bool? = nil, promptWord: String? = nil, queueNumber: Int? = nil, queueWaitTime: Int? = nil) {
        self.isQueuing = isQueuing
        self.promptWord = promptWord
        self.queueNumber = queueNumber
        self.queueWaitTime = queueWaitTime
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct GuestqueuepromptModel : Decodable {
        var isQueuing:Bool?
        var promptWord:String?
        var queueNumber:Int?
        var queueWaitTime:Int?
    }
}


//MARK: 会话状态模型
/// 会话状态模型
public struct GuestSessionModel : Codable {
    
    public var channel:Int?
    public var customerId:String?
    /// 时间戳(单位：毫秒)
    public var endTime:Double?
    public var entryId:Int64?
    public var parentId:String?
    public var receptionistId:String?
    public var receptionistName:String?
    public var satisfactionConfig:SatisfactionConfig?
    public var sessionId:String?
    public var eId:Int64?
    /**
     * 会话状态
     isInvalid = 0, // 无效标识
     isNotAccess = 1, // 未接入
     isQueuing = 2, // 排队中
     isTransferring = 3, // 转移中
     isSuccess = 4, // 咨询中
     isAllocated = 5, // 已分配
     isTransferred = 6, // 已转移
     isTimeOut = 7, // 已超时
     isEnded = 8, // 已完成
     isTerminated = 9 // 已终止
     // isOffline = 10 // 已离线
     */
    public var sessionStatus:Int?
    /**
     * 会话类型
     blackList = 0, // 黑名单会话
     system = 1, // 系统会话
     ai = 2, // 机器人会话
     original = 3, // 原始在线咨询会话
     transfer = 4, // 转移在线咨询会话
     queuing = 5, // 在线咨询排队
     leavingMessage = 6, // 离线留言
     claim = 7, // 手动认领会话
     invitation = 8, // 主动邀请会话
     overflow = 9, // 溢出在线咨询会话
     offline = 10, // 离线会话
     epWeChat = 11, // 企业微信归档
     videoChat = 12, // 视频聊天
     reservation = 13 // 预约会话
     */
    public var sessionType:Int?
    public var socketId:String?
    /// 时间戳(单位：毫秒)
    public var startTime:Double?
    public var traceId:Int64?
    
    public init(channel: Int? = nil, customerId: String? = nil, endTime: Double? = nil, entryId: Int64? = nil, parentId: String? = nil, receptionistId: String? = nil, receptionistName: String? = nil, satisfactionConfig: SatisfactionConfig? = nil, sessionId: String? = nil, eId: Int64? = nil, sessionStatus: Int? = nil, sessionType: Int? = nil, socketId: String? = nil, startTime: Double? = nil, traceId: Int64? = nil) {
        self.channel = channel
        self.customerId = customerId
        self.endTime = endTime
        self.entryId = entryId
        self.parentId = parentId
        self.receptionistId = receptionistId
        self.receptionistName = receptionistName
        self.satisfactionConfig = satisfactionConfig
        self.sessionId = sessionId
        self.eId = eId
        self.sessionStatus = sessionStatus
        self.sessionType = sessionType
        self.socketId = socketId
        self.startTime = startTime
        self.traceId = traceId
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct GuestSessionModel : Decodable {
        var channel:Int?
        var customerId:String?
        var endTime:Double? //时间戳(单位：毫秒)
        var entryId:Int64?
        var parentId:String?
        var receptionistId:String?
        var receptionistName:String?
        var satisfactionConfig:SatisfactionConfig?
        var sessionId:String?
        var eId:Int64?
        var sessionStatus:Int?
        var sessionType:Int?
        var socketId:String?
        var startTime:Double? //时间戳(单位：毫秒)
        var traceId:Int64?
    }
}

/// 满意度配置
public struct SatisfactionConfig : Codable {
    /// 是否启用访客主动评价
    var enableGuestActiveEvaluate:Bool?
    /// 样式类型 1：浮沉窗口《弹窗），2：消息气泡，3：自定义页面
    var styleType:Int?
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct SatisfactionConfig : Decodable {
        var enableGuestActiveEvaluate:Bool?
        var styleType:Int?
    }
}


//MARK: - UserMappingModel
/// 用户配置模型
public struct UserMappingModel : Codable,Equatable {
    /// 入口编号(== tenantId)
    public var identity_id:String?
    /// guestName
    public var visitor_name:String?
    public var phone:String?
    public var email:String?
    /// 客户编号
    public var deviceId:String?
    
    public init(identity_id: String? = nil, visitor_name: String? = nil, phone: String? = nil, email: String? = nil, deviceId: String? = nil) {
        self.identity_id = identity_id
        self.visitor_name = visitor_name
        self.phone = phone
        self.email = email
        self.deviceId = deviceId
    }
    
    /// 防止服务端下发字段多余当前字段，而无法匹配解析
    struct UserMappingModel : Decodable {
        var identity_id:String?
        var visitor_name:String?
        var phone:String?
        var email:String?
        var deviceId:String?
    }
    
    /// 判断两者是否相等
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.identity_id == rhs.identity_id &&
            lhs.visitor_name == rhs.visitor_name &&
            lhs.phone == rhs.phone &&
            lhs.email == rhs.email &&
            lhs.deviceId == rhs.deviceId {
            return true
        } else {
            return false
        }
    }
}
