//
//  RealmModels.swift
//  YLBaseChat
//
//  Created by yl on 17/5/9.
//  Copyright © 2017年 yl. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

/// 消息方向类型:1|2 发送(右边) 16中间 其他(接收)左边
struct MessageDirection:OptionSet {
    let rawValue: Int
    
    /// 接收
    static let receive = MessageDirection(rawValue: 1 << 0)
    /// 发送
    static let send   = MessageDirection(rawValue: 1 << 1)
    /// 中间
    static let middle = MessageDirection(rawValue: 1 << 16)
    
    /// 发送的消息
    func isSend() -> Bool {
        return self.rawValue == 1 || self.rawValue == 2
    }
    
    /// 接收的消息
    func isReceive() -> Bool {
        return !self.isSend() && !self.isMiddle()
    }
    
    /// 中间
    func isMiddle() -> Bool {
        return self.rawValue == 16
    }
}

/// 会话列表历史消息方向
enum MessageHistoryDirection:String {
    /// 新消息
    case new
    /// 历史消息
    case old
}

/// 卡片类型里面的细分分支
enum MessageCardsBranchType:String {
    /// 留言
    case leaveWordReminder
}

/// 消息已读、未读状态
enum MessageReadStatus : Int {
    /// 未知
    case unknown   = 0
    /// 已收(未读)
    case received  = 1
    /// 已读
    case read      = 2
    /// 撤回
    case revoked   = 3
    /// 发送失败
    case sendError = 4
    /// 已处理
    case processed = 5
}

/// 消息类型：1-文本、2-图片、3-语音、4-短视频、5-文件、6-链接
enum MessageBodyType : Int {
    /// 文本
    case text  = 1
    /// 图片
    case image = 2
    /// 语音
    case voice = 3
    /// 视频
    case video = 4
    /// 附件(文件)
    case annex = 5
    /// 链接
    case link  = 6
    /// 统一事件消息
    case event = 7
    /// 机器人回答
    case machineAnswer = 8
    /// 卡片消息(有多个细分分支)
    case cards = 10
    /// 满意度
    case evaluat = 11
}

/// 成员标识（0：未知，1：内部具名访客，2：外部匿名访客，4：原始坐席，8：受邀坐席，16：系统，32：机器人）
enum MessageMemberType: Int {
    /// 未知
    case unknown              = 0
    /// 内部具名访客
    case namedVisitors        = 1
    /// 外部匿名访客
    case anonymousVisitors    = 2
    /// 原始坐席
    case originalSeat         = 4
    /// 受邀坐席
    case invitedSeats         = 8
    /// 系统
    case system               = 16
    /// 机器人
    case robot                = 32
}


//MARK: - 会话模型
/// 会话模型(Realm保存到数据库需要)
class Conversation: RealmSwift.Object {
    
    @objc var conversationId = NSUUID().uuidString
    
    //let messages = List<MessageModel>()  // 用户对应的聊天消息
    
    override static func primaryKey() -> String? {
        return "conversationId"
    }
    
}

//MARK: - 消息模型
/// 主消息模型
public class MessageModel: Codable {
    /// 消息唯一标识
    public let messageUUId:String = NSUUID().uuidString
    
    /// mId:消息的服务端ID
    public var mId:Int64?
    
    /// 消息的服务端创建时间戳(单位：毫秒)
    public var createTime:Double?
    
    /// 消息的本地时间戳(单位：毫秒)
    public var timestamp:Double?
    
    /// 计算完毕格式化后的时间信息(直接显示)
    public var timeFormatInfo:String?
    
    /// 客户端编号生成消息编号(本地发送消息会添加，其它可能不存在)
    public var cMid:String?
    
    /// 消息内容类型（0-未知、1-文本、2-图片、3-语音、4-短视频、5-文件、6-链接 、7-事件、11-文本&按钮...）
    public var mType:Int?
    
    /// 消息体
    public var messageBody:MessageBody?
    /// "optionSelected":"up",评价后的结果值
    public var optionSelected:String?
    
    /// 发送消息的用户ID,如为空则是系统消息
    public var sUserId:String?
    
    /// 会话id
    public var sessionId:String?
    
    /// 消息状态标识（0-未知、1-已收、2-已读、4-已处理)
    public var mStatus:Int?
    
    /// 成员标识（0：未知，1：内部具名访客，2：外部匿名访客，4：原始坐席，8：受邀坐席，16：系统，32：机器人）
    public var memberType:Int?
    
    /// 是否包含敏感词
    public var isSensitive:Bool?
    
    /// 会话开始时间戳
    public var sessionStartTime:Double?
    
    /// 消息方向类型:1|2 发送(右边) 16中间 其他(接收)左边
    public var renderMemberType:Int?
    
