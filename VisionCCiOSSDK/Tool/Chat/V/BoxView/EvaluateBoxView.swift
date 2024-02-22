//
//  EvaluateBoxView.swift
//  Tool
//
//  Created by apple on 2024/1/2.
//

import UIKit
import RxSwift
import SnapKit
@_implementationOnly import VisionCCiOSSDKEngine


/// 满意度消息
class EvaluateBoxView: UIView {
    
    /// 关闭
    var closeBlock:(()->Void)?
    
    /// 提交事件
    /// _pushType:满意度推送类型，0：未知，1：系统自动推送，2：访客主动评价，4：坐席主动推送
    /// _dicMain:[String:Any]
    var submitBlock:((_ _pushType:Int,
                      _ _dicMain:[String:Any],
                      _ _dicOptions:[String:Any],
                      _ _mid:Int64,
                      _ _sessionId:String?)->Void)?
    
    private var viewModel:VXIChatViewModel?
    private var isNewViewController:Bool = false
    
    private let view_margin:CGFloat = 15
    private let start_size:CGSize = .init(width: 32, height: 30.67)
    
    private let cell_identify:String = "EvaluateBoxView.identify"
    private let section_foot_identify:String = "EvaluateBoxView.foot.identify"
    private let section_head_identify:String = "EvaluateBoxView.head.identify"
    
    
    //MARK: - override
    init(isNewViewController _isNew:Bool = false,
         andViewModel _vm:VXIChatViewModel) {
        var _frame:CGRect = .zero
        if _isNew == false {
            let _h:CGFloat = 315.5 + VXIUIConfig.shareInstance.xp_safeDistanceBottom()
            _frame = .init(origin: .zero, size: .init(width: VXIUIConfig.shareInstance.YLScreenWidth, height: _h))
        }
        super.init(frame: _frame)
        self.viewModel = _vm
        self.isNewViewController = _isNew
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        if self.subviews.contains(self.listCollectionView){
            self.listCollectionView.snp.makeConstraints { make in
                make.left.right.equalTo(0)
                make.top.equalTo(view_margin)
                make.height.greaterThanOrEqualTo(231)
                make.bottom.equalTo(-VXIUIConfig.shareInstance.xp_safeDistanceBottom())
            }
        }
        
        super.updateConstraints()
    }
    
    private func initView(){
        self.backgroundColor = .white
        self.bindViewModel()
        
        if !self.isNewViewController {
            TGSUIModel.addCornerFor(View: self,
                                    andCorners: [.topLeft,.topRight],
                                    widthRadius: 10,
                                    heightRadius: 10)
            
        }
        
        self.addSubview(self.listCollectionView)
        VXIUIConfig.shareInstance.initConfigThreadLabs()
        
        setNeedsUpdateConstraints()
    }
    
    private func bindViewModel(){
        /// 加载默认配置
        self.viewModel?.evaluatLoadConfigPublishSubject.subscribe({[weak self] (_input:Event<Any>) in
            guard let self = self else { return }
            guard let (_isOK,_any,_msg) = _input.element as? (Bool,EvaluatModel,String) else { return }
            if _isOK {
                self.setValueFor(Data: _any.options,
                                 andSTFTemplateId: _any.stfTemplateId,
                                 withTitle: _any.titleWord,
                                 andPushType: self.pushType,
                                 andMessageid: nil,
                                 andSessionid: nil)
            }
            else{
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
            }
        }).disposed(by:rx.disposeBag)
    }
    
    
    //MARK: - lazy load
    /// 0：未知，1：系统自动推送，2：访客主动评价，4：坐席主动推送
    private lazy var pushType:Int = 2
    
    /// 消息编号
    private lazy var messageId:Int64? = nil
    
    private lazy var sessionId:String? = nil
    
