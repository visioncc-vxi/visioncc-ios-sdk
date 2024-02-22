//
//  ChatProductCell.swift
//  Tool
//
//  Created by CQP-MacPro on 2023/12/27.
//

import UIKit
import SnapKit
@_implementationOnly import VisionCCiOSSDKEngine

///商品链接
class ChatProductCell: BaseChatCell {
    
    /// 点击打开商品(绝对地址)
    public var clickCellBlock:((_ _link_Url:String?)->())?
    
    private lazy var _linkUrl:String? = nil
    private lazy var productView : ChatProductView = ChatProductView()
    
    override func layoutUI() {
        super.layoutUI()
        contentView.addSubview(self.productView)
        
        let click = UITapGestureRecognizer()
        click.rx.event.asObservable().subscribe(onNext: { [weak self]recognizer in
            guard let self = self else { return }
            self.clickCellBlock?(self._linkUrl)
        }).disposed(by: rx.disposeBag)
        
        productView.addGestureRecognizer(click)
        productView.isUserInteractionEnabled = true
        
        //长按事件
        weak var weakSelf = self
        let _longPress = UILongPressGestureRecognizer.init(target: weakSelf, action: #selector(bassCellLongPressAction(sender:)))
        self.productView.addGestureRecognizer(_longPress)
        
        layoutIfNeeded()
    }
    
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        isNeedBubbleBackground = false
        messagebubbleBackImageView?.isHidden = true
        messageUserNameLabel.isHidden = true
        
        //更新数据
        self._linkUrl = self.productView.updateDataFor(Data: m)
        
        productView.snp.remakeConstraints({[weak self] (make) in
            guard let self = self else { return }
            make.top.equalTo(messageAvatarsImageView)
            if MessageDirection.init(rawValue: m.renderMemberType ?? 0).isSend() {
                make.right.equalTo(messageAvatarsImageView.snp.left).offset(-VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
            }
            else{
                make.left.equalTo(messageAvatarsImageView.snp.right).offset(VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
            }
            make.width.equalTo(VXIUIConfig.shareInstance.cellMaxWidth())
            make.height.equalTo(180)
            make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
        })
        
        layoutIfNeeded()
    }
    
}


//MARK: - ChatProductView
///商品链接View
class ChatProductView: UIView {
    
    private let cell_image_size:CGSize = .init(width: 201, height: 94.5)
    
    //MARK: - override
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateDataFor(Data _d:MessageModel) -> String? {
        if _d.mType == MessageBodyType.link.rawValue {
            let _linkUrl = _d.messageBody?.linkUrl
            if let _url = _d.messageBody?.imageUrl,_url.isEmpty == false,
               let _newUrl = URL.init(string: TGSUIModel.getFileRealUrlFor(Path: _url, andisThumbnail: true)) {
                
                self.showIV.yy_setImage(with: _newUrl,
                                        placeholder: VXIUIConfig.shareInstance.cellDefaultImage(),
                                        options: VXIUIConfig.shareInstance.requestOption()) { [weak self] (_img:UIImage?, _:URL, _:YYWebImageFromType, _:YYWebImageStage, _error:Error?) in
                    guard let self = self else { return }
                    let _tBlock = { [weak self] in
                        guard let self = self else { return }
                        if let _image = _img{
                            self.showIV.image = _image.yy_imageByResize(to: cell_image_size, contentMode: VXIUIConfig.shareInstance.cellImageContentMode())
                        }
                    }
                    
                    if Thread.current.isMainThread {
                        _tBlock()
                    }
                    else{
                        DispatchQueue.main.async {
                            _tBlock()
                        }
                    }
                }
            }
            
            priceLabel.text = nil //价格无
            productLabel.text = _d.messageBody?.title
            desLabel.text = _d.messageBody?.link_description
            
            return _linkUrl
        }
        else if _d.mType == MessageBodyType.cards.rawValue {
            let _linkUrl = _d.messageBody?.cardLink
            if let _url = _d.messageBody?.cardImg,_url.isEmpty == false,
               let _newUrl = URL.init(string: TGSUIModel.getFileRealUrlFor(Path: _url, andisThumbnail: true)) {
                self.showIV.yy_setImage(with: _newUrl,
                                        placeholder: VXIUIConfig.shareInstance.cellDefaultImage(),
                                        options: VXIUIConfig.shareInstance.requestOption()) { [weak self] (_img:UIImage?, _:URL, _:YYWebImageFromType, _:YYWebImageStage, _error:Error?) in
                    guard let self = self else { return }
                    let _tBlock = { [weak self] in
                        guard let self = self else { return }
                        if let _image = _img{
                            self.showIV.image = _image.yy_imageByResize(to: cell_image_size, contentMode: VXIUIConfig.shareInstance.cellImageContentMode())
                        }
                    }
                    
                    if Thread.current.isMainThread {
                        _tBlock()
                    }
                    else{
                        DispatchQueue.main.async {
                            _tBlock()
                        }
                    }
                }
            }
            
            priceLabel.text = nil//价格无
            productLabel.text = _d.messageBody?.cardGuide
            desLabel.text = _d.messageBody?.cardDesc
            
            return _linkUrl
        }
        
        return nil
    }
    
    func setUI(){
        addSubview(self.bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    //MARK: - lazy load
    private lazy var bgView:UIView = {
        let bgView = UIView ()
        bgView.backgroundColor = UIColor.white
        bgView.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
        bgView.clipsToBounds = true
        bgView.addSubview(showIV)
        bgView.addSubview(priceLabel)
        bgView.addSubview(productLabel)
        bgView.addSubview(desLabel)
        showIV.snp.makeConstraints { make in
            make.left.top.equalTo(10)
            make.right.equalTo(-10)
            make.size.equalTo(cell_image_size)
        }
        
        priceLabel.snp.makeConstraints {[weak self] make in
            guard let self =  self else { return }
            make.left.equalTo(10)
            make.top.equalTo(showIV.snp.bottom).offset(10)
        }
        
        productLabel.snp.makeConstraints { [weak self] make in
            guard let self =  self else { return }
            make.right.equalTo(-10)
            make.left.equalTo(10)
            make.centerY.equalTo(priceLabel)
        }
        
        desLabel.snp.makeConstraints {[weak self] make in
            guard let self =  self else { return }
            make.left.equalTo(10)
            make.right.bottom.equalTo(-10)
            make.top.equalTo(priceLabel.snp.bottom).offset(10)
        }
        
        return bgView
    }()
    
    /// 商品图片
    private lazy var showIV:UIImageView = {
        let iv = TGSUIModel.createImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.lightGray
        
        return iv
    }()
    
    ///价格
    private lazy var priceLabel:YYLabel = {
        return TGSUIModel.createLable(rect: .zero,
                                      textColor: TGSUIModel.createColorHexInt(0xFF8F1F),
                                      font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular),
                                      andTextAlign: .left)
    }()
    
    /// 商品标签
    private lazy var productLabel:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                      textColor: TGSUIModel.createColorHexInt(0x9E9E9E),
                                      font: UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular),
                                      andTextAlign: .left)
        _lab.numberOfLines = 0
        return _lab
    }()
    
    /// 商品名称字段
    private lazy var desLabel:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          textColor: TGSUIModel.createColorHexInt(0x424242),
                                          font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular),
                                          andTextAlign: .left)
        _lab.numberOfLines = 0
        return _lab
    }()
}