    public init(mId: Int64? = nil, createTime: Double? = nil, timestamp: Double? = nil, timeFormatInfo: String? = nil, cMid: String? = nil, mType: Int? = nil, messageBody: MessageBody? = nil, optionSelected: String? = nil, sUserId: String? = nil, sessionId: String? = nil, mStatus: Int? = nil, memberType: Int? = nil, isSensitive: Bool? = nil, sessionStartTime: Double? = nil, renderMemberType: Int? = nil) {
        self.mId = mId
        self.createTime = createTime
        self.timestamp = timestamp
        self.timeFormatInfo = timeFormatInfo
        self.cMid = cMid
        self.mType = mType
        self.messageBody = messageBody
        self.optionSelected = optionSelected
        self.sUserId = sUserId
        self.sessionId = sessionId
        self.mStatus = mStatus
        self.memberType = memberType
        self.isSensitive = isSensitive
        self.sessionStartTime = sessionStartTime
        self.renderMemberType = renderMemberType
    }
    
    //    //MARK: - override
    //    /// 键映射
    //    public override class func propertiesMapping() -> [String : String] {
    //        [
    //            "messageBody":"mBody",
    //        ]
    //    }
    
    ///键值映射(不是服务端下发字段，用户自己附加的不用写在下面，否则报错闪退)
    ///https://zhuanlan.zhihu.com/p/50043306
    private enum CodingKeys:String,CodingKey {
        case mId
        case createTime
        case cMid
        case mType
        case messageBody = "mBody"
        case optionSelected
        case sUserId
        case sessionId
        case mStatus
        case memberType
        case isSensitive
        case sessionStartTime
        case renderMemberType
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    class MessageModel : Decodable {
        var mId:Int64?
        var createTime:Double?
        var cMid:String?
        var mType:Int?
        var messageBody:MessageBody?
        var optionSelected:String?
        var sUserId:String?
        var sessionId:String?
        var msgStatus:Int?
        var memberType:Int?
        var isSensitive:Bool?
        var sessionStartTime:Double?
        var renderMemberType:Int?
    }
}

//MARK: - 消息体
public class MessageBody: Codable {
    
    //[S]公用字段
    public var options:[MessageOptions]?
    /// 语音文件、视频文件、图片、文件等的服务端相对地址
    /// ex：/chat/form/1693561967515/video.mp4，/chat/form/1697685894836/record1697685894835.mp3，/chat/form/1693373141005/在线咨询文档.docx...
    public var mediaUrl:String? = nil
    
    /// 语音、视频等时长(单位：毫秒)
    public var duration:Double? = nil
    
    /// 图片、视频等尺寸信息
    public var width:Float?
    public var height:Float?
    //[E]
    
    // 文字 1(作为统一的事件消息 7 类似文本)
    public var content:String? = nil
    
    // 图片 2
    public var image:Data? = nil
    public var name:String? = nil
    
    // 语音 3
    public var voiceLocalPath:String? = nil
    
    //[S]文件(附件 5)
    public var annexLocalData:Data?   = nil
    /// 下载后本地存储路径
    public var annexLocalPath:String? = nil
    /// 文件Mime类型
    public var contentType:String? = nil
    /// 文件名称
    public var fileName:String? = nil
    /// 文件大小(单位：kb)
    public var fileSize:Double?
    //[E]
    
    //[S]视频 4
    public var videoLocalPath:String? = nil
    public var videoCoverImage:Data? = nil
    public var coverUrl:String? = nil
    public var videoName:String? = nil
    //[E]
    
    //[S]普通链接 6
    /// 绝对地址：https://vcc-master-dev.vxish.cn/portal/survey/s/JFtupkmg?iframe=true&sessionId=a865f1860da94a05811bf37cdec7a457&identityId=null
    public var linkUrl:String? = nil
    public var title:String? = nil
    /// 链接描述(* 描述和图片Url都有的时候按照卡片渲染否则按超链文字渲染)
    public var link_description:String? = ""
    /// 打开方式: 1: 新开窗口, 2: 当前页面内嵌打开
    public var openMethod:Int?
    /// 图片Url
    public var imageUrl:String? = nil
    //[E]
    
    //[S]问题列表 8
    public var question_group:[MessageQuestions]?
    public var url:String? = nil
    public var button:String? = nil
    
    ///卡片类型 1：订单卡片，2：商品卡片
    public var cardType:Int?
    /// 卡片引导语
    public var cardGuide:String? = nil
    public var cardDesc:String? = nil
    /// 卡片图片
    public var cardImg:String?
    /// 卡片跳转链接
    public var cardLink:String?
    public var customFields:[MessageCustomFields]?
    public var customItems:[MessageCustomItems]?
    public var customMenus:[MessageCustomMenus]?
    //[E]
    
