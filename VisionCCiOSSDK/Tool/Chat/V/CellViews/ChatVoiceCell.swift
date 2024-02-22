//
//  ChatVoiceCell.swift
//  YLBaseChat
//
//  Created by yl on 17/6/5.
//  Copyright © 2017年 yl. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
@_implementationOnly import VisionCCiOSSDKEngine

/// 语音
class ChatVoiceCell: BaseChatCell {
    
    
    //MARK: - override
    override func layoutUI() {
        super.layoutUI()
        
        messagebubbleBackImageView?.addSubview(messageAnimationVoiceImageView)
        messagebubbleBackImageView?.addSubview(messageVoiceDurationLabel)
        
        self.contentView.addSubview(self.activeInfoView)
        self.contentView.addSubview(self.btnError)
        self.btnError.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            self.btnError.isHidden = true
            self.activeInfoView.isHidden = false
            self.reloadUpload(isClick: true)
        }.disposed(by: rx.disposeBag)
        
        setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        
        if self.contentView.subviews.contains(self.activeInfoView) && self.messagebubbleBackImageView != nil {
            self.activeInfoView.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.height.equalTo(16)
                make.centerY.equalTo(self.messagebubbleBackImageView!.snp.centerY)
                make.right.equalTo(self.messagebubbleBackImageView!.snp.left).offset(-6)
            }
        }
        
        if self.contentView.subviews.contains(self.btnError) && messagebubbleBackImageView != nil {
            self.btnError.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.height.equalTo(17)
                make.centerY.equalTo(self.messagebubbleBackImageView!.snp.centerY)
                make.right.equalTo(self.messagebubbleBackImageView!.snp.left).offset(-6)
            }
        }
        
        super.updateConstraints()
    }
    
    
    //MARK: 数据更新
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        
        //时长单位：毫秒
        let duration = (message?.messageBody?.duration ?? 0) / 1000
        self.messageVoiceDurationLabel.text = String.init(format: "%.f%@", duration,"\"")
        var width:CGFloat = min(VXIUIConfig.shareInstance.cellMaxWidth(), 220.5)
        if duration < 60 {//220.5 最大60秒语音长度
            let _temp_width:CGFloat = width * (CGFloat(duration) / CGFloat(60))
            width = min(_temp_width, CGFloat(56))
        }
        
        if MessageDirection.init(rawValue: m.renderMemberType ?? 0).isSend() == true {
            messageAnimationVoiceImageView.snp.remakeConstraints({ (make) in
                make.edges.equalTo(UIEdgeInsets(top: 11, left: 6, bottom: 11, right: 10))
                make.width.equalTo(width + 35)
                make.height.equalTo(13)
            })
            
            messageAnimationVoiceImageView.contentMode = UIView.ContentMode.right
            messageVoiceAnimationImageViewWithIsSendMessage(true)
            
            messageVoiceDurationLabel.snp.remakeConstraints({ (make) in
                make.centerY.equalTo(messageAnimationVoiceImageView)
                make.right.equalTo(-24)
            })
        }
        else {
            
            messageAnimationVoiceImageView.snp.remakeConstraints({ (make) in
                make.edges.equalTo(UIEdgeInsets(top: 11, left: 10, bottom: 11, right: 6))
                make.width.equalTo(width + 35)
                make.height.equalTo(13)
            })
            
            messageAnimationVoiceImageView.contentMode = UIView.ContentMode.left
            messageVoiceAnimationImageViewWithIsSendMessage(false)
            
            messageVoiceDurationLabel.snp.remakeConstraints({ (make) in
                make.centerY.equalTo(messageAnimationVoiceImageView)
                make.left.equalTo(24)
            })
        }
        
        // 加载
        self.reloadUpload()
        
        layoutIfNeeded()
    }
    
    
    //MARK: lazy load
    private lazy var messageVoiceDurationLabel:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          textColor: VXIUIConfig.shareInstance.cellMessageVoiceColor(),
                                          font: VXIUIConfig.shareInstance.cellMessageFont())
        _lab.yl_autoW()
        return _lab
    }()
    
    fileprivate(set) lazy var messageAnimationVoiceImageView:UIImageView = {[weak self] in
        let _img = TGSUIModel.createImage(rect: .zero,
                                          image: nil,
                                          backgroundColor: nil)
        _img.isUserInteractionEnabled = true
        _img.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(ChatVoiceCell.tapHandle)))
        return _img
    }()
    
    /// 发送状态
    private lazy var activeInfoView:UIActivityIndicatorView = {
        let _activityV = UIActivityIndicatorView.init()
        if #available(iOS 13.0, *) {
            _activityV.style = .medium
        } else {
            // Fallback on earlier versions
        }
        _activityV.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
        _activityV.color = UIColor.init().colorFromHexInt(hex: 0xC0C4CC)
        _activityV.backgroundColor = .clear
        _activityV.hidesWhenStopped = true
        _activityV.isHidden = true
        return _activityV
    }()
    
}


