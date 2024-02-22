//
//  ChatLinkTableViewCell.swift
//  Tool
//
//  Created by apple on 2024/1/22.
//

import UIKit
import SnapKit
import RxSwift
@_implementationOnly import VisionCCiOSSDKEngine

/// 超链列
class ChatLinkTableViewCell: BaseChatCell {
    
    weak var viewModel:VXIChatViewModel?
    
    /// 留言消息
    var cellLeaveMessageBlock:((_ _msgId:Int64?,_ _sessionId:String?)->Void)?
    
    /// 评价消息(_styleType:样式类型（ 1：浮沉窗口，2：消息气泡，3：自定义页面，4：回复数字评价)
    var cellEvaluateMessageBlock:((_ _styleType:Int?,
                                   _ _data:[EvaluatOptionsModel]?,
                                   _ _stfTemplateId:Int64?,
                                   _ _title:String,
                                   _ _pushType:Int,
                                   _ _mid:Int64,
                                   _ _sessionId:String?)->Void)?
    
    private let cell_txt_max_width:CGFloat = VXIUIConfig.shareInstance.cellMaxWidth() - 25
    
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
        isNeedBubbleBackground = true
        super.layoutUI()
        self.initView()
        layoutIfNeeded()
    }
    
    override func updateConstraints() {
        if self.messagebubbleBackImageView?.subviews.contains(self.labInfo) == true {
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
        messagebubbleBackImageView?.addSubview(self.labInfo)
        setNeedsUpdateConstraints()
    }
    
    
    //MARK: - 数据绑定
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        self.cellBindValue()
        print("ChatLinkTableViewCell-updateMessage:\(m)")
        layoutIfNeeded()
    }
    
    //MARK: - lazy load
    private lazy var labInfo:YYLabel = {
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
        _lab.preferredMaxLayoutWidth = cell_txt_max_width
        
        _lab.rx.textTapAction.onNext {[weak self] (_:UIView, _:NSAttributedString, _:NSRange, _:CGRect) in
            guard let self = self else { return }
            if self.message?.mType == MessageBodyType.link.rawValue {
                guard let _linkUrl = self.message?.messageBody?.linkUrl,_linkUrl.isEmpty == false else {
                    VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "linkUrl 不存在，无法浏览")
                    return
                }
                //系统浏览器打开
                TGSUIModel.gotoWebViewFor(Path: _linkUrl)
            }
            //留言
            else if self.message?.mType == MessageBodyType.cards.rawValue || self.message?.mType == MessageBodyType.event.rawValue {
                self.cellLeaveMessageBlock?(self.message?.mId,self.message?.sessionId)
                
                //加载留言配置
                self.viewModel?.leaveMessageLoadConfigPublishSubject.onNext((false,true))
            }
            //评价
            else if self.message?.mType == MessageBodyType.evaluat.rawValue {
                //自定义页面直接走
                if self.message?.messageBody?.styleType == 3,
                   let _url = self.message?.messageBody?.customPageUrl,_url.isEmpty == false {
                    //                    let vc = WebDetailsViewController.init()
                    //                    vc.target = self.yy_viewController
                    //                    vc.url = TGSUIModel.getFileRealUrlFor(Path: _url, andisThumbnail: false)
                    //                    self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
                    TGSUIModel.gotoWebViewFor(Path: TGSUIModel.getFileRealUrlFor(Path: _url, andisThumbnail: false))
                }
                else{
                    if self.message?.messageBody?.isEvaluated == true {
                        debugPrint("已评价，不可再次评价")
                        return
                    }
                    //最大个数
                    let _max = self.message?.messageBody?.satisfactionOptions?.count ?? 5
                    UserDefaults.standard.setValue(_max,
                                                   forKey: VXIUIConfig.shareInstance.getEvaluatMaxStarKey())
                    
                    self.cellEvaluateMessageBlock?(self.message?.messageBody?.styleType,
                                                   self.message?.messageBody?.satisfactionOptions,
                                                   self.message?.messageBody?.stfTemplateId,
                                                   self.message?.messageBody?.titleWord ?? "评价",
                                                   self.message?.messageBody?.pushType ?? 1,
                                                   self.message?.mId ?? 0,
                                                   self.message?.sessionId)
                }
            }
        }
        
        return _lab
    }()
}



//MARK: -
extension ChatLinkTableViewCell {
    
