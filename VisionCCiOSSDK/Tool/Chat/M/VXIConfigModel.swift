//
//  VXIConfigModel.swift
//  VisionCCiOSSDK
//
//  Created by apple on 2024/1/30.
//

import Foundation

//MARK: - 皮肤配置字体模型
/// 皮肤配置字体模型
struct VXIThemFontsModel : Codable {
    ///聊天界面顶部的字体大小
    var cckf_title_top_text_size:CGFloat?
    ///聊天界面顶部机器人名称或坐席名称字体大小
    var cckf_tv_online_text_size:CGFloat?
    ///聊天界面顶部转人工字体大小
    var cckf_trans_user_text_size:CGFloat?
    ///聊天界面显示未读消息字体大小
    var cckf_unread_text_size:CGFloat?
    ///聊天文本消息字体大小
    var cckf_text_view_size:CGFloat?
    ///聊天问题消息字体大小
    var cckf_question_title_size:CGFloat?

    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct VXIThemFontsModel : Decodable {
        var cckf_title_top_text_size:CGFloat?
        var cckf_tv_online_text_size:CGFloat?
        var cckf_trans_user_text_size:CGFloat?
        var cckf_unread_text_size:CGFloat?
        var cckf_text_view_size:CGFloat?
        var cckf_question_title_size:CGFloat?
    }
}


//MARK: - 皮肤配置颜色模型
///皮肤配置颜色模型
struct VXIThemColorsModel : Codable {
    ///在线客服 主题色
    var cckf_online_color:String?
    ///在线客服 通用头部 背景颜色
    var cckf_online_base_header_bg_color:String?
    ///状态栏颜色
    var cckf_app_status_bar_color:String?
    ///在线客服 聊天主页面
    var cckf_chat_status_bar_color:String?
    ///文件消息气泡颜色
    var cckf_chat_file_bgColor:String?
    ///消息气泡左侧背景默认颜色
    var cckf_chat_left_bgColor:String?
    ///消息气泡右侧背景默认颜色
    var cckf_chat_right_bgColor:String?
    ///聊天页消息背景颜色
    var cckf_chat_back_all:String?
    ///聊天页底部背景颜色
    var cckf_chat_bottom_bgColor:String?
    ///文本消息气泡 左侧文字 颜色
    var cckf_left_msg_text_color:String?
    ///文本消息气泡 右侧文字 颜色
    var cckf_right_msg_text_color:String?
    ///超链接颜色 左边
    var cckf_color_link:String?
    ///超链接颜色 右边
    var cckf_color_rlink:String?
    ///聊天界面提醒背景颜色
    var cckf_chat_remind_bg:String?
    ///聊天界面提醒的字体颜色
    var cckf_chat_remind_text_color:String?
    ///聊天界面顶部的字体颜色
    var cckf_chat_title_text_color:String?

    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct VXIThemColorsModel : Decodable {
        var cckf_online_color:String?
        var cckf_online_base_header_bg_color:String?
        var cckf_app_status_bar_color:String?
        var cckf_chat_status_bar_color:String?
        var cckf_chat_file_bgColor:String?
        var cckf_chat_left_bgColor:String?
        var cckf_chat_right_bgColor:String?
        var cckf_chat_back_all:String?
        var cckf_chat_bottom_bgColor:String?
        var cckf_left_msg_text_color:String?
        var cckf_right_msg_text_color:String?
        var cckf_color_link:String?
        var cckf_color_rlink:String?
        var cckf_chat_remind_bg:String?
        var cckf_chat_remind_text_color:String?
        var cckf_chat_title_text_color:String?
    }
}