    /// 评价索引
    private lazy var evaluateIndex:Int = 0 {
        didSet{
            if (self.arrData?.count ?? 0) > self.evaluateIndex {
                self.labSelectSourceInfo.text = self.arrData?[self.evaluateIndex].optionsName
                self.listCollectionView.reloadData()
                self.listCollectionView.layoutIfNeeded()
                
                //[S]高度更新
                let _h:CGFloat = view_margin + VXIUIConfig.shareInstance.xp_safeDistanceBottom() + self.listCollectionView.contentSize.height
                self.frame = .init(origin: .init(x: 0, y: VXIUIConfig.shareInstance.YLScreenHeight - _h), size: .init(width: VXIUIConfig.shareInstance.YLScreenWidth, height: _h))
                //[E]
            }
        }
    }
    
    /// 满意度设置id(提交需要用到)
    private lazy var stfTemplateId:Int64? = nil
    private lazy var arrData:[EvaluatOptionsModel]? = nil {
        didSet{
            self.listCollectionView.reloadData()
        }
    }
    
    /// 评价Labels 选中索引
    private lazy var labelsIndex:Int? = nil
    
    /// 列表
    private lazy var listCollectionView:UICollectionView = {[unowned self] in
        let layout = SectionBgCollectionViewLayout.init()
        layout.scrollDirection = .vertical
        layout.dicSpaceBetweenColumns = [0:6]
        
        let _m = UICollectionView.init(frame: CGRect.zero,
                                       collectionViewLayout: layout)
        
        _m.backgroundColor = .clear
        _m.isScrollEnabled = false
        _m.showsVerticalScrollIndicator = false
        _m.showsHorizontalScrollIndicator = false
        
        _m.delegate = self
        _m.dataSource = self
        
        if #available(iOS 13.0, *) {
            _m.automaticallyAdjustsScrollIndicatorInsets = false
        }
        
