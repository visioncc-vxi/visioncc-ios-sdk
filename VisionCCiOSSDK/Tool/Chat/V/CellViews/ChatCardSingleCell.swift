//
//  ChatCardSingleCell.swift
//  Tool
//
//  Created by apple on 2024/1/9.
//

import UIKit
import SnapKit
import RxSwift
@_implementationOnly import VisionCCiOSSDKEngine

/// 单商品卡片列
class ChatCardSingleCell: BaseChatCell {
    
    private let cell_margin:CGFloat = 10
    private let cell_button_height:CGFloat = 29
    private let cell_ziduan_height:CGFloat = 16.5
    private let cell_image_size:CGSize = .init(width: 64, height: 64)
    
    /// 点击回调
    public var clickCellBlock:(()->Void)?
    
    //MARK: override
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
        
        if self.contentView.subviews.contains(self.parentView){
            self.parentView.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.equalTo(220.5)
                make.height.equalTo(321)
                make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                make.top.equalTo(self.messageAvatarsImageView.snp.top)
                make.right.equalTo(self.messageAvatarsImageView.snp.left).offset(-VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
            }
        }
        
        if self.parentView.subviews.contains(self.labTopTitle){
            self.labTopTitle.snp.makeConstraints { make in
                make.left.top.equalTo(cell_margin)
                make.height.equalTo(21)
                make.right.equalTo(-cell_margin)
            }
        }
        
