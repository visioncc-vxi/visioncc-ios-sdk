//
//  EvaluatModel.swift
//  Tool
//
//  Created by apple on 2024/1/18.
//

import Foundation


//MARK: - 满意度
/// 满意度配置信息模型
struct EvaluatModel : Codable {
    /// 满意度模板标识id
    var stfTemplateId:Int64?
    /// 租户id
    var tenantId:Int?
    /// 标题文案
    var titleWord:String?
    /// 评价感谢文案
    var appreciateWord:String?
    /// 当前模板对应的满意度评价有效期，0表示不限制时效，单位：分钟
    var validPeriod:Int?
    /// 限制会话多少分钟后才能进行满意度评价(分钟)
    var limitSessionTime:Int?
    /// 是否启用评价结果客服可见
    var enableReceptionistVisible:Bool?
    /// 是否启用座席邀请访客评价即座席端主动推送
    var enableReceptionistInvitation:Bool?
    /// 是否启用访客主动评价
    var enableGuestActiveEvaluate:Bool?
    /// 是否启用系统自动推送评价
    var enableSystemAutoPush:Bool?
    var icon:String?
    var description:String?
    /// 渠道类型标识id（冗余，-1为默认设置）
    var channelId:Int?
    /// 与渠道入口配置信息表id关联（-1为默认设置）
    var entryConfigId:Int?
    /// 样式模板（1:默认模板,2:自定义模板）
    var styleTemplateType:Int?
    /// 评价模式 1-5级满意度
    var pattern:Int?
    var enabledPopup:Bool?
    var enabledResolved:Bool?
    /// 样式类型（ 1：浮沉窗口，2：消息气泡，3：自定义页面，4：回复数字评价）
    var styleType:Int?
    var enableBetterScore:Bool?
    var enableLabels:Bool?
    var enableMultiLabels:Bool?
    /// 自定义页面url地址
    var customPageUrl:String?
    var createTime:Double?
    var enableMultiOptions:Bool?
    var options: [EvaluatOptionsModel]?
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct EvaluatModel : Decodable {
        var stfTemplateId:Int64?
        var tenantId:Int?
        var titleWord:String?
        var appreciateWord:String?
        var validPeriod:Int?
        var limitSessionTime:Int?
        var enableReceptionistVisible:Bool?
        var enableReceptionistInvitation:Bool?
        var enableGuestActiveEvaluate:Bool?
        var enableSystemAutoPush:Bool?
        var icon:String?
        var description:String?
        var channelId:Int?
        var entryConfigId:Int?
        var styleTemplateType:Int?
        var pattern:Int?
        var enabledPopup:Bool?
        var enabledResolved:Bool?
        var styleType:Int?
        var enableBetterScore:Bool?
        var enableLabels:Bool?
        var enableMultiLabels:Bool?
        var customPageUrl:String?
        var createTime:Double?
        var enableMultiOptions:Bool?
        var options: [EvaluatOptionsModel]?
    }
}

/// 对应评分标签
public struct EvaluatLabelModel : Codable {
    var stfLabelsId:Int64?
    var stfOptionsId:Int64?
    /// 标签名称
    var labelsName:String?
    var labelsValue:String?
    var sort:Int?
    
    public init(stfLabelsId: Int64? = nil, stfOptionsId: Int64? = nil, labelsName: String? = nil, labelsValue: String? = nil, sort: Int? = nil) {
        self.stfLabelsId = stfLabelsId
        self.stfOptionsId = stfOptionsId
        self.labelsName = labelsName
        self.labelsValue = labelsValue
        self.sort = sort
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct EvaluatLabelModel : Decodable {
        var stfLabelsId:Int64?
        var stfOptionsId:Int64?
        var labelsName:String?
        var labelsValue:String?
        var sort:Int?
    }
}

/// 平分选项
public struct EvaluatOptionsModel : Codable {
    var stfOptionsId:Int64?
    /// 评价模式 1-5
    var pattern:Int?
    var sort:Int?
    /// 标签是否必选（0：否，1：是）
    var tagRequired:Bool?
    /// 备注是否必填（0：否，1：是）
    var remarkRequired:Bool?
    /// 当前选项的名称
    var optionsName:String?
    /// 当前选项的分值
    var optionsScore:Int?
    /// 当前选项的icon
    var optionsIcon:String?
    var labels:[EvaluatLabelModel]?
    
