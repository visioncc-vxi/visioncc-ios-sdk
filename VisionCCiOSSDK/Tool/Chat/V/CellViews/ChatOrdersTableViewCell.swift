//
//  ChatOrdersTableViewCell.swift
//  Tool
//
//  Created by apple on 2024/1/9.
//

import UIKit
import SnapKit
@_implementationOnly import VisionCCiOSSDKEngine

/// 迪订单信息列
class ChatOrdersTableViewCell: BaseChatCell {
    
    
    /// 点击回调
    public var clickCellBlock:((_ _chirdIndex:Int)->Void)?
    
    private let cell_margin:CGFloat = 10
    private let cell_size:CGSize = .init(width: 47.13, height: 47.13)
    private let cell_identify:String = "ChatOrdersTableViewCell.identify"
    
    
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
        
        if self.contentView.subviews.contains(self.parentView){
            self.parentView.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.equalTo(220.5)
                make.height.equalTo(143)
                make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                make.top.equalTo(self.messageAvatarsImageView.snp.top)
                make.right.equalTo(self.messageAvatarsImageView.snp.left).offset(-VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
            }
        }
        
        if self.parentView.subviews.contains(self.labTitle) {
            self.labTitle.snp.makeConstraints { make in
                make.left.top.equalTo(cell_margin)
                make.right.equalTo(-cell_margin)
                make.height.equalTo(21)
            }
        }
        
        if self.parentView.subviews.contains(self.listCollectionView) {
            self.listCollectionView.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.right.equalTo(0)
                make.top.equalTo(self.labTitle.snp.bottom).offset(6)
                make.height.equalTo(self.cell_size.height)
            }
        }
        
        if self.parentView.subviews.contains(self.labOrderNo) {
            self.labOrderNo.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(cell_margin)
                make.right.equalTo(-cell_margin)
                make.height.equalTo(16.5)
                make.top.equalTo(self.listCollectionView.snp.bottom).offset(10)
            }
        }
        
        if self.parentView.subviews.contains(self.labCreateTime) {
            self.labCreateTime.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(cell_margin)
                make.right.equalTo(-cell_margin)
                make.height.equalTo(16.5)
                make.bottom.equalTo(-10)
            }
        }
        
        super.updateConstraints()
    }
    
    private func initView(){
        
        self.contentView.addSubview(self.parentView)
        
        self.parentView.addSubview(self.labTitle)
        self.parentView.addSubview(self.listCollectionView)
        self.parentView.addSubview(self.labOrderNo)
        self.parentView.addSubview(self.labCreateTime)
        
        setNeedsUpdateConstraints()
    }
    
    //MARK: 数据绑定
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        self.bindCellValue()
        layoutIfNeeded()
    }
    
    
    //MARK: lazy load
    private lazy var parentView:UIView = {[unowned self] in
        let _v = TGSUIModel.createView()
        _v.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
        
        //长按事件
        let _longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(bassCellLongPressAction(sender:)))
        _v.addGestureRecognizer(_longPress)
        _v.isUserInteractionEnabled = true
        
        return _v
    }()
    
    /// 标题
    private lazy var labTitle:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "您正在咨询的订单",
                                          textColor: .colorFromRGB(0x424242),
                                          font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                          andTextAlign: .left)
        return _lab
    }()
    
    /// 列表
    private lazy var listCollectionView:UICollectionView = {[unowned self] in
        let _v = TGSUIModel.createCollectionViewFor(ScrollDirection: .horizontal, withLayout: nil)
        _v.showsHorizontalScrollIndicator = false
        _v.delegate = self
        _v.dataSource = self
        
        //注册列
        _v.register(UICollectionViewCell.classForCoder(),
                    forCellWithReuseIdentifier: cell_identify)
        
        //注册组头尾
        //...
        
        return _v
    }()
    
    private lazy var arrList:[String]? = {
        return [
            "https://img0.baidu.com/it/u=2435050429,3044159349&fm=253&app=120&size=w931&n=0&f=JPEG&fmt=auto?sec=1704906000&t=cfee8db7db3c5f62589fd04fb704cc5c",
            "https://img2.baidu.com/it/u=1738681348,1945875603&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1704906000&t=a8124da2277cb35e39c5a11574c69d7e",
            "https://img0.baidu.com/it/u=3065092866,2600878965&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1704906000&t=734fa4cb268d3f8eaed1ebe5c70c702f",
            "https://img2.baidu.com/it/u=3180250412,32585046&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1704906000&t=a9ddb21712322d647d0e3468bcb0a10c",
            "https://img2.baidu.com/it/u=1562384357,1464409926&fm=253&app=120&size=w931&n=0&f=JPEG&fmt=auto?sec=1704906000&t=826305e43673e41664eae6b64b1ce494"
        ]
    }()
    
    /// 订单号
    private lazy var labOrderNo:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "订单号：9876543456789099",
                                          textColor: .colorFromRGB(0x424242),
                                          font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                          andTextAlign: .left)
        
        _lab.attributedText = TGSUIModel.createAttributed(textString: _lab.text!,
                                                          normalFont: _lab.font,
                                                          normalColor: .colorFromRGB(0x424242),
                                                          highLightString:"9876543456789099",
                                                          highLightFont:_lab.font,
                                                          highLightColor: .colorFromRGB(0x9E9E9E))
        return _lab
    }()
    
    /// 创建时间
    private lazy var labCreateTime:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "创建时间：2021-10-10 20:05:39",
                                          textColor: .colorFromRGB(0x424242),
                                          font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                          andTextAlign: .left)
        
        _lab.attributedText = TGSUIModel.createAttributed(textString: _lab.text!,
                                                          normalFont: _lab.font,
                                                          normalColor: .colorFromRGB(0x424242),
                                                          highLightString:"2021-10-10 20:05:39",
                                                          highLightFont:_lab.font,
                                                          highLightColor: .colorFromRGB(0x9E9E9E))
        
        return _lab
    }()
}


