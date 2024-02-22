//
//  ChatCardMutableCell.swift
//  Tool
//
//  Created by apple on 2024/1/9.
//

import UIKit
import SnapKit
import RxSwift
import RealmSwift
@_implementationOnly import VisionCCiOSSDKEngine


/// 商品横幅大图卡片列
class ChatCardMutableCell: BaseChatCell {
    
    private let cell_tag_btn = 4100
    private let cell_margin:CGFloat = 10
    private let cell_file_height:CGFloat = 16.5
    private let cell_parent_width:CGFloat = VXIUIConfig.shareInstance.cellMaxWidth()
    private let cell_button_height:CGFloat = 29
    static  let cell_top_image_height:CGFloat = 94.5
    private let cell_identify:String = "ChatCardMutableCell.identify"
    
    /// 点击回调
    var cellParentDidBlock:((_ m:MessageCustomMenus?,_ _cardLink:String?)->Void)?
    
    
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
        layoutIfNeeded()
    }
    
    override func updateConstraints() {
        
        if self.contentView.subviews.contains(self.parentView){
            self.parentView.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.equalTo(cell_parent_width)
                make.height.equalTo(473)
                make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                make.top.equalTo(self.messageAvatarsImageView.snp.top)
                make.right.equalTo(self.messageAvatarsImageView.snp.left).offset(-VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
            }
        }
        
        //MARK: 头部
        if self.parentView.subviews.contains(self.labTopTitle){
            self.labTopTitle.snp.makeConstraints { make in
                make.left.top.equalTo(cell_margin)
                make.height.equalTo(21)
                make.right.equalTo(-cell_margin)
            }
        }
        
        if self.parentView.subviews.contains(self.labTopSubtitle){
            self.labTopSubtitle.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(cell_margin)
                make.top.equalTo(self.labTopTitle.snp.bottom).offset(6)
                make.height.equalTo(16.5)
                make.right.equalTo(-cell_margin)
            }
        }
        
        if self.parentView.subviews.contains(self.imgProduct){
            self.imgProduct.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.right.equalTo(-cell_margin)
                make.left.equalTo(cell_margin)
                make.height.equalTo(ChatCardMutableCell.cell_top_image_height)
                make.top.equalTo(self.labTopSubtitle.snp.bottom).offset(10)
            }
        }
        
        if self.parentView.subviews.contains(self.labHL){
            self.labHL.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(cell_margin)
                make.top.equalTo(self.imgProduct.snp.bottom).offset(10)
                make.height.equalTo(1)
                make.right.equalTo(-cell_margin)
            }
        }
        
        //MARK: 列表
        if self.parentView.subviews.contains(self.listCollectionView){
            self.listCollectionView.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.right.equalTo(0)
                make.width.equalTo(cell_parent_width)
                make.bottom.equalTo(-10)
                make.top.equalTo(self.imgProduct.snp.bottom)
            }
        }
        
        super.updateConstraints()
    }
    
    private func initView(){
        
        self.contentView.addSubview(self.parentView)
        
        //顶部
        self.parentView.addSubview(self.labTopTitle)
        self.parentView.addSubview(self.labTopSubtitle)
        self.parentView.addSubview(self.imgProduct)
        self.parentView.addSubview(self.labHL)
        
        //列表
        self.parentView.addSubview(self.listCollectionView)
        
        //底部字段(动态的)
        //...
        
        setNeedsUpdateConstraints()
    }
    
    
    //MARK: 绑定数据
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        self.chatCardMutableBindValue()
        layoutIfNeeded()
    }
    
    //MARK: - lazy load
    private lazy var parentView:UIView = {[unowned self] in
        let _v = TGSUIModel.createView()
        _v.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
        _v.isUserInteractionEnabled = true
        
        let _tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction(sender:)))
        _v.addGestureRecognizer(_tap)
        
        //长按事件
        let _longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(bassCellLongPressAction(sender:)))
        _v.addGestureRecognizer(_longPress)
        
        return _v
    }()
    
    /// 标题
    private lazy var labTopTitle:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "卡片名称",
                                          textColor: .colorFromRGB(0x424242),
                                          font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                          andTextAlign: .left)
        return _lab
    }()
    
    /// 副标题
    private lazy var labTopSubtitle:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "卡片描述",
                                          textColor: .colorFromRGB(0x9E9E9E),
                                          font: UIFont.systemFont(ofSize: 12, weight: .regular),
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
    
    /// 水平线
    private lazy var labHL:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: nil,
                                          textColor: nil,
                                          font: nil,
                                          backgroundColor: VXIUIConfig.shareInstance.cellSplitColor())
        
        return _lab
    }()
    
    
    //MARK: 列表
    /// 列表
    private lazy var listCollectionView:UICollectionView = {[unowned self] in
        let _v = TGSUIModel.createCollectionViewFor(ScrollDirection: .vertical)
        _v.showsHorizontalScrollIndicator = false
        _v.showsVerticalScrollIndicator = false
        _v.delegate = self
        _v.dataSource = self
        
        //注册列
        _v.register(ChatCardChildCell.classForCoder(),
                    forCellWithReuseIdentifier: cell_identify)
        
        //注册组头尾
        //...
        
        return _v
    }()
    
    private lazy var arrList:[MessageCustomItems]? = nil {
        didSet{
            self.listCollectionView.reloadData()
        }
    }
}