    /// 列数据绑定
    private func cellBindValue(){
        guard let m = self.message else { return }
        
        var _link_Color:UIColor = VXIUIConfig.shareInstance.cellMessageLinkLeftColor()
        if MessageDirection(rawValue: m.renderMemberType ?? 0).isSend() {
            _link_Color = VXIUIConfig.shareInstance.cellMessageLinkRightColor()
        }
        
        var _h:CGFloat = 21
        if m.mType == MessageBodyType.link.rawValue {
            let _title:String = m.messageBody?.title ?? ""
            var _full_String = ""
            var _description:String = m.messageBody?.link_description ?? ""
            if _description.isEmpty == true {
                _description = _title
                _full_String = _title
            }
            else{
                //_full_String = String.init(format:"%@%@",_title,_description)
                _full_String = _title
            }
            
            let _attr = TGSUIModel.setAttributeStringTexts(strFullText: _full_String,
                                                           andFullTextFont: VXIUIConfig.shareInstance.cellMessageFont(),
                                                           andFullTextColor: VXIUIConfig.shareInstance.cellMessageColor(),
                                                           withChangeText: [_full_String],
                                                           withChangeFont: VXIUIConfig.shareInstance.cellMessageFont(),
                                                           withChangeColor: _link_Color)
            
            let _layout = YYTextLayout.init(containerSize: CGSize(width:cell_txt_max_width,height: CGFloat(MAXFLOAT)),text: _attr)
            self.labInfo.textLayout = _layout
            _h = max(21,_layout?.textBoundingSize.height ?? _attr.size().height)
        }
        /// 留言消息
        else if m.mType == MessageBodyType.cards.rawValue {
            let _title:String = m.messageBody?.customItems?.first?.customCardName ?? "点击留言"
            let _description:String = m.messageBody?.customItems?.first?.customMenus?.first?.title ?? ""
            
            let _attr = TGSUIModel.setAttributeStringTexts(strFullText: String.init(format:"%@\n%@",_title,_description),
                                                           andFullTextFont: VXIUIConfig.shareInstance.cellMessageFont(),
                                                           andFullTextColor: VXIUIConfig.shareInstance.cellMessageColor(),
                                                           withChangeText: [_description],
                                                           withChangeFont: VXIUIConfig.shareInstance.cellMessageFont(),
                                                           withChangeColor: _link_Color)
            let _layout = YYTextLayout.init(containerSize: CGSize(width:cell_txt_max_width,height: CGFloat(MAXFLOAT)),text: _attr)
            self.labInfo.textLayout = _layout
            _h = max(21,_layout?.textBoundingSize.height ?? _attr.size().height)
        }
        /// 留言(从7里面过来)
        else if m.mType == MessageBodyType.event.rawValue {
            let _title:String = m.messageBody?.customMenus?.first?.title ?? "点击留言"
            
            let _attr = TGSUIModel.setAttributeStringTexts(strFullText: _title,
                                                           andFullTextFont: VXIUIConfig.shareInstance.cellMessageFont(),
                                                           andFullTextColor: VXIUIConfig.shareInstance.cellMessageColor(),
                                                           withChangeText: [_title],
                                                           withChangeFont: VXIUIConfig.shareInstance.cellMessageFont(),
                                                           withChangeColor: _link_Color)
            let _layout = YYTextLayout.init(containerSize: CGSize(width:cell_txt_max_width,height: CGFloat(MAXFLOAT)),text: _attr)
            self.labInfo.textLayout = _layout
            _h = max(21,_layout?.textBoundingSize.height ?? _attr.size().height)
        }
        /// 满意度 评价
        else if m.mType == MessageBodyType.evaluat.rawValue {
            if m.messageBody?.isEvaluated == true {
                _link_Color = .colorFromRGB(0x9BC2F8)
            }
            let _full_String = m.messageBody?.titleWord ?? m.messageBody?.content ?? "点击这里给我评价"
            let _attr = TGSUIModel.setAttributeStringTexts(strFullText: _full_String,
                                                           andFullTextFont: VXIUIConfig.shareInstance.cellMessageFont(),
                                                           andFullTextColor: VXIUIConfig.shareInstance.cellMessageColor(),
                                                           withChangeText: [_full_String],
                                                           withChangeFont: VXIUIConfig.shareInstance.cellMessageFont(),
                                                           withChangeColor: _link_Color)
            let _layout = YYTextLayout.init(containerSize: CGSize(width:cell_txt_max_width,height: CGFloat(MAXFLOAT)),text: _attr)
            self.labInfo.textLayout = _layout
            _h = max(21,_layout?.textBoundingSize.height ?? _attr.size().height)
        }
        
        if MessageDirection.init(rawValue: m.renderMemberType ?? 0).isSend() == true {
            labInfo.snp.remakeConstraints({ (make) in
                make.edges.equalTo(UIEdgeInsets(top: 11, left: 10, bottom: 11, right: 15))
                make.width.lessThanOrEqualTo(VXIUIConfig.shareInstance.cellMaxWidth())
                make.height.equalTo(_h)
            })
        }else {
            messageUserNameLabel.isHidden = true
            labInfo.snp.remakeConstraints({ (make) in
                make.edges.equalTo(UIEdgeInsets(top: 11, left: 15, bottom: 11, right: 10))
                make.width.lessThanOrEqualTo(VXIUIConfig.shareInstance.cellMaxWidth())
                make.height.equalTo(_h)
            })
        }
    }
    
}