//MARK: -
extension ChatVoiceCell {
    
    fileprivate func messageVoiceAnimationImageViewWithIsSendMessage(_ isSendMessage:Bool) {
        
        var imageSepatorName = ""
        if isSendMessage {
            imageSepatorName = "ico_talk_voice_right"
        }else{
            imageSepatorName = "ico_talk_voice_left"
        }
        
        var images = [UIImage]()
        
        for i in 1...2 {
            if let image = UIImage(named: imageSepatorName + "_play_\(i)", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil) {
                images.append(image)
            }
        }
        
        messageAnimationVoiceImageView.image = UIImage(named: imageSepatorName, in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
        messageAnimationVoiceImageView.animationImages = images
        messageAnimationVoiceImageView.animationDuration = 1.0
        messageAnimationVoiceImageView.stopAnimating()
        
    }
    
    
    //MARK: 语音点击
    @objc fileprivate func tapHandle() {
        if let message = message {
            delegate?.epDidVoiceClick(message)
        }
    }
    
    
    //MARK: 发送文件
    private func reloadUpload(isClick _ic:Bool = false){
        if let _d = self.message,self.cellisFirstResponse == true || (self.cellisFirstResponse == false && _ic) {
            if MessageDirection.init(rawValue: _d.renderMemberType ?? 0).isSend() == true && (_d.mId ?? 0) <= 0 {
                if let _voicePath = _d.messageBody?.voiceLocalPath,
                   let range = _voicePath.range(of: "Caches") {
                    let _path = NSHomeDirectory() + "/Library/" + _voicePath.dropFirst(range.lowerBound.utf16Offset(in: _voicePath))
                    let _url = URL.init(fileURLWithPath: _path)
                    guard let _data = try? Data.init(contentsOf: _url) else { return }
                    
                    let _name = _url.lastPathComponent
                    VXIChatViewModel.conversationUploadFor(FileData: _data,
                                                           andFileName: _name,
                                                           andMimeType: TGSUIModel.getMimeTypeFor(FileName: _name),
                                                           withFinishblock: {[weak self] (_isOk:Bool, _info:String, _:Data,_:String) in
                        guard let self = self else { return }
                        if _isOk {
                            self.btnError.isHidden = true
                            
                            //语音上传成功，发送消息
                            var dicParams = [
                                "mediaUrl": _info as Any,
                            ]
                            
                            // 非必选 没有该值 自己获取
                            if let _duration = _d.messageBody?.duration, _duration > 0 {
                                dicParams["duration"] = _duration
                            }
                            
                            self.delegate?.epSendMessage(MessageBodyType.voice.rawValue,
                                                         _d.cMid ?? NSUUID().uuidString,
                                                         dicParams)
                        }
                        else{
                            //上传失败，重发
                            self.cellisFirstResponse = false
                            self.btnError.isHidden = false
                            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _info)
                        }
                        self.activeInfoView.stopAnimating()
                    },
                                                           andProgressBlock: {[weak self] _progress in
                        guard let self = self else { return }
                        self.activeInfoView.isHidden = false
                        self.activeInfoView.startAnimating()
                        if _progress >= 1 {
                            self.activeInfoView.stopAnimating()
                        }
                    },
                                                           andLoading: false,
                                                           andisFullPath: false)
                }
            }
        }
    }
}
