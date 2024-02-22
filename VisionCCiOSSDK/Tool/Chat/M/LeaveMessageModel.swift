//
//  LeaveMessageModel.swift
//  Tool
//
//  Created by apple on 2024/1/22.
//

import Foundation


/// 留言默认配置模型
struct LeaveMessageModel : Codable {
    
    var templateId:Int64?
    /// 留言样式（1-表单；2-消息流；3-自定义模板；）
    var templateStyle:Int?
    /// 服务开放时间内的邀请留言文案
    var onlineTitleWord:String?
    /// 非服务开放时间内的邀请留言文案
    var offlineTitleWord:String?
    /// 留言正文框提示文案
    var contentWord:String?
    var fields:[LeaveMessageFieldsModel]?
    /// 是否启用附件（0：不启用；1：启用；）
    var enableAttachment:Bool?
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct LeaveMessageModel : Decodable {
        var templateId:Int64?
        var templateStyle:Int?
        var onlineTitleWord:String?
        var offlineTitleWord:String?
        var contentWord:String?
        var fields:[LeaveMessageFieldsModel]?
        var enableAttachment:Bool?
    }
}

struct LeaveMessageFieldsModel : Codable {
    /// 字段名
    var fieldName:String?
    ///是否必须
    var required:Bool?
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct LeaveMessageFieldsModel : Decodable {
        var fieldName:String?
        var required:Bool?
    }
}
