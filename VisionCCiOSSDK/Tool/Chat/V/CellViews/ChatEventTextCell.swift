//
//  ChatEventTextCell.swift
//  Tool
//
//  Created by apple on 2024/1/17.
//

import UIKit
import SnapKit
@_implementationOnly import VisionCCiOSSDKEngine


//MARK: - 事件消息
class ChatEventTextCell: BaseChatCell {
    
    //MARK: - override
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutUI() {
        isNeedBubbleBackground = false
        super.layoutUI()
        self.initView()
    }
    
    override func updateConstraints() {
        
        if self.contentView.subviews.contains(self.labInfo){
            self.labInfo.snp.makeConstraints { make in
                make.top.equalTo(0)
                make.left.equalTo(VXIUIConfig.shareInstance.cellUserLeftOrRightMargin())
                make.right.equalTo(-VXIUIConfig.shareInstance.cellUserLeftOrRightMargin())
                make.height.greaterThanOrEqualTo(16.5)
                make.bottom.equalTo(-VXIUIConfig.shareInstance.cellTopBubbleMargin())
            }
        }
        
        super.updateConstraints()
    }
    
    private func initView(){
        self.contentView.addSubview(self.labInfo)
        self.messageAvatarsImageView.isHidden = true
        setNeedsUpdateConstraints()
    }
    
    //MARK: - 绑定数据
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        self.labInfo.text = m.messageBody?.content
        let _h:CGFloat = (self.labInfo.text ?? "未知消息类型").yl_getLabelHeight(Font: self.labInfo.font!,
                                                                           andWidth: VXIUIConfig.shareInstance.YLScreenWidth - 2 * VXIUIConfig.shareInstance.cellUserLeftOrRightMargin()).0
        self.labInfo.snp.remakeConstraints {[weak self] make in
            guard let self = self else { return }
            if self.messageTimeLabel.isHidden == false {
                make.top.equalTo(self.messageTimeLabel.snp.bottom).offset(VXIUIConfig.shareInstance.cellTopBubbleMargin())
            }
            else{
                make.top.equalTo(VXIUIConfig.shareInstance.cellTopBubbleMargin())
            }
            make.left.equalTo(VXIUIConfig.shareInstance.cellUserLeftOrRightMargin())
            make.right.equalTo(-VXIUIConfig.shareInstance.cellUserLeftOrRightMargin())
            make.height.equalTo(max(_h, 16.5))
            make.bottom.equalTo(-VXIUIConfig.shareInstance.cellTopBubbleMargin())
        }
        layoutIfNeeded()
    }
    
    //MARK: - lazy load
    private lazy var labInfo:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "未知消息类型",
                                          textColor: .colorFromRGB(0x9E9E9E),
                                          font: VXIUIConfig.shareInstance.cellMessageFont(),
                                          andTextAlign: .center)
        _lab.numberOfLines = 0
        return _lab
    }()
}