        if #available(iOS 11.0, *) {
            _m.contentInsetAdjustmentBehavior = .never
        }
        
        //注册列
        _m.register(EvaluatCollectionViewCell.classForCoder(),
                    forCellWithReuseIdentifier: cell_identify)
        
        //注册组头尾
        _m.register(UICollectionReusableView.classForCoder(),
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: section_head_identify)
        _m.register(UICollectionReusableView.classForCoder(),
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                    withReuseIdentifier: section_foot_identify)
        
        return _m
    }()
    
    //MARK: 头部视图
    /// 标题
    private lazy var labTitle:YYLabel = {
        return TGSUIModel.createLable(rect: .zero,
                                      text: "您好，请对本次服务进行评价",
                                      textColor: UIColor.init().colorFromHexInt(hex: 0x424242),
                                      font: UIFont.systemFont(ofSize: 18, weight: .regular),
                                      andTextAlign: .left)
    }()
    
    /// 关闭
    private lazy var btnClose:UIButton = {[unowned self] in
        let _img:UIImage? = TGSUIModel.imageForBuncle(Class: nil,
                                                      andBundleName: VXIUIConfig.shareInstance.getConfigBundleName(),
                                                      withImageName: "tool_close_small.png",
                                                      andImagesFileName: nil)
        let _btn = TGSUIModel.createBtn(rect: .zero,
                                        image: _img,
                                        backgroundImage: nil)
        _btn.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            self.closeBlock?()
        }.disposed(by: rx.disposeBag)
        
        return _btn
    }()
    
    /// 选中评分描述
    private lazy var labSelectSourceInfo:YYLabel = {
        return TGSUIModel.createLable(rect: .zero,
                                      text: "非常不满意",
                                      textColor: UIColor.init().colorFromHexInt(hex: 0x9E9E9E),
                                      font: UIFont.systemFont(ofSize: 10, weight: .regular),
                                      andTextAlign: .center)
    }()
    
    //MARK: 尾部视图
    private lazy var isEnable:Bool = false {
        didSet{
            self.btnSubmit.backgroundColor = self.isEnable ? VXIUIConfig.shareInstance.getStarSelectColor() : UIColor.init().colorFromHexInt(hex: 0xF2F2F2)
            self.btnSubmit.setTitleColor(self.isEnable ? .white : UIColor.init().colorFromHexInt(hex: 0x9E9E9E), for: .normal)
        }
    }
    
    /// 提交
    private lazy var btnSubmit:UIButton = {[unowned self] in
        let _btn = TGSUIModel.createBtn(rect: .zero,
                                        strTitle: "提交",
                                        titleColor: .white,
                                        txtFont: UIFont.systemFont(ofSize: 18, weight: .regular),
                                        image: nil,
                                        backgroundColor: VXIUIConfig.shareInstance.getStarSelectColor())
        
        _btn.layer.cornerRadius = 4
        _btn.contentHorizontalAlignment = .center
        
        _btn.rx.safeTap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            self.btnSubmitAction()
        }.disposed(by: rx.disposeBag)
        
        return _btn
    }()
    
    /// 文本框
    public private(set) lazy var txtView:UITextView = {[unowned self] in
        let _txt = UITextView.init(frame:.init(x: 0, y: 0, width: VXIUIConfig.shareInstance.YLScreenWidth - 2 * view_margin, height: 80))
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
        self.labPlace.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.height.equalTo(20)
            make.right.equalTo(-10)
            make.top.equalTo(5)
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
extension EvaluateBoxView {
    
    /// 设置数据
    /// - Parameters:
    ///   - _d: [EvaluatOptionsModel]?
    ///   - _stfTemplateId: Int64? stfTemplateId
    ///   - _titleWord: String? titleWord
    ///   - _pt: 0：未知，1：系统自动推送，2：访客主动评价，4：坐席主动推送
    public func setValueFor(Data _d:[EvaluatOptionsModel]?,
                            andSTFTemplateId _stfTemplateId:Int64?,
                            withTitle _titleWord:String?,
                            andPushType _pt:Int = 2,
                            andMessageid _mid:Int64?,
                            andSessionid _sid:String?) {
        //最大个数
        let _max = _d?.count ?? 5
        UserDefaults.standard.setValue(_max,
                                       forKey: VXIUIConfig.shareInstance.getEvaluatMaxStarKey())
        
        //标题
        self.labTitle.text = _titleWord
        self.messageId = _mid
        self.sessionId = _sid
        
        //评价数据
        self.evaluateIndex = 0
        self.pushType = _pt
        self.stfTemplateId = _stfTemplateId
        self.arrData = _d
    }
    
    //还原初始化状态
    public func preView(){
        self.txtView.text = nil
        self.evaluateIndex = 0
        self.listCollectionView.reloadData()
    }
    
    
    //MARK: 评分星星
    /// 创建星星
    private func createStartButtonFor(View _v:UIView){
        
        let _margin_left_right:CGFloat = 63.5
        let max_lengt = VXIUIConfig.shareInstance.getMaxStar()
        for i in 0..<max_lengt {
            let tag:Int = VXIUIConfig.shareInstance.getStarBeginTag() + i
            var btnStart:UIButton? = _v.viewWithTag(tag) as? UIButton
            
            let _img_name:String = self.evaluateIndex >= i ? "evaluate_start_hover.png":"evaluate_start.png"
            let _img:UIImage? = TGSUIModel.imageForBuncle(Class: nil,
                                                          andBundleName: VXIUIConfig.shareInstance.getConfigBundleName(),
                                                          withImageName: _img_name,
                                                          andImagesFileName: nil)
            
            if btnStart == nil {
                btnStart = TGSUIModel.createBtn(rect: .zero,
                                                image: nil,
                                                backgroundImage: _img)
                btnStart?.tag = tag
                _v.addSubview(btnStart!)
                
                let _margin:CGFloat = (VXIUIConfig.shareInstance.YLScreenWidth - CGFloat(2) * _margin_left_right - CGFloat(max_lengt) * start_size.width) / CGFloat(max_lengt - 1)
                let _left:CGFloat = _margin_left_right + CGFloat(i) * (start_size.width + _margin)
                
                btnStart?.snp.makeConstraints({[weak self] make in
                    guard let self = self else { return }
                    make.size.equalTo(start_size)
                    make.top.equalTo(50)
                    
                    if i == 0 {
                        make.left.equalTo(_margin_left_right)
                    }
                    else if i == max_lengt - 1 {
                        make.right.equalTo(-_margin_left_right)
                    }
                    else {
                        make.left.equalTo(_left)
                    }
                })
                
                btnStart?.addTarget(self, action: #selector(btnStartAction(sender:)), for: .touchUpInside)
            }
            
            btnStart?.setBackgroundImage(_img, for: .normal)
        }
    }
    
    /// 点击
    @IBAction private func btnStartAction(sender:UIButton) {
        let _view:UIView? = sender.superview
        self.evaluateIndex = sender.tag - VXIUIConfig.shareInstance.getStarBeginTag()
        for i in 0..<VXIUIConfig.shareInstance.getStarBeginTag() {
            if let _btn = _view?.viewWithTag(VXIUIConfig.shareInstance.getStarBeginTag() + i) as? UIButton {
                let _img_name:String = _btn.tag <= sender.tag ? "evaluate_start_hover.png":"evaluate_start.png"
                let _img:UIImage? = TGSUIModel.imageForBuncle(Class: nil,
                                                              andBundleName: VXIUIConfig.shareInstance.getConfigBundleName(),
                                                              withImageName: _img_name,
                                                              andImagesFileName: nil)
                _btn.setBackgroundImage(_img, for: .normal)
            }
        }
    }
    
    
    //MARK: 提交
    /// 提交事件
    private func btnSubmitAction(){
//        if self.isEnable == false || self.txtView.text.replacingOccurrences(of: " ", with: "").count <= 0 {
//            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "请输入内容后再试")
//            return
//        }
        
        guard let _option = self.arrData?[self.evaluateIndex],(self.arrData?.count ?? 0) > self.evaluateIndex else {
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "Options内容不存在")
            return
        }
        
        var _options = TGSUIModel.getDicDataFor(Data: try? JSONEncoder.init().encode(_option))
        if _options == nil {
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "Options内容不存在")
            return
        }
        
        _options?["choosedValues"] = _option.labels?.map({ $0.stfLabelsId })
        _options?["choosedNames"] = _option.labels?.map({ $0.labelsName })
        _options?["optionsIcon"] = nil
        _options?["optionsScore"] = nil
        
        //得分
        let _source = _option.optionsScore ?? 1
        
        self.submitBlock?(self.pushType,
                          [
                            //满意度设置id
                            "stfTemplateId":self.stfTemplateId ?? 0,
                            //得分
                            "score":_source,
                            //满意度评价内容
                            "comment":self.txtView.text.replacingOccurrences(of: " ", with: "")
                          ],
                          _options!,
                          self.messageId ?? 0,
                          self.sessionId
        )
        
    }
}


//MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension EvaluateBoxView : UICollectionViewDelegate,UICollectionViewDataSource,SectionBgCollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    //组头尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize.init(width: VXIUIConfig.shareInstance.YLScreenWidth, height: 124.5)
        }
        return .zero
    }
    
    //组尾尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 2 {
            return CGSize.init(width: VXIUIConfig.shareInstance.YLScreenWidth, height: 158)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var collectionReusableView = UICollectionReusableView.init()
        
        //MARK: 组头
        if kind == UICollectionView.elementKindSectionHeader {
            collectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,withReuseIdentifier: section_head_identify,for: indexPath)
            
            //标题
            if collectionReusableView.subviews.contains(self.labTitle) == false {
                collectionReusableView.addSubview(self.labTitle)
                self.labTitle.snp.makeConstraints { make in
                    make.left.equalTo(view_margin)
                    make.right.equalTo(-50)
                    make.height.equalTo(25)
                    make.top.equalTo(0)
                }
            }
            
            //关闭
            if !self.isNewViewController {
                if collectionReusableView.subviews.contains(self.btnClose) == false {
                    collectionReusableView.addSubview(self.btnClose)
                    self.btnClose.snp.makeConstraints {[weak self] make in
                        guard let self = self else { return }
                        make.width.height.equalTo(40)
                        make.right.equalTo(-5)
                        make.centerY.equalTo(self.labTitle.snp.centerY)
                    }
                }
            }
            
            //评分星
            self.createStartButtonFor(View: collectionReusableView)
            
            //描述
            if collectionReusableView.subviews.contains(self.labSelectSourceInfo) == false {
                collectionReusableView.addSubview(self.labSelectSourceInfo)
                self.labSelectSourceInfo.snp.makeConstraints { make in
                    make.left.right.equalTo(0)
                    make.height.equalTo(20.5)
                    make.bottom.equalTo(-16)
                }
            }
        }
        //MARK: 组尾
        else if kind == UICollectionView.elementKindSectionFooter {
            collectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,withReuseIdentifier: section_foot_identify,for: indexPath)
            
            if collectionReusableView.subviews.contains(self.btnSubmit) == false {
                collectionReusableView.addSubview(self.btnSubmit)
                self.btnSubmit.snp.makeConstraints { make in
                    make.left.equalTo(view_margin)
                    make.right.equalTo(-view_margin)
                    make.height.equalTo(42)
                    make.bottom.equalTo(-10)
                }
            }
            
            if collectionReusableView.subviews.contains(self.txtView) == false {
                collectionReusableView.addSubview(self.txtView)
                self.txtView.snp.makeConstraints { make in
                    make.left.equalTo(view_margin)
                    make.right.equalTo(-view_margin)
                    make.height.equalTo(80)
                    make.bottom.equalTo(-62)
                }
            }
            
            if collectionReusableView.subviews.contains(self.labFootCount) == false {
                collectionReusableView.addSubview(self.labFootCount)
                self.labFootCount.snp.makeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.left.equalTo(view_margin)
                    make.right.equalTo(-view_margin-6)
                    make.height.equalTo(16.5)
                    make.bottom.equalTo(self.txtView.snp.bottom).offset(-6)
                }
            }
        }
        
        return collectionReusableView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 && (self.arrData?.count ?? 0) > self.evaluateIndex,
           let _arrLabels = self.arrData?[self.evaluateIndex].labels  {
            return _arrLabels.count
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell_identify, for: indexPath)
        if indexPath.section == 1 && (self.arrData?.count ?? 0) > self.evaluateIndex,
           let _arrLabels = self.arrData?[self.evaluateIndex].labels,_arrLabels.count > indexPath.row  {
            let _item:EvaluatLabelModel = _arrLabels[indexPath.row]
            (cell as? EvaluatCollectionViewCell)?.bindValueFor(Text: _item.labelsName, andisSelect: self.labelsIndex == indexPath.row)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        defer {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        
        self.labelsIndex = indexPath.row
        collectionView.reloadData()
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1 && (self.arrData?.count ?? 0) > self.evaluateIndex,
           let _arrLabels = self.arrData?[self.evaluateIndex].labels,_arrLabels.count > indexPath.row  {
            let _item:EvaluatLabelModel = _arrLabels[indexPath.row]
            var _w:CGFloat = (_item.labelsName ?? "").yl_getWidthFor(Font:VXIUIConfig.shareInstance.getStarCellFont()) + 15
            if _w > VXIUIConfig.shareInstance.YLScreenWidth - 2 * view_margin {
                _w = VXIUIConfig.shareInstance.YLScreenWidth - 2 * view_margin
            }
            return .init(width: _w,
                         height: VXIUIConfig.shareInstance.getStarCellHeight())
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            return UIEdgeInsets.init(top: 0, left: view_margin, bottom: 0, right: view_margin)
        }
        return .zero
    }
    
    //行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return VXIUIConfig.shareInstance.getStarCellRowMargin()
    }
    
    //列间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, backgroundColorForSectionAt section: Int) -> UIColor {
        return .clear
    }
    
}


//MARK: - UITextViewDelegate
extension EvaluateBoxView : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let length = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count
        let strLength = text.lengthOfBytes(using: String.Encoding.utf8)
        
        let _max = VXIUIConfig.shareInstance.getStarMaxComment()
        if strLength > 0 && text != "\n" && text != " " {
            //self.isEnable = true
            self.labPlace.isHidden = true
        }
        else if strLength <= 0 && range.location <= 0 {
            //self.isEnable = false
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
            //1.5秒
            textView.rx.text.debounce(.microseconds(1500), scheduler: MainScheduler.instance).subscribe {[weak self] (_input:Event<String?>) in
                guard let self = self else { return }
                self.btnSubmitAction()
            }.disposed(by: rx.disposeBag)
            
            return false
        }
        
        return true
    }
    
}
