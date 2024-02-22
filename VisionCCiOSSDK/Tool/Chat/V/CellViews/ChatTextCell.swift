//
//  ChatTextCell.swift
//  YLBaseChat
//
//  Created by yl on 17/5/25.
//  Copyright © 2017年 yl. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
@_implementationOnly import VisionCCiOSSDKEngine

/// 文本消息
class ChatTextCell: BaseChatCell {
    
    
    //MARK: - overrdie
    override func layoutUI() {
        super.layoutUI()
        
        messagebubbleBackImageView?.addSubview(messageTextLabel)
        messageTextLabel.yl_autoW()
        
    }
    
    //MARK: - 数据绑定
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        
        let messageBody = m.messageBody
        var layout:VisionCCiOSSDKEngine.YYTextLayout!
        
        //留言成功信息
        if m.mType == MessageBodyType.cards.rawValue {
            let text = messageBody?.customItems?.first?.customCardName?.yl_conversionAttributedString(align: .left) ?? NSAttributedString.init(string: "")
            layout = VisionCCiOSSDKEngine.YYTextLayout(containerSize: CGSize.init(width: VXIUIConfig.shareInstance.cellMaxWidth(),
                                                                                  height: CGFloat.greatestFiniteMagnitude),
                                                       text: text)
        }
        else{
            print(messageBody?.content)
            let text = messageBody?.content?.yl_conversionAttributedString(align: .left) ?? NSAttributedString.init(string: "")
            layout = VisionCCiOSSDKEngine.YYTextLayout(containerSize: CGSize.init(width: VXIUIConfig.shareInstance.cellMaxWidth(),
                                                                                  height: CGFloat.greatestFiniteMagnitude),
                                                       text: text)
            print(text)
        }
        
        messageTextLabel.textLayout = layout
        
        if MessageDirection.init(rawValue: m.renderMemberType ?? 0).isSend() == true {
            //用户
            self.messageAvatarsImageView.image = VXIUIConfig.shareInstance.cellUserDefaultImage()
            
            messageTextLabel.snp.remakeConstraints({ (make) in
                make.edges.equalTo(UIEdgeInsets(top: 11, left: 10, bottom: 11, right: 10))
                make.width.lessThanOrEqualTo(VXIUIConfig.shareInstance.cellMaxWidth())
                make.height.equalTo((layout?.textBoundingSize.height)!)
            })
        }else {
            messageUserNameLabel.isHidden = true
            messageTextLabel.snp.remakeConstraints({ (make) in
                make.edges.equalTo(UIEdgeInsets(top: 11, left: 10, bottom: 11, right: 10))
                make.width.lessThanOrEqualTo(VXIUIConfig.shareInstance.cellMaxWidth())
                make.height.equalTo((layout?.textBoundingSize.height)!)
            })
        }
        
        layoutIfNeeded()
    }
    
    
    //MARK: - lazy load
    lazy var messageTextLabel:VisionCCiOSSDKEngine.YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: nil,
                                          textColor: VXIUIConfig.shareInstance.cellMessageColor(),
                                          font: VXIUIConfig.shareInstance.cellMessageFont(),
                                          andTextAlign: .left)
        _lab.numberOfLines = 0
        _lab.isUserInteractionEnabled = true
        _lab.textVerticalAlignment = .top
        _lab.tintAdjustmentMode = .automatic
        _lab.ignoreCommonProperties = true
        _lab.preferredMaxLayoutWidth = VXIUIConfig.shareInstance.cellMaxWidth()
        
        return _lab
    }()
    
    lazy var helpView:UIView = {
        let v = UIView()
        return v
    }()
}