//MARK: -
extension ChatCardMutableCell {
    
    //MARK: 数据绑定
    /// 数据绑定
    private func chatCardMutableBindValue() {
        
        //MARK: 头部数据
        //[S]头部数据
        var _info:String? = self.message?.messageBody?.cardGuide
        self.labTopTitle.text = _info
        self.labTopTitle.snp.remakeConstraints{ make in
            make.left.top.equalTo(cell_margin)
            make.height.equalTo((_info == nil || _info?.isEmpty == true) ? 0 : 21)
            make.right.equalTo(-cell_margin)
        }
        
        _info = self.message?.messageBody?.cardDesc
        self.labTopSubtitle.text = _info
        self.labTopSubtitle.snp.remakeConstraints {[weak self] make in
            guard let self = self else { return }
            make.left.equalTo(cell_margin)
            make.top.equalTo(self.labTopTitle.snp.bottom).offset((_info == nil || _info?.isEmpty == true) ? 0 : 6)
            make.height.equalTo((_info == nil || _info?.isEmpty == true) ? 0 : 16.5)
            make.right.equalTo(-cell_margin)
        }
        
        let _isHiddenTop:Bool = (self.message?.messageBody?.cardGuide == nil || self.message?.messageBody?.cardGuide?.isEmpty == true) && (self.message?.messageBody?.cardDesc == nil || self.message?.messageBody?.cardDesc?.isEmpty == true)
        self.labHL.isHidden = _isHiddenTop
        
        var _image_h:CGFloat = 0
        if let _url = self.message?.messageBody?.cardImg,_url.isEmpty == false,
           let _newUrl = URL.init(string: TGSUIModel.getFileRealUrlFor(Path: _url, andisThumbnail: true)) {
            _image_h = ChatCardMutableCell.cell_top_image_height
            
            self.imgProduct.yy_setImage(with: _newUrl,
                                        placeholder: VXIUIConfig.shareInstance.cellDefaultImage(),
                                        options: VXIUIConfig.shareInstance.requestOption()) { [weak self] (_img:UIImage?, _:URL, _:YYWebImageFromType, _:YYWebImageStage, _error:Error?) in
                guard let self = self else { return }
                let _tBlock = {[weak self] in
                    guard let self = self else { return }
                    if let _image = _img {
                        let _size:CGSize = .init(width: self.cell_parent_width - 2 * self.cell_margin, height: _image_h)
                        self.imgProduct.image = _image.yy_imageByResize(to: _size,
                                                                        contentMode: VXIUIConfig.shareInstance.cellImageContentMode())
                        
                        self.imgProduct.snp.remakeConstraints {[weak self] make in
                            guard let self = self else { return }
                            make.right.equalTo(-cell_margin)
                            make.left.equalTo(cell_margin)
                            make.height.equalTo(_image_h)
                            make.top.equalTo(self.labTopSubtitle.snp.bottom).offset(_isHiddenTop ? 0 : 10)
                        }
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
            _image_h = 0
            self.imgProduct.snp.remakeConstraints {[weak self] make in
                guard let self = self else { return }
                make.right.equalTo(-cell_margin)
                make.left.equalTo(cell_margin)
                make.height.equalTo(_image_h)
                make.top.equalTo(self.labTopSubtitle.snp.bottom).offset(_image_h > 0 ? 10 : 0)
            }
        }
        //[E]
        
        //MARK: 中间列表
        //[S]中间列表
        let _list = self.message?.messageBody?.customItems
        self.arrList = _list
        
        //高度更新
        var _h:CGFloat = 0
        if _list != nil && (_list?.count ?? 0) > 0 {
            for _item in _list! {
                let _item_h = ChatCardChildCell.getCardChildCellHeightFor(Data: _item)
                _h += _item_h
                _item.cellHeight = _item_h
            }
        }
        
        self.listCollectionView.snp.remakeConstraints {[weak self] make in
            guard let self = self else { return }
            make.left.right.equalTo(0)
            make.width.equalTo(cell_parent_width)
            make.height.equalTo(_h)
            make.top.equalTo(self.imgProduct.snp.bottom)
        }
        //[E]
        
        //MARK: 附件字段
        //[S]字段信息
        let cell_tag_start = 4000
        
        //先移除
        self.parentView.subviews.forEach {
            if $0.isKind(of: YYLabel.classForCoder()) && $0.tag >= cell_tag_start {
                $0.removeFromSuperview()
            }
        }
        
        if let _arr = self.message?.messageBody?.customFields,_arr.count > 0 {
            //后添加
            for i in 0..<_arr.count {
                let _item = _arr[i]
                let _lab = TGSUIModel.createLable(rect: .zero,
                                                  text: "\(_item.key ?? "")：\(_item.value ?? "")",
                                                  textColor: .colorFromRGB(0x424242),
                                                  font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                                  andTextAlign: .left)
                let _tag = cell_tag_start + i
                _lab.tag = _tag
                _lab.attributedText = TGSUIModel.createAttributed(textString: _lab.text!,
                                                                  normalFont: _lab.font,
                                                                  normalColor: .colorFromRGB(0x424242),
                                                                  highLightString:_item.value ?? "",
                                                                  highLightFont:_lab.font,
                                                                  highLightColor: .colorFromRGB(0x9E9E9E))
                self.parentView.addSubview(_lab)
                _lab.snp.makeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.left.equalTo(cell_margin)
                    make.right.equalTo(-cell_margin)
                    make.height.equalTo(cell_file_height)
                    if i == 0 {
                        if _h > 0 {
                            make.top.equalTo(self.listCollectionView.snp.bottom).offset(6)
                        }
                        else{
                            make.top.equalTo(self.labHL.snp.bottom).offset(6)
                        }
                    }
                    else{
                        if let _lab_Temp = self.contentView.viewWithTag(_tag - 1) {
                            make.top.equalTo(_lab_Temp.snp.bottom).offset(6)
                        }
                    }
                }
            }
        }
        //[E]
        
        //MARK: 附件按钮
        //[S] 底部按钮
        //先移除
        self.parentView.subviews.forEach {
            if $0.isKind(of: UIButton.classForCoder()) && $0.tag >= cell_tag_btn {
                $0.removeFromSuperview()
            }
        }
        
        //添加
        if let _arr = self.message?.messageBody?.customMenus,_arr.count > 0 {
            for i in 0..<_arr.count {
                let _item = _arr[i]
                let _btn = TGSUIModel.createBtn(rect: .zero,
                                                strTitle: _item.title,
                                                titleColor: .colorFromRGB(0x07C160),
                                                txtFont: UIFont.systemFont(ofSize: 15, weight: .regular),
                                                image: nil,
                                                borderColor: .colorFromRGB(0x07C160),
                                                cornerRadius: VXIUIConfig.shareInstance.bubbleCornerRadius(),
                                                isRadius: true,
                                                borderWidth: 0.5)
                _btn.tag = cell_tag_btn + i
                _btn.addTarget(self, action: #selector(btnClickAction(sender:)), for: .touchUpInside)
                
                self.parentView.addSubview(_btn)
                _btn.snp.makeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.left.equalTo(cell_margin)
                    make.right.equalTo(-cell_margin)
                    make.height.equalTo(cell_button_height)
                    if i == 0 {
                        if let _arrFiles = self.message?.messageBody?.customFields,_arrFiles.count > 0,
                           let _file = self.parentView.viewWithTag(cell_tag_start + _arrFiles.count - 1) {
                            make.top.equalTo(_file.snp.bottom).offset(6)
                        }
                        else{
                            make.top.equalTo(self.listCollectionView.snp.bottom).offset(6)
                        }
                    }
                    else {
                        if let _temp = self.contentView.viewWithTag(cell_tag_btn + i - 1) as? UIButton {
                            make.top.equalTo(_temp.snp.bottom).offset(6)
                        }
                    }
                }
            }
        }
        //[E]
        
        //更新高度
        var _parentH:CGFloat = 63.5
        if (self.message?.messageBody?.cardGuide == nil || self.message?.messageBody?.cardGuide?.isEmpty == true) && (self.message?.messageBody?.cardDesc == nil || self.message?.messageBody?.cardDesc?.isEmpty == true) {
            _parentH = 5
        }
        
        _parentH += _image_h + CGFloat(_image_h > 0 ? 10 : 0) //图片高度及间距
        _parentH += _h                     //列表高度
        _parentH += CGFloat(self.message?.messageBody?.customFields?.count ?? 0) * CGFloat(cell_file_height + 6)
        _parentH += CGFloat(self.message?.messageBody?.customMenus?.count ?? 0) * CGFloat(cell_button_height + 6)
        _parentH += 15
        
        self.parentView.snp.remakeConstraints {[weak self] make in
            guard let self = self else { return }
            make.width.equalTo(cell_parent_width)
            make.height.equalTo(_parentH)
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
    
    /// 按钮点击
    @objc private func btnClickAction(sender:UIButton?) {
        debugPrint("我被点击了:{title:\(sender?.titleLabel?.text ?? "--"),tag:\(sender?.tag ?? 0)}")
        
        let _tag = (sender?.tag ?? 0) - cell_tag_btn
        if let _arr = self.message?.messageBody?.customMenus,_arr.count > 0,_arr.count > _tag {
            let _item = _arr[_tag]
            self.didActionBy(CustomMenus: _item)
        }
    }
    
    private func didActionBy(CustomMenus _item:MessageCustomMenus?){
        if _item?.type == 4 {
            var _m = ShortcutsModel.init()
            _m.title = _item?.title
            _m.shortcutType = 5
            _m.command =  _item?.command
            NotificationCenter.default.post(name: VXIUIConfig.shareInstance.getQuickPhrases(),object: nil, userInfo: ["5":_m])
        }
        else{
            self.cellParentDidBlock?(_item,self.message?.messageBody?.cardLink)
        }
    }
    
    /// 点击
    @objc private func tapAction(sender:UITapGestureRecognizer){
        self.didActionBy(CustomMenus: self.message?.messageBody?.customMenus?.first)
    }
}


//MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension ChatCardMutableCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _arr = self.arrList {
            return _arr.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell_identify, for: indexPath)
        
        if let _arr = self.arrList,_arr.count > indexPath.row {
            (cell as? ChatCardChildCell)?.cellBindValueFor(CellData: _arr[indexPath.row])
            (cell as? ChatCardChildCell)?.cellDidBlock = {[weak self] (_m:MessageCustomMenus?,_cardLink:String?) in
                guard let self = self else { return }
                //传递上层应用
                if _m?.type == 4 {
                    var _sm = ShortcutsModel.init()
                    _sm.title = _m?.title
                    _sm.shortcutType = 5
                    _sm.command = _m?.command
                    NotificationCenter.default.post(name: VXIUIConfig.shareInstance.getQuickPhrases(),object: nil, userInfo: ["5":_sm])
                }
                else{
                    self.cellParentDidBlock?(_m,_cardLink)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer{
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        if let _arr = self.arrList,_arr.count > indexPath.row {
            self.didActionBy(CustomMenus: _arr[indexPath.row].customMenus?.first)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let _arr = self.arrList,_arr.count > indexPath.row {
            let _h = ChatCardChildCell.getCardChildCellHeightFor(Data: _arr[indexPath.row])
            return .init(width: cell_parent_width, height: _h)
        }
        return .zero
    }
    
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if (self.message?.messageBody?.cardGuide == nil || self.message?.messageBody?.cardGuide?.isEmpty == true) && (self.message?.messageBody?.cardDesc == nil || self.message?.messageBody?.cardDesc?.isEmpty == true) {
            return .zero
        }
        else{
            return .init(top: cell_margin, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
}


//MARK: -
//MARK: - ChatCardChildCell
class ChatCardChildCell : UICollectionViewCell {
    
    private let cell_tag_start = 500000
    private let cell_margin:CGFloat = 10
    private static let cell_ziduan_height:CGFloat = 16.5
    private static let cell_description_max:CGFloat = VXIUIConfig.shareInstance.cellMaxWidth() - 90
    private static let cell_file_max:CGFloat = VXIUIConfig.shareInstance.cellMaxWidth() - 20
    private let cell_image_size:CGSize = .init(width: 64, height: 64)
    var cellDidBlock:((_ m:MessageCustomMenus?,_ _cardLink:String?)->Void)?
    
    //MARK: -
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        if self.contentView.subviews.contains(self.imgInfo){
            self.imgInfo.snp.makeConstraints({[weak self] make in
                guard let self = self else { return }
                make.size.equalTo(cell_image_size)
                make.left.equalTo(cell_margin)
                make.top.equalTo(cell_margin)
            })
        }
        
        if self.contentView.subviews.contains(self.labName){
            self.labName.snp.makeConstraints({[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(self.imgInfo.snp.right).offset(6)
                make.top.equalTo(self.imgInfo.snp.top)
                make.right.equalTo(-cell_margin)
                make.height.equalTo(21)
            })
        }
        
        if self.contentView.subviews.contains(self.labDescription){
            self.labDescription.snp.makeConstraints({[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(self.labName.snp.left)
                make.top.equalTo(self.labName.snp.bottom).offset(6)
                make.right.equalTo(-cell_margin)
                make.height.equalTo(16.5)
            })
        }
        
        if self.contentView.subviews.contains(self.btnRight){
            self.btnRight.snp.makeConstraints({ make in
                make.width.equalTo(36)
                make.height.equalTo(20.5)
                make.right.equalTo(-cell_margin)
                make.bottom.equalTo(-10.5)
            })
        }
        
        if self.contentView.subviews.contains(self.labProductPrice){
            self.labProductPrice.snp.makeConstraints({[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(self.labName.snp.left)
                make.top.equalTo(self.labDescription.snp.bottom).offset(6)
                make.width.equalTo(69)
                make.height.equalTo(22)
            })
        }
        
        if self.contentView.subviews.contains(self.labOriginalPrice){
            self.labOriginalPrice.snp.makeConstraints({[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(self.labProductPrice.snp.right).offset(2.5)
                make.centerY.equalTo(self.labProductPrice.snp.centerY)
                make.width.equalTo(60)
                make.height.equalTo(22)
            })
        }
        
        if self.contentView.subviews.contains(self.labLine){
            self.labLine.snp.makeConstraints({ make in
                make.height.equalTo(1)
                make.left.equalTo(cell_margin)
                make.right.equalTo(-cell_margin)
                make.bottom.equalTo(-10)
            })
        }
        
        super.updateConstraints()
    }
    
    private func initView(){
        //图片
        self.contentView.addSubview(self.imgInfo)
        
        //名称
        self.contentView.addSubview(self.labName)
        
        //描述
        self.contentView.addSubview(self.labDescription)
        
        //按钮
        self.contentView.addSubview(self.btnRight)
        
        //价格
        self.contentView.addSubview(self.labProductPrice)
        self.contentView.addSubview(self.labOriginalPrice)
        
        //底部线
        self.contentView.addSubview(self.labLine)
        
        setNeedsUpdateConstraints()
    }
    
    
    //MARK: - lazy load
    private lazy var _customMenus:MessageCustomMenus? = nil
    private lazy var _cardLink:String? = nil
    
    /// 图片
    private lazy var imgInfo:UIImageView = {
        let _imgInfo = TGSUIModel.createImage(rect: .zero,
                                              image: nil,
                                              backgroundColor: VXIUIConfig.shareInstance.cellImageDefaultBackgroudColor())
        return _imgInfo
    }()
    
    /// 名称
    private lazy var labName:YYLabel = {
        let _labName = TGSUIModel.createLable(rect: .zero,
                                              text: nil,
                                              textColor: .colorFromRGB(0x424242),
                                              font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                              andTextAlign: .left)
        
        _labName.numberOfLines = 0
        _labName.isUserInteractionEnabled = true
        _labName.textVerticalAlignment = .top
        _labName.tintAdjustmentMode = .automatic
        _labName.ignoreCommonProperties = true
        _labName.preferredMaxLayoutWidth = ChatCardChildCell.cell_description_max
        
        return _labName
    }()
    
    /// 描述
    private lazy var labDescription:YYLabel = {
        let _labDescription = TGSUIModel.createLable(rect: .zero,
                                                     text: nil,
                                                     textColor: .colorFromRGB(0x9E9E9E),
                                                     font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                                     andTextAlign: .left)
        
        _labDescription.numberOfLines = 0
        _labDescription.isUserInteractionEnabled = true
        _labDescription.textVerticalAlignment = .top
        _labDescription.tintAdjustmentMode = .automatic
        _labDescription.ignoreCommonProperties = true
        _labDescription.preferredMaxLayoutWidth = ChatCardChildCell.cell_description_max
        
        return _labDescription
    }()
    
    /// 按钮(可选)
    private lazy var btnRight:UIButton = {[unowned self] in
        let _btn = TGSUIModel.createBtn(rect: .zero,
                                        strTitle: "按钮",
                                        titleColor: .colorFromRGB(0x07C160),
                                        txtFont: UIFont.systemFont(ofSize: 15, weight: .regular),
                                        image: nil,
                                        borderColor: .colorFromRGB(0x07C160),
                                        cornerRadius: 2,
                                        isRadius: true,
                                        borderWidth: 0.5)
        _btn.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            self.cellDidBlock?(self._customMenus,self._cardLink)
        }.disposed(by: rx.disposeBag)
        
        return _btn
    }()
    
    /// 价格
    private lazy var labProductPrice:YYLabel = {
        return TGSUIModel.createLable(rect: .zero,
                                      text: nil,
                                      textColor: .colorFromRGB(0xFF8F1F),
                                      font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                                      andTextAlign: .left)
    }()
    
    /// 原价(划线价，可选)
    private lazy var labOriginalPrice:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: nil,
                                          textColor: .colorFromRGB(0x9E9E9E),
                                          font: UIFont.systemFont(ofSize: 11, weight: .semibold),
                                          andTextAlign: .left)
        
        let _line = TGSUIModel.createLable(rect: .zero,backgroundColor: .init().colorFromHexInt(hex: 0x9E9E9E))
        _lab.addSubview(_line)
        _line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.centerY.equalToSuperview()
        }
        
        return _lab
    }()
    
    /// 底部线
    private lazy var labLine:YYLabel = {
        return TGSUIModel.createLable(rect: .zero,
                                      text: nil,
                                      textColor: nil,
                                      font: nil,
                                      backgroundColor: VXIUIConfig.shareInstance.cellSplitColor())
        
    }()
}


//MARK: -
extension ChatCardChildCell {
    
    
    //MARK: 高度计算
    /// 计算高度
    /// - Parameters:
    ///   - _data: MessageCustomItems?
    ///   - _ci: String? 顶部卡片地址
    ///   - _cg: String? self.message?.messageBody?.cardGuide
    ///   _ _cd: String? self.message?.messageBody?.cardDesc
    /// - Returns: <#description#>
    static func getCardChildCellHeightFor(Data _data:MessageCustomItems?) -> CGFloat {
        if _data == nil {
            return .zero
        }
        
        if let _ch = _data?.cellHeight {
            return _ch
        }
        
        //默认高度
        var _tempH:CGFloat = 91.5
        
        //标题
        if let _customCardName = _data?.customCardName,_customCardName.isEmpty == false {
            let _attr = TGSUIModel.createAttributed(textString: _customCardName,
                                                    normalFont: UIFont.systemFont(ofSize: 15, weight: .regular),
                                                    normalColor: .colorFromRGB(0x424242))
            
            let _layout = YYTextLayout.init(containerSize: CGSize(width:ChatCardChildCell.cell_description_max,height: CGFloat(MAXFLOAT)),text: _attr)
            if let _layout_h = _layout?.textBoundingSize.height {
                _tempH = _tempH + (_layout_h - 21)
            }
        }
        
        //计算描述
        if let _description = _data?.customCardDesc,_description.isEmpty == false {
            let _attr = TGSUIModel.createAttributed(textString: _description,
                                                    normalFont: UIFont.systemFont(ofSize: 12, weight: .regular),
                                                    normalColor: UIColor.colorFromRGB(0x9E9E9E))
            
            let _layout = YYTextLayout.init(containerSize: CGSize(width:ChatCardChildCell.cell_description_max,height: CGFloat(MAXFLOAT)),text: _attr)
            if let _layout_h = _layout?.textBoundingSize.height {
                _tempH = _tempH + (_layout_h - cell_ziduan_height)
            }
        }
        
        //原价
        if let _op = _data?.customCardOriginalAmount,_op.isEmpty == false,(_data?.customMenus?.count ?? 0) > 0 {
            _tempH += 26.5 //按钮高度和间距
        }
        
        //字段高度
        if let _arr = _data?.customFields,_arr.count > 0 {
            for i in 0..<_arr.count {
                let _item = _arr[i]
                let _attr = TGSUIModel.createAttributed(textString: "\(_item.key ?? "")：\(_item.value ?? "")",
                                                        normalFont: UIFont.systemFont(ofSize: 12, weight: .regular),
                                                        normalColor: .colorFromRGB(0x424242),
                                                        highLightString:_item.value ?? "",
                                                        highLightFont:UIFont.systemFont(ofSize: 12, weight: .regular),
                                                        highLightColor: .colorFromRGB(0x9E9E9E))
                
                let _layout = YYTextLayout.init(containerSize: CGSize(width:ChatCardChildCell.cell_file_max,height: CGFloat(MAXFLOAT)),text: _attr)
                if let _lh = _layout?.textBoundingSize.height {
                    _tempH += _lh + 6
                }
                else{
                    _tempH += cell_ziduan_height + 6
                }
            }
        }
        
        _tempH += 10 //间距
        _data?.cellHeight = _tempH //保存
        return _tempH
    }
    
    
    //MARK: 列数据绑定
    /// 列数据绑定
    func cellBindValueFor(CellData _cd:MessageCustomItems?) {
        
        //图片
        if let _url = _cd?.customCardThumbnail as? String,_url.isEmpty == false,
           let _newUrl = URL.init(string: TGSUIModel.getFileRealUrlFor(Path: _url, andisThumbnail: true)) {
            self.imgInfo.yy_setImage(with: _newUrl,
                                     placeholder: VXIUIConfig.shareInstance.cellDefaultImage(),
                                     options: VXIUIConfig.shareInstance.requestOption()) { [weak self] (_img:UIImage?, _:URL, _:YYWebImageFromType, _:YYWebImageStage, _error:Error?) in
                guard let self = self else { return }
                let _tBlock = {
                    if let _image = _img {
                        let imgNew:UIImage? = _image.yy_imageByResize(to: self.cell_image_size,
                                                                      contentMode: VXIUIConfig.shareInstance.cellImageContentMode())
                        self.imgInfo.image = imgNew
                        self.imgInfo.backgroundColor = .clear
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
            self.imgInfo.backgroundColor = VXIUIConfig.shareInstance.cellImageDefaultBackgroudColor()
        }
        
        //[S]标题
        var _attr = TGSUIModel.createAttributed(textString: _cd?.customCardName ?? "",
                                                normalFont: self.labName.font,
                                                normalColor: self.labName.textColor)
        
        var _layout = YYTextLayout.init(containerSize: CGSize(width:ChatCardChildCell.cell_description_max,height: CGFloat(MAXFLOAT)),text: _attr)
        self.labName.textLayout = _layout
        self.labName.snp.remakeConstraints {[weak self] make in
            guard let self = self else { return }
            make.left.equalTo(self.imgInfo.snp.right).offset(6)
            make.top.equalTo(self.imgInfo.snp.top)
            make.right.equalTo(-cell_margin)
            make.height.equalTo(_layout?.textBoundingSize.height ?? 21)
        }
        //[E]
        
        //[S]副标题
        _attr = TGSUIModel.createAttributed(textString: _cd?.customCardDesc ?? "",
                                            normalFont: self.labDescription.font,
                                            normalColor: self.labDescription.textColor)
        
        _layout = YYTextLayout.init(containerSize: CGSize(width:ChatCardChildCell.cell_description_max,height: CGFloat(MAXFLOAT)),text: _attr)
        self.labDescription.textLayout = _layout
        self.labDescription.snp.remakeConstraints {[weak self] make in
            guard let self = self else { return }
            make.left.equalTo(self.labName.snp.left)
            make.top.equalTo(self.labName.snp.bottom).offset(6)
            make.right.equalTo(-cell_margin)
            make.height.equalTo(_layout?.textBoundingSize.height ?? 16.5)
        }
        //[E]
        
        //价格
        if let _p = _cd?.customCardAmount as? String,_p.isEmpty == false {
            let _unit = _cd?.customCardAmountSymbol ?? "￥"//货币类型(单位)
            let _arr = _p.replacingOccurrences(of: _unit, with: "").components(separatedBy: ".")
            let _color:UIColor =  .colorFromRGB(0xFF8F1F)
            let _font:UIFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
            
            let _attr = TGSUIModel.setAttributeStringTexts(strFullText: _unit + _p,
                                                           andFullTextFont: _font,
                                                           andFullTextColor: _color,
                                                           withChangeText: [_unit,".\(_arr.last!)"],
                                                           withChangeFont: UIFont.systemFont(ofSize: 11, weight: .semibold),
                                                           withChangeColor: _color,
                                                           isLineThrough: false)
            self.labProductPrice.attributedText = _attr
            let _w:CGFloat = _attr.size().width
            
            self.labProductPrice.snp.remakeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(self.labName.snp.left)
                make.top.equalTo(self.labDescription.snp.bottom).offset(6)
                make.width.equalTo(_w)
                make.height.equalTo(22)
            }
        }
        else{
            self.labProductPrice.attributedText = nil
            self.labProductPrice.text = nil
        }
        
        //[S]划线价格
        let _originalAmount:String? = _cd?.customCardOriginalAmount
        self.labOriginalPrice.text = _originalAmount
        if _originalAmount == nil || _originalAmount?.isEmpty == true {
            self.labOriginalPrice.isHidden = true
        }
        else{
            self.labOriginalPrice.isHidden = false
            let _w:CGFloat = _originalAmount?.yl_getLabelWidth(Font: self.labOriginalPrice.font!,
                                                               andHeight: 22) ?? 60
            self.labOriginalPrice.snp.remakeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(self.labProductPrice.snp.right).offset(2.5)
                make.centerY.equalTo(self.labProductPrice.snp.centerY)
                make.width.equalTo(_w)
                make.height.equalTo(22)
            }
        }
        //[E]
        
        //[S]按钮
        self._customMenus = _cd?.customMenus?.first
        self._cardLink = _cd?.customCardLink
        
        let _btn_title:String? = self._customMenus?.title
        self.btnRight.setTitle(_btn_title, for: .normal)
        if _btn_title == nil || _btn_title?.isEmpty == true {
            self.btnRight.isHidden = true
        }
        else{
            self.btnRight.isHidden = false
            let _w:CGFloat = _btn_title!.yl_getWidthFor(Font: UIFont.systemFont(ofSize: 15, weight: .regular)) + 12
            self.btnRight.snp.remakeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.equalTo(_w)
                make.height.equalTo(20.5)
                if self.labOriginalPrice.isHidden == true {
                    make.right.equalTo(-cell_margin)
                    make.centerY.equalTo(self.labProductPrice.snp.centerY)
                }
                else{
                    make.left.equalTo(self.labProductPrice.snp.left)
                    make.top.equalTo(self.labProductPrice.snp.bottom).offset(6)
                }
            }
        }
        //[E]
        
        //[S]字段信息
        //先移除
        self.contentView.subviews.forEach {
            if $0.isKind(of: YYLabel.classForCoder()) && $0.tag >= cell_tag_start {
                $0.removeFromSuperview()
            }
        }
        
        //后添加
        if let _arr = _cd?.customFields,_arr.count > 0 {
            for i in 0..<_arr.count {
                let _item = _arr[i]
                let _lab = TGSUIModel.createLable(rect: .zero,
                                                  text: "\(_item.key ?? "")：\(_item.value ?? "")",
                                                  textColor: .colorFromRGB(0x424242),
                                                  font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                                  andTextAlign: .left)
                let _tag = cell_tag_start + i
                _lab.tag = _tag
                _lab.numberOfLines = 0
                _lab.isUserInteractionEnabled = true
                _lab.textVerticalAlignment = .top
                _lab.tintAdjustmentMode = .automatic
                _lab.ignoreCommonProperties = true
                _lab.preferredMaxLayoutWidth = ChatCardChildCell.cell_file_max
                
                let _attr = TGSUIModel.createAttributed(textString: _lab.text!,
                                                        normalFont: _lab.font,
                                                        normalColor: .colorFromRGB(0x424242),
                                                        highLightString:_item.value ?? "",
                                                        highLightFont:_lab.font,
                                                        highLightColor: .colorFromRGB(0x9E9E9E))
                
                let _layout = YYTextLayout.init(containerSize: CGSize(width:ChatCardChildCell.cell_file_max,height: CGFloat(MAXFLOAT)),text: _attr)
                _lab.textLayout = _layout
                
                self.contentView.addSubview(_lab)
                _lab.snp.makeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.left.equalTo(cell_margin)
                    make.right.equalTo(-cell_margin)
                    make.height.equalTo(_layout?.textBoundingSize.height ?? ChatCardChildCell.cell_ziduan_height)
                    if i == 0 {
                        if self.btnRight.isHidden == false {
                            make.top.equalTo(self.btnRight.snp.bottom).offset(6)
                        }
                        else{
                            if self.labProductPrice.attributedText == nil ||
                                self.labProductPrice.text == nil || self.labProductPrice.text?.isEmpty == true {
                                make.top.equalTo(87.5)
                            }
                            else{
                                make.top.equalTo(self.labProductPrice.snp.bottom).offset(6)
                            }
                        }
                    }
                    else{
                        if let _lab_Temp = self.contentView.viewWithTag(_tag - 1) {
                            make.top.equalTo(_lab_Temp.snp.bottom).offset(6)
                        }
                    }
                }
            }
        }
        //[E]
    }
    
}