//MARK: -
extension ChatOrdersTableViewCell {
    
    //MARK: 数据绑定
    /// 数据绑定
    private func bindCellValue() {
        
        //更新约束
        self.parentView.snp.remakeConstraints{[weak self] make in
            guard let self = self else { return }
            make.width.equalTo(220.5)
            make.height.equalTo(143)
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
    
    
    //MARK: 订单加载
    /// 加载订单图
    private func bindOrdersFor(Path _p:String?,
                               withTarget _t:UIImageView?) {
        if let _url = _p,_url.isEmpty == false,
           let _newUrl = URL.init(string: _url.yl_urlEncoded()) {
            _t?.yy_setImage(with: _newUrl,
                            placeholder: VXIUIConfig.shareInstance.cellDefaultImage(),
                            options: VXIUIConfig.shareInstance.requestOption()) { [weak self] (_img:UIImage?, _:URL, _:YYWebImageFromType, _:YYWebImageStage, _error:Error?) in
                guard let self = self else { return }
                let _tBlock = {
                    if let _image = _img{
                        let imgNew:UIImage? = _image.yy_imageByResize(to: self.cell_size,
                                                                      contentMode: VXIUIConfig.shareInstance.cellImageContentMode())
                        _t?.image = imgNew
                        _t?.backgroundColor = .clear
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
        else{
            _t?.backgroundColor = VXIUIConfig.shareInstance.cellImageDefaultBackgroudColor()
        }
    }
}


//MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension ChatOrdersTableViewCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrList?.count ?? 1//默认返回1 站位(类似骨架图)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell_identify, for: indexPath)
        
        var imgInfo:UIImageView? = cell.contentView.viewWithTag(1234) as? UIImageView
        if imgInfo == nil {
            imgInfo = TGSUIModel.createImage(rect: .zero,
                                             image: nil,
                                             backgroundColor: VXIUIConfig.shareInstance.cellImageDefaultBackgroudColor())
            imgInfo?.tag = 1234
            cell.contentView.addSubview(imgInfo!)
            imgInfo?.snp.makeConstraints({ make in
                make.edges.equalToSuperview()
            })
        }
        
        if (self.arrList?.count ?? 0) > indexPath.row {
            self.bindOrdersFor(Path: self.arrList?[indexPath.row],withTarget: imgInfo)
        }
        else{
            self.bindOrdersFor(Path: nil,withTarget: imgInfo)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer{
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        if (self.arrList?.count ?? 0) > indexPath.row {
            self.clickCellBlock?(indexPath.row)
        }
    }
    
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cell_size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: cell_margin, bottom: 0, right: cell_margin)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

