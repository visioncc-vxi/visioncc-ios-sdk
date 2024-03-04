//
//  GlobalCgaModel.swift
//  Tool
//
//  Created by apple on 2024/1/5.
//

import UIKit

/// 配置信息模型
public struct GlobalCgaModel : Codable {
    public var guest: GuestModel?
    public var channel:ChannelModel?
    public var shortcuts:[ShortcutsModel]?
    public var stickerPkgs:[StickerPkgsModel]? //自定义动图表情
    
    public init(guest: GuestModel? = nil, channel: ChannelModel? = nil, shortcuts: [ShortcutsModel]? = nil, stickerPkgs: [StickerPkgsModel]? = nil) {
        self.guest = guest
        self.channel = channel
        self.shortcuts = shortcuts
        self.stickerPkgs = stickerPkgs
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct GlobalCgaModel : Decodable {
        var guest: GuestModel?
        var channel:ChannelModel?
        var shortcuts:[ShortcutsModel]?
        var stickerPkgs:[StickerPkgsModel]?
    }
}

/// 坐席信息
public struct GuestModel : Codable {
    
    public var tenantId:Int?
    public var enabledGuestSensitive:Bool?
    public var enabledGlobalAvatar:Bool?
    /// 坐席图像
    public var receptionistAvatarUrl:String?
    public var receptionistTagType:Int?
    public var companyName:String?
    public var companyLogoUrl:String?
    public var enabledGuestOfflineTime:Bool?
    public var guestOfflineTime:Int?
    public var guestReplyTimeout1:Int?
    public var guestReplyTimeout2:Int?
    public var enabledGuestSwitch:Bool?
    public var enabledReceptionistStatus:Bool?
    /// 是否启用撤回功能
    public var enabledGuestWithdrawal:Bool?
    /// 撤回时效(单位：秒)
    public var messageWithdrawtime:Int?
    public var guestInputAssociate:Int?
    
    public init(tenantId: Int? = nil, enabledGuestSensitive: Bool? = nil, enabledGlobalAvatar: Bool? = nil, receptionistAvatarUrl: String? = nil, receptionistTagType: Int? = nil, companyName: String? = nil, companyLogoUrl: String? = nil, enabledGuestOfflineTime: Bool? = nil, guestOfflineTime: Int? = nil, guestReplyTimeout1: Int? = nil, guestReplyTimeout2: Int? = nil, enabledGuestSwitch: Bool? = nil, enabledReceptionistStatus: Bool? = nil, enabledGuestWithdrawal: Bool? = nil, messageWithdrawtime: Int? = nil, guestInputAssociate: Int? = nil) {
        self.tenantId = tenantId
        self.enabledGuestSensitive = enabledGuestSensitive
        self.enabledGlobalAvatar = enabledGlobalAvatar
        self.receptionistAvatarUrl = receptionistAvatarUrl
        self.receptionistTagType = receptionistTagType
        self.companyName = companyName
        self.companyLogoUrl = companyLogoUrl
        self.enabledGuestOfflineTime = enabledGuestOfflineTime
        self.guestOfflineTime = guestOfflineTime
        self.guestReplyTimeout1 = guestReplyTimeout1
        self.guestReplyTimeout2 = guestReplyTimeout2
        self.enabledGuestSwitch = enabledGuestSwitch
        self.enabledReceptionistStatus = enabledReceptionistStatus
        self.enabledGuestWithdrawal = enabledGuestWithdrawal
        self.messageWithdrawtime = messageWithdrawtime
        self.guestInputAssociate = guestInputAssociate
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct GuestModel : Decodable {
        var tenantId:Int?
        var enabledGuestSensitive:Bool?
        var enabledGlobalAvatar:Bool?
        var receptionistAvatarUrl:String?
        var receptionistTagType:Int?
        var companyName:String?
        var companyLogoUrl:String?
        var enabledGuestOfflineTime:Bool?
        var guestOfflineTime:Int?
        var guestReplyTimeout1:Int?
        var guestReplyTimeout2:Int?
        var enabledGuestSwitch:Bool?
        var enabledReceptionistStatus:Bool?
        var enabledGuestWithdrawal:Bool?
        var messageWithdrawtime:Int?
        var guestInputAssociate:Int?
    }
    
}

/// 平台信息
public struct ChannelModel : Codable {
    
    public var id:Int?
    /// 租户id
    public var tenant_id:Int?
    public var channel_id:Int?
    public var channel_app_id:Int?
    public var app_id:String?
    public var app_name:String?
    public var entry_code:String?
    public var entry_name:String?
    public var entry_skill_id:Int?
    public var enabled:Bool?
    /// 否开启常驻转人工入口（true：开启，false：关闭）
    public var enabled_entrance:Bool?
    /// 是否开启AI自动接待访客功能（true：开启，false：关闭）
    public var enabled_reception:Bool?
    public var reception_robot_id:String?
    /// 机器人名称
    public var reception_robot_name:String?
    /// 接待访客机器人图像
    public var reception_robot_avatar_url:String?
    public var reception_robot_skill_id:Int?
    public var enabled_assistant:Bool?
    public var assistant_robot_id:String?
    public var assistant_robot_name:String?
    public var assistant_robot_skill_id:Int?
    public var entry_id:Int?
    public var deploy_info:String?
    public  var docking_mode:Int?
    public  var reception_ability:Int?
    public var voice_provider:Int?
    public var voice_app_id:String?
    public var auto_open_voice:Bool?
    public var video_provider:Int?
    public var video_app_id:String?
    public var auto_open_video:Bool?
    
