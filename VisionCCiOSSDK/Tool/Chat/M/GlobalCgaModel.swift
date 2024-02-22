//
//  GlobalCgaModel.swift
//  Tool
//
//  Created by apple on 2024/1/5.
//

import UIKit

/// 配置信息模型
public struct GlobalCgaModel : Codable {
    var guest: GuestModel?
    var channel:ChannelModel?
    var shortcuts:[ShortcutsModel]?
    var stickerPkgs:[StickerPkgsModel]? //自定义动图表情
    
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
    
    var tenantId:Int?
    var enabledGuestSensitive:Bool?
    var enabledGlobalAvatar:Bool?
    ///坐席图像
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
    /// 是否启用撤回功能
    var enabledGuestWithdrawal:Bool?
    /// 撤回时效(单位：秒)
    var messageWithdrawtime:Int?
    var guestInputAssociate:Int?
    
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
    
    var id:Int?
    /// 租户id
    var tenant_id:Int?
    var channel_id:Int?
    var channel_app_id:Int?
    var app_id:String?
    var app_name:String?
    var entry_code:String?
    var entry_name:String?
    var entry_skill_id:Int?
    var enabled:Bool?
    /// 否开启常驻转人工入口（true：开启，false：关闭）
    var enabled_entrance:Bool?
    /// 是否开启AI自动接待访客功能（true：开启，false：关闭）
    var enabled_reception:Bool?
    var reception_robot_id:String?
    /// 机器人名称
    var reception_robot_name:String?
    /// 接待访客机器人图像
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
    var title:String?
    /// 快捷语类型  1:发送消息；2:打开Url；3:调用接口 4: 内部处理，5：传递上层应用
    var shortcutType:Int?
    /// 快捷语命令
    var command:String?
    
    init(title: String? = nil, shortcutType: Int? = nil, command: String? = nil) {
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
    
    var groupId:Int
    /// 组名
    var title:String?
    /// 组图标相对地址
    var icon:String?
    var sort:Int?
    /// 所属表情集合
    var stickers: [StickersModel]?
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct StickerPkgsModel : Decodable {
        var groupId:Int
        var title:String?
        var icon:String?
        var sort:Int?
        var stickers: [StickersModel]?
    }
}


struct StickersModel : Codable {
    var stickerId:Int?
    var groupId:Int?
    /// 表情名称
    var title:String?
    ///表情相对地址
    var path:String?
    var sort:Int
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct StickersModel : Decodable {
        var stickerId:Int?
        var groupId:Int?
        var title:String?
        var path:String?
        var sort:Int
    }
}