    //[S]满意度消息 11
    public var titleWord:String? = nil
    public var stfTemplateId:Int64?
    /// 满意度推送类型（0：未知，1：系统自动推送，2：访客主动评价，4：坐席主动推送）
    public var pushType:Int?
    public var customPageUrl:String?
    /// 样式类型（ 1：浮沉窗口，2：消息气泡，3：自定义页面，4：回复数字评价）
    public var styleType:Int?
    public var satisfactionOptions:[EvaluatOptionsModel]?
    /// Bool 是否已评价 true 是
    public var isEvaluated:Bool?
    /// 评价时效(单位：分钟)
    public var validPeriod:Int?
    //[E]
    
    //    /// 键映射
    //    public override class func propertiesMapping() -> [String : String] {
    //        [
    //            "link_description":"description",
    //            "question_group":"group"
    //        ]
    //    }
    
    public init(options: [MessageOptions]? = nil, mediaUrl: String? = nil, duration: Double? = nil, width: Float? = nil, height: Float? = nil, content: String? = nil, image: Data? = nil, name: String? = nil, voiceLocalPath: String? = nil, annexLocalData: Data? = nil, annexLocalPath: String? = nil, contentType: String? = nil, fileName: String? = nil, fileSize: Double? = nil, videoLocalPath: String? = nil, videoCoverImage: Data? = nil, coverUrl: String? = nil, videoName: String? = nil, linkUrl: String? = nil, title: String? = nil, link_description: String? = nil, openMethod: Int? = nil, imageUrl: String? = nil, question_group: [MessageQuestions]? = nil, url: String? = nil, button: String? = nil, cardType: Int? = nil, cardGuide: String? = nil, cardDesc: String? = nil, cardImg: String? = nil, cardLink: String? = nil, customFields: [MessageCustomFields]? = nil, customItems: [MessageCustomItems]? = nil, customMenus: [MessageCustomMenus]? = nil, titleWord: String? = nil, stfTemplateId: Int64? = nil, pushType: Int? = nil, customPageUrl: String? = nil, styleType: Int? = nil, satisfactionOptions: [EvaluatOptionsModel]? = nil, isEvaluated: Bool? = nil, validPeriod: Int? = nil) {
        self.options = options
        self.mediaUrl = mediaUrl
        self.duration = duration
        self.width = width
        self.height = height
        self.content = content
        self.image = image
        self.name = name
        self.voiceLocalPath = voiceLocalPath
        self.annexLocalData = annexLocalData
        self.annexLocalPath = annexLocalPath
        self.contentType = contentType
        self.fileName = fileName
        self.fileSize = fileSize
        self.videoLocalPath = videoLocalPath
        self.videoCoverImage = videoCoverImage
        self.coverUrl = coverUrl
        self.videoName = videoName
        self.linkUrl = linkUrl
        self.title = title
        self.link_description = link_description
        self.openMethod = openMethod
        self.imageUrl = imageUrl
        self.question_group = question_group
        self.url = url
        self.button = button
        self.cardType = cardType
        self.cardGuide = cardGuide
        self.cardDesc = cardDesc
        self.cardImg = cardImg
        self.cardLink = cardLink
        self.customFields = customFields
        self.customItems = customItems
        self.customMenus = customMenus
        self.titleWord = titleWord
        self.stfTemplateId = stfTemplateId
        self.pushType = pushType
        self.customPageUrl = customPageUrl
        self.styleType = styleType
        self.satisfactionOptions = satisfactionOptions
        self.isEvaluated = isEvaluated
        self.validPeriod = validPeriod
    }
    
    ///键值映射
    ///https://zhuanlan.zhihu.com/p/50043306
    private enum CodingKeys:String,CodingKey {
        
        case options
        case mediaUrl
        case duration
        case width
        case height
        case content
        case image
        case name
        case contentType
        case fileName
        case fileSize
        case coverUrl
        case videoName
        case linkUrl
        case title
        
        case cardType
        case cardGuide
        case cardDesc
        case cardImg
        case cardLink
        case customFields
        case customItems
        case customMenus
        case link_description = "description"
        case openMethod
        case imageUrl
        case question_group = "group"
        case url
        case button
        
        case titleWord
        case stfTemplateId
        case pushType
        case styleType
        case validPeriod
        case customPageUrl
        case satisfactionOptions
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    class MessageBody : Decodable {
        var options:[MessageOptions]?
        var mediaUrl:String?
        var duration:Double?
        var width:Float?
        var height:Float?
        var content:String?
        var image:Data?
        var name:String?
        var contentType:String?
        var fileName:String?
        var fileSize:Double?
        var coverUrl:String?
        var videoName:String?
        var linkUrl:String?
        var title:String?
        var link_description:String?
        var openMethod:Int?
        var imageUrl:String?
        var question_group:[MessageQuestions]?
        var url:String?
        var button:String?
        var cardImg:String?
        var cardDesc:String?
        var cardLink:String?
        var cardType:Int?
        var cardGuide:String?
        var customItems:[MessageCustomItems]?
        var customFields:[MessageCustomFields]?
        var customMenus:[MessageCustomMenus]?
        var titleWord:String? = nil
        var stfTemplateId:Int64?
        var pushType:Int?
        var customPageUrl:String?
        var satisfactionOptions:[EvaluatOptionsModel]?
    }
}

//MARK: - Options
/// MessageOptions
/// [{"id": "up","title": "有帮助"},{"id": "down","title": "无帮"}]
public class MessageOptions : Codable {
    @objc dynamic var id:String?
    @objc dynamic var title:String?
    