    public init(stfOptionsId: Int64? = nil, pattern: Int? = nil, sort: Int? = nil, tagRequired: Bool? = nil, remarkRequired: Bool? = nil, optionsName: String? = nil, optionsScore: Int? = nil, optionsIcon: String? = nil, labels: [EvaluatLabelModel]? = nil) {
        self.stfOptionsId = stfOptionsId
        self.pattern = pattern
        self.sort = sort
        self.tagRequired = tagRequired
        self.remarkRequired = remarkRequired
        self.optionsName = optionsName
        self.optionsScore = optionsScore
        self.optionsIcon = optionsIcon
        self.labels = labels
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct EvaluatOptionsModel : Decodable {
        var stfOptionsId:Int64?
        var pattern:Int?
        var sort:Int?
        var tagRequired:Bool?
        var remarkRequired:Bool?
        var optionsName:String?
        var optionsScore:Int?
        var optionsIcon:String?
        var labels:[EvaluatLabelModel]?
    }
}

//MARK: 回显集
/// 评价过后回显的模型
public struct EvaluatResultModel : Codable {
    var main:EvaluatResultMainModel?
    var options:[EvaluatResultOptionsModel]?
    
    public init(main: EvaluatResultMainModel? = nil, options: [EvaluatResultOptionsModel]? = nil) {
        self.main = main
        self.options = options
    }
    
    /// 防止服务端下发字段多余当前字段，而无法匹配解析
    struct EvaluatResultModel : Decodable {
        var main:EvaluatResultMainModel?
        var options:[EvaluatResultOptionsModel]?
    }
}

public struct EvaluatResultMainModel : Codable {
    /// 会话满意度标识id
    var satisfactionId:Int64?
    /// 满意度模板标识id
    var stfTemplateId:Int64?
    var sessionId:String?
    /// 满意度填写人访客标识id
    var evaluatorId:String?
    /// 坐席id
    var receptionistId:String?
    var score:Int?
    /// 满意度评价内容
    var comment:String?
    /// 满意度填写时间(时间戳：毫秒)
    var createTime:Double?
    /// 标题文案
    var titleWord:String?
    /// 评价感谢文案
    var appreciateWord:String?
    /// 评价模式 1-5级满意度
    var pattern:Int?
    /// 启用已解决
    var enableResolved:Bool?
    /// 是否越大越好
    var biggerSocreBetter:Bool?
    
    public init(satisfactionId: Int64? = nil, stfTemplateId: Int64? = nil, sessionId: String? = nil, evaluatorId: String? = nil, receptionistId: String? = nil, score: Int? = nil, comment: String? = nil, createTime: Double? = nil, titleWord: String? = nil, appreciateWord: String? = nil, pattern: Int? = nil, enableResolved: Bool? = nil, biggerSocreBetter: Bool? = nil) {
        self.satisfactionId = satisfactionId
        self.stfTemplateId = stfTemplateId
        self.sessionId = sessionId
        self.evaluatorId = evaluatorId
        self.receptionistId = receptionistId
        self.score = score
        self.comment = comment
        self.createTime = createTime
        self.titleWord = titleWord
        self.appreciateWord = appreciateWord
        self.pattern = pattern
        self.enableResolved = enableResolved
        self.biggerSocreBetter = biggerSocreBetter
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct EvaluatResultMainModel : Decodable {
        var satisfactionId:Int64?
        var stfTemplateId:Int64?
        var sessionId:String?
        var evaluatorId:String?
        var receptionistId:String?
        var score:Int?
        var comment:String?
        var createTime:Double?
        var titleWord:String?
        var appreciateWord:String?
        var pattern:Int?
        var enableResolved:Bool?
        var biggerSocreBetter:Bool?
    }
}

public struct EvaluatResultOptionsModel : Codable {
    /// 满意度设置选项id
    var stfOptionsId:Int64?
    var choosedValues:[String]?
    var choosedNames:[String]?
    var sort:Int?
    /// 满意度模板配置的选项是否必选
    var tagRequired:Bool?
    var remarkRequired:Bool?
    var optionsName:String?
    var optionsScore:Int?
    var optionsIcon:String?
    
    public init(stfOptionsId: Int64? = nil, choosedValues: [String]? = nil, choosedNames: [String]? = nil, sort: Int? = nil, tagRequired: Bool? = nil, remarkRequired: Bool? = nil, optionsName: String? = nil, optionsScore: Int? = nil, optionsIcon: String? = nil) {
        self.stfOptionsId = stfOptionsId
        self.choosedValues = choosedValues
        self.choosedNames = choosedNames
        self.sort = sort
        self.tagRequired = tagRequired
        self.remarkRequired = remarkRequired
        self.optionsName = optionsName
        self.optionsScore = optionsScore
        self.optionsIcon = optionsIcon
    }
    
    ///防止服务端下发字段多余当前字段，而无法匹配解析
    struct EvaluatResultOptionsModel : Decodable {
        var stfOptionsId:Int64?
        var choosedValues:[String]?
        var choosedNames:[String]?
        var sort:Int?
        var tagRequired:Bool?
        var remarkRequired:Bool?
        var optionsName:String?
        var optionsScore:Int?
        var optionsIcon:String?
    }
}
