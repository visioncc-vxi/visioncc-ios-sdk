//
//  BaseChatCell.swift
//  YLBaseChat
//
//  Created by yl on 17/5/25.
//  Copyright © 2017年 yl. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
@_implementationOnly import VisionCCiOSSDKEngine

protocol BaseChatCellDelegate: NSObjectProtocol {
    func epDidVoiceClick(_ message: MessageModel)
    func epMessageRevoke(_ _messageId:Int64)
    func epSendMessage(_ _type:Int, _ _cMid:String,_ _dicPanras:[String:Any])
    func epDidImageClick(FromView fv:UIView,
                         andToView tv:UIView,
                         andMessageUUId muuid:String?,
                         andMessagecmid cmid:String?,
                         andFinishBlock fb:((_ pbv:YYPhotoBrowseView)->Void)?)
}


/// 消息列Identify
enum MessageBodyCellIdentify:String {
    case ChatTextCell
    case ChatImageCell
    case ChatVoiceCell
    case ChatMachineBaseCell
    case ChatMachineTabCell
    case ChatProductCell      //商品列
    case ChatAnnexCell        //附件列
    case ChatVideoCell        //视频列
    case ChatOrdersCell       //订单列
    case ChatCardSingleCell   //单商品卡片列
    case ChatCardMutableCell  //多商品卡片列
    case ChatLikeTextCell     //点赞消息(评价)
    case ChatEventTextCell    //统一的事件消息
    case ChatEvaluatCell      //满意度气泡消息
    case ChatLinkTableViewCell//超链
}

//MARK: 消息基类
class BaseChatCell: UITableViewCell {
    
    weak var delegate:BaseChatCellDelegate?
    
    //MARK: - override
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layoutUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 初始化
    func layoutUI() {
        //没有选中样式
        self.selectionStyle = .none
        
        // 背景色
        self.contentView.backgroundColor = VXIUIConfig.shareInstance.cellBackgroundColor()
        
        // 用户头像
        self.contentView.addSubview(self.messageAvatarsImageView)
        
        // 用户名
        self.contentView.addSubview(self.messageUserNameLabel)
        
        if isNeedBubbleBackground {
            // 气泡
            self.contentView.addSubview(self.messagebubbleBackImageView!)
        }
        
    }
    
    //MARK: lazy load
    internal lazy var isNeedBubbleBackground = true
    internal lazy var message:MessageModel? = nil
    internal lazy var indexPath:IndexPath? = nil
    /// 防止消息失败后，来回滑动多次触发发送请求
    internal lazy var cellisFirstResponse:Bool = true
    
    /// 气泡
    internal lazy var messagebubbleBackImageView:UIImageView? = {[unowned self] in
        let _img = TGSUIModel.createImage(rect: .zero,
                                          image: nil,
                                          backgroundColor: .clear,
                                          isRadius: false)
        
        _img.isUserInteractionEnabled = true
        _img.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
        
        //长按事件
        let _longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(self.bassCellLongPressAction(sender:)))
        _img.addGestureRecognizer(_longPress)
        