        //MARK: 商品
        if self.parentView.subviews.contains(self.imgProduct){
            self.imgProduct.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.size.equalTo(cell_image_size)
                make.left.equalTo(cell_margin)
                make.top.equalTo(self.labTopTitle.snp.bottom).offset(10)
            }
        }
        
        if self.parentView.subviews.contains(self.labProductName){
            self.labProductName.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(self.imgProduct.snp.right).offset(6)
                make.top.equalTo(self.imgProduct.snp.top)
                make.right.equalTo(-cell_margin)
                make.height.equalTo(21)
            }
        }
        
        if self.parentView.subviews.contains(self.labProductDescription){
            self.labProductDescription.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.height.equalTo(33)
                make.top.equalTo(self.labProductName.snp.bottom).offset(6)
                make.left.equalTo(self.labProductName.snp.left)
                make.right.equalTo(self.labProductName.snp.right)
            }
        }
        
        if self.parentView.subviews.contains(self.labProductPrice){
            self.labProductPrice.snp.makeConstraints { [weak self] make in
                guard let self = self else { return }
                make.height.equalTo(cell_ziduan_height)
                make.top.equalTo(self.labProductDescription.snp.bottom).offset(6)
                make.left.equalTo(self.labProductName.snp.left)
                make.right.equalTo(self.labProductName.snp.right)
            }
        }
        
        //MARK: 字段
        if self.parentView.subviews.contains(self.lab3){
            self.lab3.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(cell_margin)
                make.right.equalTo(-cell_margin)
                make.height.equalTo(cell_ziduan_height)
                make.top.equalTo(self.labProductPrice.snp.bottom).offset(6)
            }
        }
        
        if self.parentView.subviews.contains(self.lab4){
            self.lab4.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(cell_margin)
                make.right.equalTo(-cell_margin)
                make.height.equalTo(cell_ziduan_height)
                make.top.equalTo(self.lab3.snp.bottom).offset(6)
            }
        }
        
        if self.parentView.subviews.contains(self.labHL){
            self.labHL.snp.makeConstraints { [weak self] make in
                guard let self = self else { return }
                make.left.equalTo(cell_margin)
                make.right.equalTo(-cell_margin)
                make.height.equalTo(1)
                make.top.equalTo(self.lab4.snp.bottom).offset(10)
            }
        }
        
        if self.parentView.subviews.contains(self.lab5){
            self.lab5.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(cell_margin)
                make.right.equalTo(-cell_margin)
                make.height.equalTo(cell_ziduan_height)
                make.top.equalTo(self.labHL.snp.bottom).offset(10)
            }
        }
        
        //MARK: 按钮
        if self.parentView.subviews.contains(self.btn1){
            self.btn1.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(cell_margin)
                make.right.equalTo(-cell_margin)
                make.height.equalTo(cell_button_height)
                make.top.equalTo(self.lab5.snp.bottom).offset(6)
            }
        }
        
        if self.parentView.subviews.contains(self.btn2){
            (self.btn2).snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(cell_margin)
                make.right.equalTo(-cell_margin)
                make.height.equalTo(cell_button_height)
                make.top.equalTo(self.btn1.snp.bottom).offset(6)
            }
        }
        
        if self.parentView.subviews.contains(self.btn3){
            self.btn3.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(cell_margin)
                make.right.equalTo(-cell_margin)
                make.height.equalTo(cell_button_height)
                make.top.equalTo(self.btn2.snp.bottom).offset(6)
            }
        }
        
        super.updateConstraints()
    }
    
    private func initView(){
        self.contentView.addSubview(self.parentView)
        self.parentView.addSubview(self.labTopTitle)
        
        self.parentView.addSubview(self.imgProduct)
        self.parentView.addSubview(self.labProductName)
        self.parentView.addSubview(self.labProductDescription)
        self.parentView.addSubview(self.labProductPrice)
        
        self.parentView.addSubview(self.lab3)
        self.parentView.addSubview(self.lab4)
        self.parentView.addSubview(self.labHL)
        self.parentView.addSubview(self.lab5)
        
        self.parentView.addSubview(self.btn1)
        self.parentView.addSubview(self.btn2)
        self.parentView.addSubview(self.btn3)
        
        setNeedsUpdateConstraints()
    }
    
    
    //MARK: 数据绑定
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        self.bindValueForCell()
        layoutIfNeeded()
    }
    
    
    //MARK: - lazy load
    private lazy var parentView:UIView = {[unowned self] in
        let _v = TGSUIModel.createView()
        _v.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
        
        _v.isUserInteractionEnabled = true
        let _tapGest = UITapGestureRecognizer.init(target: self, action: #selector(reviewAction(sender:)))
        _v.addGestureRecognizer(_tapGest)
        
        //长按事件
        let _longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(bassCellLongPressAction(sender:)))
        _v.addGestureRecognizer(_longPress)
        
        return _v
    }()
    
    /// 标题
    private lazy var labTopTitle:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "卡片的一级名称",
                                          textColor: .colorFromRGB(0x424242),
                                          font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                          andTextAlign: .left)
        return _lab
    }()
    
    /// 商品图
    private lazy var imgProduct:UIImageView = {
        let imgInfo = TGSUIModel.createImage(rect: .zero,
                                             image: nil,
                                             backgroundColor: VXIUIConfig.shareInstance.cellImageDefaultBackgroudColor())
        return imgInfo
    }()
    
    /// 商品名称
    private lazy var labProductName:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "卡片名称",
                                          textColor: .colorFromRGB(0x424242),
                                          font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                          andTextAlign: .left)
        return _lab
    }()
    
    /// 商品介绍
    private lazy var labProductDescription:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "卡片描述卡片描述卡片描述卡片描述卡片",
                                          textColor: .colorFromRGB(0x9E9E9E),
                                          font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                          andTextAlign: .left)
        _lab.numberOfLines = 2
        return _lab
    }()
    
    /// 商品价格
    private lazy var labProductPrice:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "￥298.00",
                                          textColor: .colorFromRGB(0xFF8F1F),
                                          font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                                          andTextAlign: .left)
        _lab.attributedText = TGSUIModel.setAttributeStringTexts(strFullText: _lab.text!,
                                                                 andFullTextFont: _lab.font,
                                                                 andFullTextColor: _lab.textColor!,
                                                                 withChangeText: ["￥",".00"],
                                                                 withChangeFont: UIFont.systemFont(ofSize: 10, weight: .semibold),
                                                                 withChangeColor: _lab.textColor!,
                                                                 isLineThrough: false)
        
        return _lab
    }()
    
    //MARK: 字段
    private lazy var lab3:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "字段名称：字段内容字段内容",
                                          textColor: .colorFromRGB(0x424242),
                                          font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                          andTextAlign: .left)
        
        _lab.attributedText = TGSUIModel.createAttributed(textString: _lab.text!,
                                                          normalFont: _lab.font,
                                                          normalColor: .colorFromRGB(0x424242),
                                                          highLightString:"字段内容字段内容",
                                                          highLightFont:_lab.font,
                                                          highLightColor: .colorFromRGB(0x9E9E9E))
        
        return _lab
    }()
    
    private lazy var lab4:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "字段名称：字段内容字段内容",
                                          textColor: .colorFromRGB(0x424242),
                                          font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                          andTextAlign: .left)
        
        _lab.attributedText = TGSUIModel.createAttributed(textString: _lab.text!,
                                                          normalFont: _lab.font,
                                                          normalColor: .colorFromRGB(0x424242),
                                                          highLightString:"字段内容字段内容",
                                                          highLightFont:_lab.font,
                                                          highLightColor: .colorFromRGB(0x9E9E9E))
        
        return _lab
    }()
    
    /// 水平线
    private lazy var labHL:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: nil,
                                          textColor: nil,
                                          font: nil,
                                          backgroundColor: VXIUIConfig.shareInstance.cellSplitColor())
        
        return _lab
    }()
    
    private lazy var lab5:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "字段名称：字段内容",
                                          textColor: .colorFromRGB(0x424242),
                                          font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                          andTextAlign: .left)
        
        _lab.attributedText = TGSUIModel.createAttributed(textString: _lab.text!,
                                                          normalFont: _lab.font,
                                                          normalColor: .colorFromRGB(0x424242),
                                                          highLightString:"字段内容",
                                                          highLightFont:_lab.font,
                                                          highLightColor: .colorFromRGB(0x9E9E9E))
        
        return _lab
    }()
    
    //MARK: 按钮
    private lazy var btn1:UIButton = {[unowned self] in
        let _btn = TGSUIModel.createBtn(rect: .zero,
                                        strTitle: "按钮",
                                        titleColor: .colorFromRGB(0x07C160),
                                        txtFont: UIFont.systemFont(ofSize: 15, weight: .regular),
                                        image: nil,
                                        borderColor: .colorFromRGB(0x07C160),
                                        cornerRadius: VXIUIConfig.shareInstance.bubbleCornerRadius(),
                                        isRadius: true,
                                        borderWidth: 0.5)
        _btn.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            debugPrint("我被点击了1")
        }.disposed(by: rx.disposeBag)
        
        return _btn
    }()
    
    private lazy var btn2:UIButton = {[unowned self] in
        let _btn = TGSUIModel.createBtn(rect: .zero,
                                        strTitle: "按钮",
                                        titleColor: .colorFromRGB(0x07C160),
                                        txtFont: UIFont.systemFont(ofSize: 15, weight: .regular),
                                        image: nil,
                                        borderColor: .colorFromRGB(0x07C160),
                                        cornerRadius: VXIUIConfig.shareInstance.bubbleCornerRadius(),
                                        isRadius: true,
                                        borderWidth: 0.5)
        _btn.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            debugPrint("我被点击了2")
        }.disposed(by: rx.disposeBag)
        
        return _btn
    }()
    
    private lazy var btn3:UIButton = {[unowned self] in
        let _btn = TGSUIModel.createBtn(rect: .zero,
                                        strTitle: "主要按钮",
                                        titleColor: .white,
                                        txtFont: UIFont.systemFont(ofSize: 15, weight: .regular),
                                        image: nil,
                                        backgroundColor: .colorFromRGB(0x07C160),
                                        borderColor: nil,
                                        cornerRadius: VXIUIConfig.shareInstance.bubbleCornerRadius(),
                                        isRadius: true,
                                        borderWidth: 0.5)
        _btn.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            debugPrint("主要按钮")
        }.disposed(by: rx.disposeBag)
        
        return _btn
    }()
}


//MARK: -
extension ChatCardSingleCell {
    
    //MARK: 点击预览
    ///点击预览
    @IBAction private func reviewAction(sender:UITapGestureRecognizer) {
        self.clickCellBlock?()
    }
    
    //MARK: 数据绑定
    /// 数据绑定
    /// - Parameter _d: <#_d description#>
    private func bindValueForCell() {
        
        
        //更新样式
        self.parentView.snp.remakeConstraints {[weak self] make in
            guard let self = self else { return }
            make.width.equalTo(220.5)
            make.height.equalTo(321)
            make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
            make.top.equalTo(self.messageAvatarsImageView.snp.top)
            if MessageDirection.init(rawValue: message?.renderMemberType ?? 0).isSend() == true {
                make.right.equalTo(self.messageAvatarsImageView.snp.left).offset(-VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
            }
            else{
                make.left.equalTo(self.messageAvatarsImageView.snp.right).offset(VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
            }
        }
        
    }
    
}
