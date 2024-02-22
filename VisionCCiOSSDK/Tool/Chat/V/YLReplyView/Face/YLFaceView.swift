//
//  YLFaceView.swift
//  YLBaseChat
//
//  Created by yl on 17/5/22.
//  Copyright © 2017年 yl. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import JXSegmentedView
@_implementationOnly import VisionCCiOSSDKEngine

protocol YLFaceViewDelegate:NSObjectProtocol {
    
    func epInsertFace(_ emoji:String)                // 插入表情
    func epDeleteTextFromTheBack()                   // 从最后面开始删除
    func epSendMessage()                             // 发送消息
    /// 发送自定义图片表情(无需上传)
    func epSendFaceoImage(_ _name:String, _ _mediaUrl:String)
    func epButtonClick(_ _type:YLInputViewBtnState)  // 菜单点击
}


/// 底部表情面板
class YLFaceView: UIView {
    
    private let cell_margin:CGFloat = 15
    weak var delegate:YLFaceViewDelegate?
    
    
    //MARK: - override
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        if self.subviews.contains(self.segmentedView) {
            self.segmentedView.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.right.equalTo(0)
                make.top.equalTo(self.labLine.snp.bottom)
                make.height.equalTo(VXIUIConfig.shareInstance.faceMenuHeight())
            }
        }
        
        if self.subviews.contains(self.labLine){
            self.labLine.snp.makeConstraints { make in
                make.left.top.right.equalTo(0)
                make.height.equalTo(0.5)
            }
        }
        
        if self.subviews.contains(self.listContainerView){
            self.listContainerView.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.right.equalTo(0)
                make.height.equalTo(VXIUIConfig.shareInstance.faceFootViewHeight() - VXIUIConfig.shareInstance.faceMenuHeight())
                make.top.equalTo(self.segmentedView.snp.bottom)
            }
        }
        
        super.updateConstraints()
    }
    
    fileprivate func layoutUI() {
        self.backgroundColor = VXIUIConfig.shareInstance.appViewBottomBackgroundColor()
        
        self.addSubview(self.labLine)
        self.addSubview(self.segmentedView)
        self.addSubview(self.listContainerView)
        
        /// 监听配置更新
        NotificationCenter.default.rx.notification(VXIUIConfig.shareInstance.getFaceConfigkey(), object: nil).subscribe {[weak self] (_input:Event<Notification>) in
            guard let self = self else { return }
            if let _arr = _input.element?.userInfo?["data"],
               let _data = TGSUIModel.getJsonDataFor(Any: _arr) {
                do{
                    let _result = try JSONDecoder.init().decode([StickerPkgsModel].self, from: _data)
                    self.arrFaceImages = _result
                }
                catch(let _error){
                    debugPrint(_error)
                }
            }
        }.disposed(by: rx.disposeBag)
        
        self.arrFaceImages = TGSUIModel.getSystemInfoModel(key: VXIUIConfig.shareInstance.getGlobalCgaKey())?.stickerPkgs
        
        setNeedsUpdateConstraints()
    }
    
    //MARK: - lazy load
    private lazy var titleDataSource:JXSegmentedTitleDataSource = {
        let _ds = JXSegmentedTitleDataSource.init()
        
        //配置数据源相关配置属性
        _ds.isTitleColorGradientEnabled = false
        _ds.titleSelectedFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        _ds.titleSelectedColor = VXIUIConfig.shareInstance.cellHighlightColor()
        _ds.titleNormalFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        _ds.titleNormalColor = VXIUIConfig.shareInstance.cellnornalColor()
        _ds.itemSpacing = cell_margin
        
        _ds.isItemSpacingAverageEnabled = false
        
        return _ds
    }()
    
    private lazy var labLine:YYLabel = {
        return TGSUIModel.createLable(rect: .zero,
                                      backgroundColor: VXIUIConfig.shareInstance.cellSplitColor())
    }()
    
    //MARK: 分组面板
    private lazy var segmentedView:JXSegmentedView = {
        let _v = JXSegmentedView.init(frame: .zero)
        _v.delegate = self
        _v.dataSource = self.titleDataSource
        _v.contentEdgeInsetLeft = cell_margin
        _v.contentEdgeInsetRight = cell_margin
        _v.isContentScrollViewClickTransitionAnimationEnabled = true
        _v.contentScrollView = self.listContainerView.scrollView
        return _v
    }()
    
    //MARK: 表情面板
    private lazy var listContainerView = JXSegmentedListContainerView(dataSource: self)
    
    /// 其他自定义表情
    private lazy var arrFaceImages:[StickerPkgsModel]? = nil
    {
        didSet{
            var _arr = [String]()
            _arr.append("默认表情")
            if self.arrFaceImages != nil && (self.arrFaceImages?.count ?? 0) > 0 {
                for _item in self.arrFaceImages! {
                    _arr.append(_item.title ?? "\(_item.groupId)")
                }
            }
            
            self.titleDataSource.titles = _arr
            self.segmentedView.reloadData()
            self.listContainerView.reloadData()
        }
    }
    
    //MARK: 数据
    private lazy var emojiImages:Array<String> = {
        if let path = VXIUIConfig.shareInstance.getBundle()?.path(forResource: "emojiImage", ofType: "plist") {
            let _arrtemp = try? NSArray.init(contentsOf: URL.init(fileURLWithPath: path), error: ()) as? [String]
            if _arrtemp != nil && _arrtemp!.count > 0 {
                return _arrtemp!
            }
        }
        
        return Array<String>()
    }()
}