        return _img
    }()
    
    /// 用户名
    internal lazy var messageUserNameLabel:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: nil,
                                          textColor: UIColor.colorFromRGB(0xb9b9bb),
                                          font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                          backgroundColor: .clear,
                                          andTextAlign: .left,
                                          andisdisplaysAsync: true,
                                          andLineBreakMode: nil)
        
        _lab.isHidden = true
        return _lab
    }()
    
    /// 用户图像
    internal lazy var messageAvatarsImageView:UIImageView = {
        let _img = TGSUIModel.createImage(rect: .zero,
                                          image: nil,
                                          backgroundColor: .clear,
                                          isRadius: false)
        
        _img.layer.cornerRadius = VXIUIConfig.shareInstance.cellUserImageSize().height * 0.5
        return _img
    }()
    
    /// 消息时间
    internal lazy var messageTimeLabel:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: nil,
                                          textColor: VXIUIConfig.shareInstance.messageTimeTextColor(),
                                          font: VXIUIConfig.shareInstance.messageTimeTextFont(),
                                          backgroundColor: .clear,
                                          andTextAlign: .center,
                                          andisdisplaysAsync: true,
                                          andLineBreakMode: nil)
        
        return _lab
    }()
    
    /// 新消息
    internal lazy var messageNewLabel:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "以下是新消息",
                                          textColor: VXIUIConfig.shareInstance.messageTimeTextColor(),
                                          font: VXIUIConfig.shareInstance.messageTimeTextFont(),
                                          backgroundColor: .clear,
                                          andTextAlign: .center,
                                          andisdisplaysAsync: true,
                                          andLineBreakMode: nil)
        
        let _line = YYLabel.init(frame: .zero)
        _line.backgroundColor = .init().colorFromHexString(hex: "#BDBDBD")
        _lab.addSubview(_line)
        _line.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.height.equalTo(0.5)
            make.centerY.equalToSuperview()
        }
        
        return _lab
    }()
    
    /// 失败
    internal lazy var btnError:UIButton = {[unowned self] in
        let _img = UIImage(named: "icon_annex_error.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
        let _btn = TGSUIModel.createBtn(rect: .zero,
                                        image: nil,
                                        backgroundImage: _img)
        _btn.isHidden = true
        return _btn
    }()
    
    //MARK: 加载cell内容
    internal func updateMessage(_ m: MessageModel,idx: IndexPath) {
        message = m
        indexPath = idx
        
        //MARK: 己方
        if MessageDirection.init(rawValue: m.renderMemberType ?? 0).isSend() == true {
            
            messageAvatarsImageView.snp.remakeConstraints({[weak self] (make) in
                guard let self = self else { return }
                if self.messageTimeLabel.isHidden == false {
                    make.top.equalTo(self.messageTimeLabel.snp.bottom).offset(VXIUIConfig.shareInstance.cellTopBubbleMargin())
                }
                else{
                    make.top.equalTo(VXIUIConfig.shareInstance.cellTopBubbleMargin())
                }
                make.size.equalTo(VXIUIConfig.shareInstance.cellUserImageSize())
                make.right.equalTo(-VXIUIConfig.shareInstance.cellUserLeftOrRightMargin())
            })
            
            messageAvatarsImageView.image = VXIUIConfig.shareInstance.cellUserDefaultImage()
            
            messageUserNameLabel.snp.remakeConstraints({[weak self] (make) in
                guard let self = self else { return }
                make.top.equalTo(messageAvatarsImageView)
                make.right.equalTo(messageAvatarsImageView.snp.left).offset(-VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
            })
            
            messageUserNameLabel.isHidden = true
            
            if isNeedBubbleBackground {
                messagebubbleBackImageView?.backgroundColor = VXIUIConfig.shareInstance.bubbleOwnBackgroundcolor()
                
                messagebubbleBackImageView?.snp.remakeConstraints({[weak self] (make) in
                    guard let self = self else { return }
                    make.right.equalTo(messageAvatarsImageView.snp.left).offset(-VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
                    make.top.equalTo(messageAvatarsImageView)
                    make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                })
                
            }
            
        }
        //MARK: 对方
        else {
            messageAvatarsImageView.snp.remakeConstraints({[weak self] (make) in
                guard let self = self else { return }
                if self.messageTimeLabel.isHidden == false {
                    make.top.equalTo(self.messageTimeLabel.snp.bottom).offset(VXIUIConfig.shareInstance.cellTopBubbleMargin())
                }
                else{
                    make.top.equalTo(VXIUIConfig.shareInstance.cellTopBubbleMargin())
                }
                make.size.equalTo(VXIUIConfig.shareInstance.cellUserImageSize())
                make.left.equalTo(VXIUIConfig.shareInstance.cellUserLeftOrRightMargin())
            })
            
            /**
             1.消息的发送人=robot 使用 机器人的头像 优先使用cfg接口下的channel 里面的reception_robot_avatar_url
             2.其他使用cfg接口下的guest对象enabledGlobalAvatar和receptionistAvatarUrl
             3.都不满足 使用 默认头像
             */
            //机器人
            if m.memberType == MessageMemberType.robot.rawValue || m.sUserId == "robot" {
                VXIUIConfig.shareInstance.cellMachineImage(ImageView: self.messageAvatarsImageView,
                                                           andSize: VXIUIConfig.shareInstance.cellUserImageSize())
            }
            //坐席
            else{
                VXIUIConfig.shareInstance.cellHumanDefaultImage(ImageView: self.messageAvatarsImageView,
                                                                andSize: VXIUIConfig.shareInstance.cellUserImageSize())
            }
            
            messageUserNameLabel.snp.remakeConstraints({ (make) in
                make.top.equalTo(messageAvatarsImageView)
                make.left.equalTo(messageAvatarsImageView.snp.right).offset(VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
            })
            
            messageUserNameLabel.text = "匿名"
            messageUserNameLabel.isHidden = true
            
            if isNeedBubbleBackground {
                messagebubbleBackImageView?.backgroundColor = VXIUIConfig.shareInstance.bubbleOthersideBackgroundcolor()
                
                messagebubbleBackImageView?.snp.remakeConstraints({ (make) in
                    make.left.equalTo(messageAvatarsImageView.snp.right).offset(VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
                    make.top.equalTo(messageAvatarsImageView)
                    make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                })
            }
        }
        
        layoutIfNeeded()
    }
    
    internal func updateMessage(_ m: MessageModel,idx: IndexPath,isSelect:Bool) {
        updateMessage(m, idx: idx)
    }
}


//MARK: -
extension BaseChatCell {
    
    //MARK: 消息设置
    /// 设置消息时间
    internal func updateTime(FormatTme fTime: String?,andLastmessageId _lmid:Int64?) {
        
        //        //新消息线
        //        self.messageNewLabel.isHidden = !(self.message?.mId == _lmid)
        //        if self.messageNewLabel.isHidden == false {
        //            if !self.contentView.subviews.contains(self.messageNewLabel){
        //                self.contentView.addSubview(self.messageNewLabel)
        //            }
        //            self.messageNewLabel.snp.remakeConstraints {[weak self] make in
        //                guard let self = self else { return }
        //                make.left.equalTo(VXIUIConfig.shareInstance.cellUserLeftOrRightMargin())
        //                make.right.equalTo(-VXIUIConfig.shareInstance.cellUserLeftOrRightMargin())
        //                make.height.equalTo(16.5)
        //                make.top.equalTo(VXIUIConfig.shareInstance.cellTopBubbleMargin())
        //            }
        //        }
        
        if fTime == nil || fTime?.isEmpty == true {
            self.messageTimeLabel.isHidden = true
            self.messageAvatarsImageView.snp.remakeConstraints({[weak self] (make) in
                guard let  self = self else { return }
                if self.messageTimeLabel.isHidden == false {
                    //                    if self.messageTimeLabel.isHidden == false {
                    //                        make.top.equalTo(self.messageTimeLabel.snp.bottom).offset(VXIUIConfig.shareInstance.cellTopBubbleMargin())
                    //                    }
                    //                    else{
                    make.top.equalTo(self.messageTimeLabel.snp.bottom).offset(VXIUIConfig.shareInstance.cellTopBubbleMargin())
                    //}
                }
                else{
                    make.top.equalTo(VXIUIConfig.shareInstance.cellTopBubbleMargin())
                }
                make.size.equalTo(VXIUIConfig.shareInstance.cellUserImageSize())
                make.left.equalTo(VXIUIConfig.shareInstance.cellUserLeftOrRightMargin())
            })
        }
        else{
            /**
             * 1、当天的消息，以每5分钟为一个跨度的显示时间；格式：时分【HH:mm】
             * 2、消息超过1天、小于1周，显示星期+收发消息的时间；格式：周几 时分【周三 HH:mm】
             * 3、消息大于1周，显示手机收发时间的日期；格式：年月日 时分【yyyy-MM-dd HH:mm】
             */
            self.messageTimeLabel.isHidden = false
            self.messageTimeLabel.text = fTime
            if !self.contentView.subviews.contains(self.messageTimeLabel){
                self.contentView.addSubview(self.messageTimeLabel)
            }
            
            self.messageTimeLabel.snp.remakeConstraints { make in
                make.left.right.equalTo(0)
                make.height.equalTo(16.5)
                //                if self.messageTimeLabel.isHidden == false {
                //                    make.top.equalTo(self.messageTimeLabel.snp.bottom).offset(VXIUIConfig.shareInstance.cellTopBubbleMargin())
                //                }
                //                else{
                make.top.equalTo(VXIUIConfig.shareInstance.cellTopBubbleMargin())
                //}
            }
            
            self.messageAvatarsImageView.snp.remakeConstraints({[weak self] (make) in
                guard let  self = self else { return }
                make.top.equalTo(self.messageTimeLabel.snp.bottom).offset(VXIUIConfig.shareInstance.cellTopBubbleMargin())
                make.size.equalTo(VXIUIConfig.shareInstance.cellUserImageSize())
                make.left.equalTo(VXIUIConfig.shareInstance.cellUserLeftOrRightMargin())
            })
        }
        
    }
    
    //MARK: 长按撤回
    @IBAction func bassCellLongPressAction(sender:UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            //配置是否启用撤回(true 启用，false 未启用)
            if let _enabledGuestWithdrawal = TGSUIModel.getSystemInfoModel(key: VXIUIConfig.shareInstance.getGlobalCgaKey())?.guest?.enabledGuestWithdrawal,_enabledGuestWithdrawal == false {
                debugPrint("enabledGuestWithdrawal 配置未启用撤回")
                return
            }
            
            //是否为己方消息
            if MessageDirection(rawValue: self.message?.renderMemberType ?? 0).isSend() == false {
                debugPrint("非己方消息，不可长按撤回")
                return
            }
            
            //状态判断
            if self.message?.mStatus == MessageReadStatus.revoked.rawValue || self.message?.mStatus == MessageReadStatus.sendError.rawValue {
                debugPrint("已撤回或发送失败消息，不可长按撤回")
                return
            }
            
            //时效判断
            if let _time = self.message?.createTime ?? self.message?.timestamp,
               let _ageing = TGSUIModel.getSystemInfoModel(key: VXIUIConfig.shareInstance.getGlobalCgaKey())?.guest?.messageWithdrawtime {
                if fabs(_time - Double(TGSUIModel.localUnixTimeForInt() * 1000)) > Double(_ageing * 1000) {
                    debugPrint("消息超过时效{消息时间:\(_time)ms,时效：\(_ageing)s}，不可长按撤回")
                    return
                }
            }
            
            if let menu = RXPopMenu.menu(with: RXPopMenuBox) as? RXPopMenu {
                menu.itemHeight = VXIUIConfig.shareInstance.messageRevokeCellHeight()
                menu.titleColor = VXIUIConfig.shareInstance.messageRevokeTextColor()
                menu.backColor = VXIUIConfig.shareInstance.messageRevokeBgColor()
                menu.titleFont = VXIUIConfig.shareInstance.messageRevokeFont()
                menu.show(by: sender.view!, with: [RXPopMenuItem.itemTitle(VXIUIConfig.shareInstance.messageRevokeText(), image: VXIUIConfig.shareInstance.messageRevokeImageName()) as! RXPopMenuItem])
                
                menu.itemActions = {[weak self] (item:RXPopMenuItem?) in
                    guard let self = self else { return }
                    debugPrint(item?.title ?? "--")
                    
                    switch item?.title {
                    case .some(VXIUIConfig.shareInstance.messageRevokeText()):
                        if let _mid = self.message?.mId {
                            self.delegate?.epMessageRevoke(_mid)
                        }
                        break
                        
                    default:
                        break
                    }
                }
            }
        }
    }
}