    public init(id: String? = nil, title: String? = nil) {
        self.id = id
        self.title = title
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    class MessageOptions : Decodable {
        var id:String?
        var title:String?
    }
    
}

//MARK: - 问题列表 8
/// 问题集合
public class MessageQuestions : Codable {
    
    @objc dynamic var name:String?
    var items = [MessageGroupItems]()
    
    public init(name: String? = nil, items: [MessageGroupItems] = [MessageGroupItems]()) {
        self.name = name
        self.items = items
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    class MessageQuestions : Decodable {
        var name:String?
        var items:[MessageGroupItems]
    }
    
}

/// 问题项
public class MessageGroupItems : Codable {
    @objc dynamic var id:String?
    @objc dynamic var title:String?
    
    public init(id: String? = nil, title: String? = nil) {
        self.id = id
        self.title = title
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    class MessageGroupItems : Decodable {
        var id:String?
        var title:String?
    }
}

//MARK: - 卡片消息 10
/// 卡片消息
public class MessageCustomItems : Codable {
    /// 商品右边按钮(有则显示，取第一个)
    var customMenus:[MessageCustomMenus]?
    var customFields:[MessageCustomFields]?
    @objc dynamic var customCardDesc:String?
    @objc dynamic var customCardLink:String?
    @objc dynamic var customCardName:String?
    /// 卡片金额
    @objc dynamic var customCardAmount:String?
    /// 卡片缩略图
    @objc dynamic var customCardThumbnail:String?
    /// 卡片金额单位
    @objc dynamic var customCardAmountSymbol:String?
    /// 金额描述
    @objc dynamic var customCardAmountName:String?
    /// 卡片原始金额(划线价格)
    @objc dynamic var customCardOriginalAmount:String?
    
    var cellHeight:CGFloat?
    
    public init(customMenus: [MessageCustomMenus]? = nil, customFields: [MessageCustomFields]? = nil, customCardDesc: String? = nil, customCardLink: String? = nil, customCardName: String? = nil, customCardAmount: String? = nil, customCardThumbnail: String? = nil, customCardAmountSymbol: String? = nil, customCardAmountName: String? = nil, customCardOriginalAmount: String? = nil, cellHeight: CGFloat? = nil) {
        self.customMenus = customMenus
        self.customFields = customFields
        self.customCardDesc = customCardDesc
        self.customCardLink = customCardLink
        self.customCardName = customCardName
        self.customCardAmount = customCardAmount
        self.customCardThumbnail = customCardThumbnail
        self.customCardAmountSymbol = customCardAmountSymbol
        self.customCardAmountName = customCardAmountName
        self.customCardOriginalAmount = customCardOriginalAmount
        self.cellHeight = cellHeight
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    class MessageCustomItems : Decodable {
        var customMenus:[MessageCustomMenus]?
        var customFields:[MessageCustomFields]?
        var customCardDesc:String?
        var customCardLink:String?
        var customCardName:String?
        var customCardAmount:String?
        var customCardThumbnail:String?
        var customCardAmountSymbol:String?
        var customCardAmountName:String?
        var customCardOriginalAmount:String?
    }
}

/// 卡片消息菜单
/// [{\"type\":3,\"title\":\"点击这里给我留言\",\"command\":\"leaveWordReminder\",\"visible\":[\"guest\"]}]
public class MessageCustomMenus : Codable {
    ///1:打开Url 3: 内部处理，4：传递上层应用
    var type:Int?
    @objc dynamic var title:String?
    /// leaveWordReminder：发起留言
    @objc dynamic var command:String?
    var visible:[String]?
    
    public init(type: Int? = nil, title: String? = nil, command: String? = nil, visible: [String]? = nil) {
        self.type = type
        self.title = title
        self.command = command
        self.visible = visible
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    class MessageCustomMenus : Decodable {
        var type:Int?
        var title:String?
        var command:String?
        var visible:[String]?
    }
}

/// 自定义字段
public class MessageCustomFields : Codable {
    @objc dynamic var key:String?
    @objc dynamic var value:String?
    
    public init(key: String? = nil, value: String? = nil) {
        self.key = key
        self.value = value
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    class MessageCustomFields : Decodable {
        var key:String?
        var value:String?
    }
}