    public init(id: Int? = nil, tenant_id: Int? = nil, channel_id: Int? = nil, channel_app_id: Int? = nil, app_id: String? = nil, app_name: String? = nil, entry_code: String? = nil, entry_name: String? = nil, entry_skill_id: Int? = nil, enabled: Bool? = nil, enabled_entrance: Bool? = nil, enabled_reception: Bool? = nil, reception_robot_id: String? = nil, reception_robot_name: String? = nil, reception_robot_avatar_url: String? = nil, reception_robot_skill_id: Int? = nil, enabled_assistant: Bool? = nil, assistant_robot_id: String? = nil, assistant_robot_name: String? = nil, assistant_robot_skill_id: Int? = nil, entry_id: Int? = nil, deploy_info: String? = nil, docking_mode: Int? = nil, reception_ability: Int? = nil, voice_provider: Int? = nil, voice_app_id: String? = nil, auto_open_voice: Bool? = nil, video_provider: Int? = nil, video_app_id: String? = nil, auto_open_video: Bool? = nil) {
        self.id = id
        self.tenant_id = tenant_id
        self.channel_id = channel_id
        self.channel_app_id = channel_app_id
        self.app_id = app_id
        self.app_name = app_name
        self.entry_code = entry_code
        self.entry_name = entry_name
        self.entry_skill_id = entry_skill_id
        self.enabled = enabled
        self.enabled_entrance = enabled_entrance
        self.enabled_reception = enabled_reception
        self.reception_robot_id = reception_robot_id
        self.reception_robot_name = reception_robot_name
        self.reception_robot_avatar_url = reception_robot_avatar_url
        self.reception_robot_skill_id = reception_robot_skill_id
        self.enabled_assistant = enabled_assistant
        self.assistant_robot_id = assistant_robot_id
        self.assistant_robot_name = assistant_robot_name
        self.assistant_robot_skill_id = assistant_robot_skill_id
        self.entry_id = entry_id
        self.deploy_info = deploy_info
        self.docking_mode = docking_mode
        self.reception_ability = reception_ability
        self.voice_provider = voice_provider
        self.voice_app_id = voice_app_id
        self.auto_open_voice = auto_open_voice
        self.video_provider = video_provider
        self.video_app_id = video_app_id
        self.auto_open_video = auto_open_video
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct ChannelModel : Decodable {
        var id:Int?
        var tenant_id:Int?
        var channel_id:Int?
        var channel_app_id:Int?
        var app_id:String?
        var app_name:String?
        var entry_code:String?
        var entry_name:String?
        var entry_skill_id:Int?
        var enabled:Bool?
        var enabled_entrance:Bool?
        var enabled_reception:Bool?
        var reception_robot_id:String?
        var reception_robot_name:String?
        var reception_robot_avatar_url:String?
        var reception_robot_skill_id:Int?
        var enabled_assistant:Bool?
        var assistant_robot_id:String?
        var assistant_robot_name:String?
        var assistant_robot_skill_id:Int?
        var entry_id:Int?
        var deploy_info:String?
        var docking_mode:Int?
        var reception_ability:Int?
        var voice_provider:Int?
        var voice_app_id:String?
        var auto_open_voice:Bool?
        var video_provider:Int?
        var video_app_id:String?
        var auto_open_video:Bool?
    }
}

/// 快捷语
public struct ShortcutsModel : Codable {
    /// 快捷语名称
    public var title:String?
    /// 快捷语类型  1:发送消息；2:打开Url；3:调用接口 4: 内部处理，5：传递上层应用
    public var shortcutType:Int?
    /// 快捷语命令
    public var command:String?
    
    public init(title: String? = nil, shortcutType: Int? = nil, command: String? = nil) {
        self.title = title
        self.shortcutType = shortcutType
        self.command = command
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct ShortcutsModel : Decodable {
        var title:String?
        var shortcutType:Int?
        var command:String?
    }
}

/// 自定义表情
public struct StickerPkgsModel: Codable {
    
    public var groupId:Int
    /// 组名
    public var title:String?
    /// 组图标相对地址
    public var icon:String?
    public var sort:Int?
    /// 所属表情集合
    public var stickers: [StickersModel]?
    
    public init(groupId: Int, title: String? = nil, icon: String? = nil, sort: Int? = nil, stickers: [StickersModel]? = nil) {
        self.groupId = groupId
        self.title = title
        self.icon = icon
        self.sort = sort
        self.stickers = stickers
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct StickerPkgsModel : Decodable {
        var groupId:Int
        var title:String?
        var icon:String?
        var sort:Int?
        var stickers: [StickersModel]?
    }
}


public struct StickersModel : Codable {
    public var stickerId:Int?
    public var groupId:Int?
    /// 表情名称
    public var title:String?
    ///表情相对地址
    public var path:String?
    public var sort:Int
    
    public init(stickerId: Int? = nil, groupId: Int? = nil, title: String? = nil, path: String? = nil, sort: Int) {
        self.stickerId = stickerId
        self.groupId = groupId
        self.title = title
        self.path = path
        self.sort = sort
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct StickersModel : Decodable {
        var stickerId:Int?
        var groupId:Int?
        var title:String?
        var path:String?
        var sort:Int
    }
}
