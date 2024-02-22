//
//  ChatView.swift
//  YLBaseChat
//
//  Created by yl on 17/5/18.
//  Copyright © 2017年 yl. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol ChatViewDelegate: NSObjectProtocol {
    
    func epSendMessageText(_ _text: String)
    func epSendMessageImage(_ images:[UIImage]?,_ names:[String]?)
    /// 发送自定义表情(无需上传)
    func epSendMessageFaceImage(_ _name:String,_ _mediaUrl:String)
    func ePSendMessageVoice(_ _path: String?,_ _duration: Double)
    func epSendMessageFile(_ _path:String?,_ _data:Data,_ _fileName:String,_ _fileSize:Double)
    func epSendMessageVideo(_ _localPath: String, _ _videoName: String, _ _coverImage: UIImage, _ _duration: TimeInterval, _ _imgSize: CGSize)
    func epSendMessageTextSystem(_ _text: String)
    func epSendMessageEvaluate()   //评价消息
    func epSendLeaveMessage()      //留言
}


//MARK: 聊天主视图
class ChatView: YLReplyView {
    
    weak var delegate:ChatViewDelegate?
    
}


// MARK: - 重写父类方法
extension ChatView {
    
    override func efSendMessageText(_ _text: String) {
        delegate?.epSendMessageText(_text)
    }
    
    override func efSendMessageImage(_ _images:[UIImage]?, _ names:[String]?) {
        delegate?.epSendMessageImage(_images, names)
    }
    
    override func efSendMessageVoice(_ _path: String?,_ _duration: Double) {
        delegate?.ePSendMessageVoice(_path, _duration)
    }
    
    override func efSendFaceoImage(_ _name: String, _ _mediaUrl: String) {
        delegate?.epSendMessageFaceImage(_name, _mediaUrl)
    }
    
    override func efSendMessageFile(_ _path:String?,_ _data: Data, _ _fileName: String, _ _fileSize: Double) {
        delegate?.epSendMessageFile(_path,_data, _fileName, _fileSize)
    }
    
    override func efSendMessageVideo(_ _localPath: String, _ _videoName: String, _ _coverImage: UIImage, _ _duration: TimeInterval, _ _imgSize: CGSize) {
        delegate?.epSendMessageVideo(_localPath, _videoName, _coverImage, _duration, _imgSize)
    }
    
    override func efSendMessageEvaluate() {
        delegate?.epSendMessageEvaluate()
    }
    
    override func efSendLeaveMessage() {
        delegate?.epSendLeaveMessage()
    }
}
