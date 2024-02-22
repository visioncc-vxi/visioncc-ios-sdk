//
//  ChatLikeTextCell.swift
//  Tool
//
//  Created by apple on 2024/1/12.
//


import UIKit
import SnapKit
import RxSwift
@_implementationOnly import VisionCCiOSSDKEngine

//点赞消息
class ChatLikeTextCell: ChatTextCell {
    
    private let cell_margin:CGFloat = 10
    var cellUpdateBack:((_ _indexPath:IndexPath?)->Void)?
    var submitCallback:((_ _mid:Int64,_ _isHelp:Bool,_ _content:String?,_ _index:Int?)->Void)?
    
    //MARK: - override
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func updateConstraints() {
        
        if self.messagebubbleBackImageView?.subviews.contains(self.labHL) == true {
            self.labHL.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.right.equalTo(0)
                make.bottom.equalTo(self.btnUnLike.snp.top).offset(-12.5)
                make.height.equalTo(1)
            }
        }
        
        if self.messagebubbleBackImageView?.subviews.contains(self.labSL) == true {
            self.labSL.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.equalTo(1)
                make.height.equalTo(12)
                make.right.equalTo(self.btnLike.snp.left).offset(-8)
                make.centerY.equalTo(self.btnUnLike.snp.centerY)
            }
        }
        
        super.updateConstraints()
    }
    
    override func layoutUI() {
        super.layoutUI()
        self.initView()
    }
    
    private func initView(){
        self.messagebubbleBackImageView?.addSubview(self.labHL)
        self.messagebubbleBackImageView?.addSubview(self.labSL)
        self.messagebubbleBackImageView?.addSubview(self.btnUnLike)
        self.messagebubbleBackImageView?.addSubview(self.btnLike)
        
        setNeedsUpdateConstraints()
    }
    
    
    //MARK: - 绑定数据
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        self.bindCellValue(isSelect: false)
        layoutIfNeeded()
    }
    
    override func updateMessage(_ m: MessageModel, idx: IndexPath, isSelect: Bool) {
        super.updateMessage(m, idx: idx, isSelect: isSelect)
        self.bindCellValue(isSelect: isSelect)
        layoutIfNeeded()
    }
    
    
    //MARK: - lazy load
    /// 水平线
    private lazy var labHL:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: nil,
                                          textColor: nil,
                                          font: nil,
                                          backgroundColor: VXIUIConfig.shareInstance.cellSplitColor())
        
        return _lab
    }()
    
    /// 竖线
    private lazy var labSL:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: nil,
                                          textColor: nil,
                                          font: nil,
                                          backgroundColor: VXIUIConfig.shareInstance.cellSplitColor())
        
        return _lab
    }()
    
    /// 踩
    private lazy var btnUnLike:TGSVerBtn = {[unowned self] in
        let btn = TGSVerBtn()
        btn.contentHorizontalAlignment = .right
        btn.setTitle("无帮助", for: UIControl.State.normal)
        btn.setTitleColor(.colorFromRGB(0x9E9E9E), for: .normal)
        btn.setTitleColor(.colorFromRGB(0x02C161), for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        
        btn.setTitleColor(TGSUIModel.createColorHexInt(0xBDBDBD), for: .normal)
        btn.setTitleColor(TGSUIModel.createColorHexInt(0x02C161), for: .selected)
        
        btn.setImage(UIImage(named: "cell_unlike_icon.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil), for: .normal)
        btn.setImage(UIImage(named: "cell_unlike_enable.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil), for: .selected)
        btn.setImage(UIImage(named: "cell_unlike_disable.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil), for: .disabled)
        
        btn.imagePosition(style: TGSVerBtn.RGButtonImagePosition.left, spacing: 6)
        
        btn.rx.tap.subscribe { [weak self] event in
            guard let self = self else { return }
            if self.btnUnLike.state != .disabled && self.btnUnLike.isSelected == false {
                self.btnUnLike.isSelected = !self.btnUnLike.isSelected
                self.btnLike.isEnabled = false
                self.cellUpdateBack?(self.indexPath)
            }
        }.disposed(by: rx.disposeBag)
        
        return btn
    }()
    
    /// 赞
    private lazy var btnLike:TGSVerBtn = {[unowned self] in
        let btn = TGSVerBtn()
        btn.contentHorizontalAlignment = .right
        btn.setTitle("有帮助", for: UIControl.State.normal)
        btn.setTitleColor(.colorFromRGB(0x9E9E9E), for: .normal)
        btn.setTitleColor(.colorFromRGB(0x02C161), for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        
        btn.setTitleColor(TGSUIModel.createColorHexInt(0xBDBDBD), for: .normal)
        btn.setTitleColor(TGSUIModel.createColorHexInt(0x02C161), for: .selected)
        
        btn.setImage(UIImage(named: "cell_like_icon.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil), for: .normal)
        btn.setImage(UIImage(named: "cell_like_enable.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil), for: .selected)
        btn.setImage(UIImage(named: "cell_like_disable.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil), for: .disabled)
        
        btn.imagePosition(style: TGSVerBtn.RGButtonImagePosition.left, spacing: 6)
        
        btn.rx.tap.subscribe { [weak self] event in
            guard let self = self else { return }
            if self.btnLike.state != .disabled && self.btnLike.isSelected == false {
                guard let _mid = self.message?.mId else  {
                    VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "消息编号不存在")
                    return
                }
                self.submitCallback?(_mid,true,"",self.indexPath?.row)
                
                self.btnLike.isSelected = !self.btnLike.isSelected
                self.btnUnLike.isEnabled = false
            }
        }.disposed(by: rx.disposeBag)
        
        return btn
    }()
    
    //MARK: 意见建议
    private lazy var isEnable:Bool = false {
        didSet{
            self.btnSubmit.backgroundColor = self.isEnable ? VXIUIConfig.shareInstance.getStarSelectColor() : UIColor.init().colorFromHexInt(hex: 0xF2F2F2)
            self.btnSubmit.setTitleColor(self.isEnable ? .white : UIColor.init().colorFromHexInt(hex: 0x9E9E9E), for: .normal)
        }
    }
    
    /// 提交
    private lazy var btnSubmit:UIButton = {[unowned self] in
        let _btn = TGSUIModel.createBtn(rect: .zero,
                                        strTitle: "提交评价",
                                        titleColor: .white,
                                        txtFont: UIFont.systemFont(ofSize: 18, weight: .regular),
                                        image: nil,
                                        backgroundColor: VXIUIConfig.shareInstance.getStarSelectColor())
        
        _btn.layer.cornerRadius = 4
        _btn.contentHorizontalAlignment = .center
        
        _btn.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            self.btnSubmitAction()
        }.disposed(by: rx.disposeBag)
        
        return _btn
    }()
    
    /// 文本框
    public private(set) lazy var txtView:UITextView = {[unowned self] in
        let _txt = UITextView.init(frame:.zero)
        _txt.shouldIgnoreScrollingAdjustment = true
        
        //防止向上偏移
        //_txt.inputAccessoryView = UIView.init()
        _txt.keyboardDistanceFromTextField = 60
        
        _txt.delegate = self
        _txt.isOpaque = false
        _txt.toolbarPlaceholder = "请填写您的意见和建议"
        
        _txt.textColor = UIColor.init().colorFromHexInt(hex: 0x424242)
        _txt.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        _txt.backgroundColor = UIColor.white
        
        _txt.layer.cornerRadius = 4
        _txt.layer.borderWidth = 1
        _txt.layer.borderColor = UIColor.init().colorFromHexInt(hex: 0xEBEEF5).cgColor
        
        _txt.returnKeyType = .send
        
        _txt.addSubview(self.labPlace)
        self.labPlace.snp.makeConstraints {[weak self] make in
            guard let self = self else { return }
            make.left.equalTo(cell_margin)
            make.height.equalTo(20)
            make.right.equalTo(-cell_margin)
            make.top.equalTo(5)
        }
        
        _txt.addSubview(self.labFootCount)
        self.labFootCount.snp.makeConstraints {[weak self] make in
            guard let self = self else { return }
            make.left.equalTo(cell_margin)
            make.right.equalTo(-cell_margin-6)
            make.height.equalTo(16.5)
            make.bottom.equalTo(-6)
        }
        
        return _txt
    }()
    
    private lazy var labPlace:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "请填写您的意见和建议",
                                          textColor: UIColor.init().colorFromHexInt(hex: 0xBDBDBD),
                                          font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                          andTextAlign: .left)
        
        return _lab
    }()
    
    /// 字数统计
    private lazy var labFootCount:YYLabel = {
        return TGSUIModel.createLable(rect: .zero,
                                      text: "0/\(VXIUIConfig.shareInstance.getStarMaxComment())",
                                      textColor: UIColor.init().colorFromHexInt(hex: 0xBDBDBD),
                                      font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                      andTextAlign: .right,
                                      andisdisplaysAsync: false)
    }()
}


//MARK: -
extension ChatLikeTextCell {
    
    //MARK: 数据绑定
    /// 列数据绑定
    private func bindCellValue(isSelect:Bool){
        guard let m = self.message else { return }
        IQKeyboardManager.shared.enable = isSelect
        
        if isSelect {
            if self.messagebubbleBackImageView?.subviews.contains(self.txtView) == false {
                self.messagebubbleBackImageView?.addSubview(self.txtView)
            }
            
            if self.messagebubbleBackImageView?.subviews.contains(self.btnSubmit) == false {
                self.messagebubbleBackImageView?.addSubview(self.btnSubmit)
            }
            
            self.btnUnLike.isSelected = true
            self.btnLike.isEnabled = false
            
            self.btnSubmit.snp.remakeConstraints{[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(cell_margin)
                make.right.bottom.equalTo(-cell_margin)
                make.height.equalTo(30)
                make.bottom.equalTo(-cell_margin)
            }
            
            self.txtView.snp.remakeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(cell_margin)
                make.right.equalTo(-cell_margin)
                make.height.equalTo(80)
                make.bottom.equalTo(self.btnSubmit.snp.top).offset(-cell_margin)
                make.top.equalTo(self.btnUnLike.snp.bottom).offset(cell_margin)
            }
        }
        else{
            self.txtView.removeFromSuperview()
            self.btnSubmit.removeFromSuperview()
        }
        
        //[S]赞、踩信息
        if let _arrOptions = m.messageBody?.options,_arrOptions.count > 0 {
            //赋值
            self.btnLike.setTitle(_arrOptions.first(where: { $0.id?.lowercased() == "up" })?.title ?? "有帮助", for: .normal)
            self.btnUnLike.setTitle(_arrOptions.first(where: { $0.id?.lowercased() == "down" })?.title ?? "无帮助", for: .normal)
            
            //有操作过(不可点击)
            debugPrint("optionSelected:\(m.optionSelected ?? "--")")
            if let _select_txt = m.optionSelected,_select_txt.isEmpty == false,
               let _option = _arrOptions.first(where: { $0.id?.lowercased() == _select_txt.lowercased() }) {
                
                //有帮助
                if _option.title?.trimmingCharacters(in: .whitespacesAndNewlines) == self.btnLike.titleLabel?.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    self.btnLike.isSelected = true
                    self.btnUnLike.isEnabled = false
                }
                //无帮助
                else{
                    self.btnLike.isEnabled = false
                    self.btnUnLike.isSelected = true
                }
            }
            //没有操作
            else{
                if !isSelect {
                    self.btnLike.isEnabled = true
                    self.btnUnLike.isEnabled = true
                    
                    self.btnLike.isSelected = false
                    self.btnUnLike.isSelected = false
                }
            }
        }
        //[E]
        
        //文本
        let text = m.messageBody?.content?.yl_conversionAttributedString(align: .left) ?? NSAttributedString.init(string: "")
        let layout = YYTextLayout(containerSize: CGSize.init(width: VXIUIConfig.shareInstance.cellMaxWidth(),
                                                             height: CGFloat.greatestFiniteMagnitude),
                                  text: text)
        
        self.messageTextLabel.snp.remakeConstraints{[weak self] (make) in
            guard let self = self else { return }
            make.height.equalTo(layout?.textBoundingSize.height ?? 20)
            make.width.lessThanOrEqualTo(VXIUIConfig.shareInstance.cellMaxWidth())
            make.top.left.equalTo(cell_margin)
            make.right.equalTo(-cell_margin)
            make.bottom.equalTo(self.labHL.snp.top).offset(-10)
        }
        
        if self.messagebubbleBackImageView?.subviews.contains(self.btnUnLike) == true {
            self.btnUnLike.snp.remakeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.equalTo(60)
                make.height.equalTo(16.5)
                if isSelect {
                    make.bottom.equalTo(self.txtView.snp.top).offset(-cell_margin)
                }
                else{
                    make.bottom.equalTo(-12)
                }
                make.right.equalTo(self.labSL.snp.left).offset(-cell_margin)
            }
        }
        
        if self.messagebubbleBackImageView?.subviews.contains(self.btnLike) == true {
            self.btnLike.snp.remakeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.equalTo(60)
                make.height.equalTo(16.5)
                make.centerY.equalTo(self.btnUnLike.snp.centerY)
                make.right.equalTo(-cell_margin)
            }
        }
        
    }
    
    
    //MARK: 提交
    /// 提交
    private func btnSubmitAction(){
        
        guard let _c = self.txtView.text,_c.isEmpty != true else {
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "请填写您的意见和建议")
            return
        }
        
        guard let _mid = self.message?.mId else  {
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "消息编号不存在")
            return
        }
        self.submitCallback?(_mid,false,_c,self.indexPath?.row)
    }
}


//MARK: - UITextViewDelegate
extension ChatLikeTextCell : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let length = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count
        let strLength = text.lengthOfBytes(using: String.Encoding.utf8)
        
        let _max = VXIUIConfig.shareInstance.getStarMaxComment()
        if strLength > 0 && text != "\n" && text != " " {
            self.isEnable = true
            self.labPlace.isHidden = true
        }
        else if strLength <= 0 && range.location <= 0 {
            self.isEnable = false
            self.labPlace.isHidden = false
        }
        
        //输入字符长度计算
        let _len = TGSUIModel.getCountFor(MaxLength: _max,
                                          andOriginalText: textView.text ?? "",
                                          andInputText: text,
                                          andRang: range,
                                          withPrimaryLanguage: textView.textInputMode?.primaryLanguage,
                                          andTextView: textView)
        self.labFootCount.text = "\(_len)/\(_max)"
        
        //评论max 100
        if strLength > 0 && length > _max {
            self.labFootCount.text = "\(_max)/\(_max)"
            return false
        }
        
        //发送
        if text == "\n" {
            self.btnSubmitAction()
            return false
        }
        
        return true
    }
    
}