// MARK: - JXSegmentedViewDelegate
extension YLFaceView:JXSegmentedViewDelegate {
    
    // 点击或滚动选中调用该方法
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        self.listContainerView.didClickSelectedItem(at: index)
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {
        self.listContainerView.scrolling(from: leftIndex, to: rightIndex, percent: percent, selectedIndex: segmentedView.selectedIndex)
    }
}

//MARK: - JXSegmentedListContainerViewDataSource
extension YLFaceView : JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        self.titleDataSource.titles.count
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        
        let _layer = UICollectionViewFlowLayout.init()
        _layer.scrollDirection = .vertical
        //组尾浮动
        _layer.sectionFootersPinToVisibleBounds = true
        
        let vc = LoadDataViewController.init(frame: .zero,
                                             collectionViewLayout: _layer,
                                             andSelectIndex: index)
        vc.backgroundColor = VXIUIConfig.shareInstance.appViewControlelrBackgroundColor()
        if index == 0 {
            vc.emojiImages = self.emojiImages
        }
        else if index > 0 && (self.arrFaceImages?.count ?? 0) > index - 1 {
            vc.arrList = self.arrFaceImages![index - 1].stickers
        }
        
        vc.didSelectBlock = {[weak self] (_index,_any) in
            guard let self = self else { return }
            if _index == nil && _any == nil {
                self.delegate?.epDeleteTextFromTheBack()
            }
            else if _index == 0,let _emoji = _any as? String,_emoji.isEmpty == false {
                self.delegate?.epInsertFace(_emoji)
            }
            else if (_index ?? 0) > 0,let (_name,_path) = _any as? (String,String) {
                self.delegate?.epSendFaceoImage(_name, _path)
            }
        }
        
        return vc
    }
    
}


//MARK: - LoadDataViewController
class LoadDataViewController : UICollectionView {
    
    private var selectIndex:Int = 0
    lazy var emojiImages = [String]()
    lazy var arrList:[StickersModel]? = nil
    
    private let cell_margin:CGFloat = 15
    private let cell_identify:String = "YLFaceView.emoji.identify"
    private let cell_identify1:String = "YLFaceView.image.identify"
    private let cell_footView_identify1:String = "YLFaceView.image.foot.identify"
    
    var didSelectBlock:((_ _index:Int?,_ _any:Any?)->Void)? = nil
    
    
    //MARK: - override
    init(frame: CGRect,
         collectionViewLayout layout: UICollectionViewLayout,
         andSelectIndex _si:Int) {
        self.selectIndex =  _si
        super.init(frame: .zero, collectionViewLayout: layout)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView(){
        self.dataSource = self
        self.delegate = self
        
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cell_identify)
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cell_identify1)
        self.register(UICollectionReusableView.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                      withReuseIdentifier: cell_footView_identify1)
    }
    
    /// 删除
    private lazy var btnRemove:UIButton = {
        let _img = UIImage(named: "delete_expression.jpg", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
        let btn = TGSUIModel.createBtn(rect: .zero,
                                       image: _img,
                                       backgroundColor: .white)
        
        btn.layer.cornerRadius = 8.5
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = TGSUIModel.createColorHexInt(0xEDEDED).cgColor
        
        btn.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            self.didSelectBlock?(nil,nil)
        }.disposed(by: rx.disposeBag)
        return btn
    }()
}

extension LoadDataViewController : JXSegmentedListContainerViewListDelegate {
    
    func listView() -> UIView {
        return self
    }
    
    func listDidAppear() {
        print("listDidAppear")
    }
    
    func listDidDisappear() {
        print("listDidDisappear-销毁了")
    }
}


//MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension LoadDataViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.selectIndex > 0 {
            return self.arrList?.count ?? 0
        }
        else{
            return self.emojiImages.count
        }
    }
    
    //组头尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    //组尾尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.selectIndex == 0 {
            return CGSize.init(width: 62.5, height: 41.5)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var collectionReusableView = UICollectionReusableView.init()
        
        //MARK: 组头
        if kind == UICollectionView.elementKindSectionHeader {
            
        }
        //MARK: 组尾
        else if kind == UICollectionView.elementKindSectionFooter {
            collectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,withReuseIdentifier: cell_footView_identify1,for: indexPath)
            
            if !collectionReusableView.subviews.contains(self.btnRemove){
                collectionReusableView.addSubview(self.btnRemove)
                self.btnRemove.snp.makeConstraints { make in
                    make.width.equalTo(52.5)
                    make.height.equalTo(41.5)
                    make.right.equalTo(-10)
                    make.top.equalTo(0)
                }
            }
        }
        
        return collectionReusableView
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell:UICollectionViewCell
        if self.selectIndex > 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell_identify1, for: indexPath)
            
            var _imgFace:UIImageView? = cell.contentView.viewWithTag(1232) as? UIImageView
            if _imgFace == nil {
                _imgFace = TGSUIModel.createImageView()
                _imgFace?.tag = 1232
                
                cell.contentView.addSubview(_imgFace!)
                _imgFace?.snp.makeConstraints { make in
                    make.size.equalTo(VXIUIConfig.shareInstance.faceImageSize())
                    make.top.equalTo(0)
                    make.centerX.equalToSuperview()
                }
            }
            
            var _labName:YYLabel? = cell.contentView.viewWithTag(1233) as? YYLabel
            if _labName == nil {
                _labName = TGSUIModel.createLable(rect: .zero,
                                                  textColor: TGSUIModel.createColorHexInt(0x424242),
                                                  font: .systemFont(ofSize: 12, weight: .regular),
                                                  andTextAlign: .center)
                _labName?.tag = 1233
                cell.contentView.addSubview(_labName!)
                _labName?.snp.makeConstraints({ make in
                    make.left.right.equalTo(0)
                    make.height.equalTo(16.5)
                    make.top.equalTo(_imgFace!.snp.bottom).offset(4)
                })
            }
            
            if (self.arrList?.count ?? 0) > indexPath.row {
                let _item = self.arrList![indexPath.row]
                _labName?.text = _item.title
                
                //图片
                if let _path = _item.path,_path.isEmpty == false,
                   let _url = URL.init(string: TGSUIModel.getFileRealUrlFor(Path: _path, andisThumbnail: true)) {
                    _imgFace?.yy_setImage(with: _url,
                                          placeholder: VXIUIConfig.shareInstance.cellDefaultImage(),
                                          options: VXIUIConfig.shareInstance.requestOption())
                }
            }
        }
        else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell_identify, for: indexPath)
            
            var _labFace:YYLabel? = cell.contentView.viewWithTag(1234) as? YYLabel
            if _labFace == nil {
                _labFace = TGSUIModel.createLable(rect: .zero,
                                                  font: UIFont.init(name: "AppleColorEmoji", size: VXIUIConfig.shareInstance.faceEmojiSize()),
                                                  backgroundColor: .clear,
                                                  andTextAlign: .center)
                _labFace?.tag = 1234
                
                cell.contentView.addSubview(_labFace!)
                _labFace?.snp.makeConstraints({ make in
                    make.edges.equalToSuperview()
                })
            }
            
            if self.emojiImages.count > indexPath.row {
                _labFace?.text = self.emojiImages[indexPath.row]
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer{
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        if self.selectIndex > 0 && (self.arrList?.count ?? 0) > indexPath.row {
            let _item = self.arrList![indexPath.row]
            
            //图片
            if let _path = _item.path,_path.isEmpty == false {
                self.didSelectBlock?(self.selectIndex,(_item.title ?? "自定义表情",_path))
            }
        }
        else {
            if self.emojiImages.count > indexPath.row {
                let _emoji = self.emojiImages[indexPath.row]
                self.didSelectBlock?(self.selectIndex,_emoji)
            }
        }
    }
    
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.selectIndex == 0 {
            return .init(width: VXIUIConfig.shareInstance.faceEmojiSize(), height: VXIUIConfig.shareInstance.faceEmojiSize())
        }
        else if (self.arrList?.count ?? 0) > indexPath.row {
            return VXIUIConfig.shareInstance.faceImageSize()
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: cell_margin, bottom: 0, right: cell_margin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if self.selectIndex == 0 {
            //每行7个
            return (VXIUIConfig.shareInstance.YLScreenWidth - 2  * cell_margin - 7 * VXIUIConfig.shareInstance.faceEmojiSize()) / 6
        }
        else if self.selectIndex > 0 {
            //每行5个
            return (VXIUIConfig.shareInstance.YLScreenWidth - 2  * cell_margin - 5 * VXIUIConfig.shareInstance.faceImageSize().width) / 4
        }
        return 0
    }
}

