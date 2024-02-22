//
//  ChatEvaluatCell.swift
//  Tool
//
//  Created by apple on 2024/1/17.
//

import UIKit
import SnapKit
import RxSwift
@_implementationOnly import VisionCCiOSSDKEngine

//MARK: 满意度气泡消息
class ChatEvaluatCell: BaseChatCell {
    
    weak var viewModel:VXIChatViewModel?
    
    private let view_margin:CGFloat = 10
    private let parent_view_width:CGFloat = 220.5
    private let cell_identify:String = "EvaluateBoxView.identify"
    private let section_foot_identify:String = "EvaluateBoxView.foot.identify"
    private let section_head_identify:String = "EvaluateBoxView.head.identify"
    private let start_size:CGSize = .init(width: 22, height: 21.08)
    
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
                make.width.equalTo(parent_view_width)
                make.height.equalTo(250)
                make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                make.top.equalTo(self.messageAvatarsImageView.snp.top)
                make.left.equalTo(self.messageAvatarsImageView.snp.right).offset(VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
            }
        }
        
        if self.parentView.subviews.contains(self.listCollectionView){
            self.listCollectionView.snp.makeConstraints { make in
                make.left.right.bottom.equalTo(0)
                make.top.equalTo(10)
            }
        }
        
        super.updateConstraints()
    }
    
    private func initView(){
        self.contentView.addSubview(self.parentView)
        self.parentView.addSubview(self.listCollectionView)
        
        setNeedsUpdateConstraints()
    }
    
    
    //MARK: 绑定数据
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        
        self.labelsIndex = nil
        self.satisfactionId = nil
        self.evaluateIndex = 0
        self.txtView.text = nil
        self.labPlace.isHidden = false
        self.labFootCount.text = "0/\(VXIUIConfig.shareInstance.getStarMaxComment())"
        
        /// 获取回显数据
        self.viewModel?.evaluatFeedbackDataPublishSubject.subscribe {[weak self] (_input:Event<Any>) in
            guard let self = self else { return }
            guard let (_isOK,_result,_mid) = _input.element as? (Bool,Any?,Int64) else { return }
            if _isOK,m.mId == _mid,let _r = _result as? EvaluatResultModel,(_r.options?.count ?? 0) > 0 {
                if let _index = self.arrData?.firstIndex(where: { $0.optionsScore == _r.main?.score }) {
                    self.labelsIndex = self.arrData![_index].labels?.firstIndex(where: { $0.labelsName == _r.options?.first?.optionsName }) ?? 0
                    self.evaluateIndex = _index
                    self.txtView.text = _r.main?.comment
                    self.satisfactionId = _r.main?.satisfactionId
                    self.labPlace.isHidden = true
                    self.labFootCount.text = "\(self.txtView.text.count)/\(VXIUIConfig.shareInstance.getStarMaxComment())"
                    print("气泡满意度消息，数据已回显！\(_r)")
                }
            }
        }.disposed(by: rx.disposeBag)
        
        //最大个数
        let _max = m.messageBody?.satisfactionOptions?.count ?? 5
        UserDefaults.standard.setValue(_max,
                                       forKey: VXIUIConfig.shareInstance.getEvaluatMaxStarKey())
        
        //标题
        self.labTitle.text = m.messageBody?.titleWord
        
        //评价数据
        self.stfTemplateId = m.messageBody?.stfTemplateId
        self.arrData = m.messageBody?.satisfactionOptions
        
        //是否可以评价
        if let _ct = m.createTime,let _vp = m.messageBody?.validPeriod {
            self.isEnable = !(TGSUIModel.localUnixTimeDouble() - _ct > Double(_vp * 60 * 1000))
        }
        layoutIfNeeded()
    }
    
    //MARK: - lazy load
    private lazy var parentView:UIView = {[unowned self] in
        let _v = TGSUIModel.createView()
        _v.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
        
        //长按事件
        let _longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(bassCellLongPressAction(sender:)))
        _v.addGestureRecognizer(_longPress)
        _v.isUserInteractionEnabled = true
        
        return _v
    }()
    
    /// 评价索引
    private lazy var evaluateIndex:Int = 0 {
        didSet{
            if (self.arrData?.count ?? 0) > self.evaluateIndex {
                self.labSelectSourceInfo.text = self.arrData?[self.evaluateIndex].optionsName
                self.listCollectionView.reloadData()
                self.listCollectionView.layoutIfNeeded()
                
                //更新高度
                let _h:CGFloat = self.listCollectionView.contentSize.height + 10
                self.parentView.snp.remakeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.height.equalTo(_h)
                    make.width.equalTo(parent_view_width)
                    make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                    make.top.equalTo(self.messageAvatarsImageView.snp.top)
                    if MessageDirection.init(rawValue: self.message?.renderMemberType ?? 0).isSend() == true {
                        make.right.equalTo(self.messageAvatarsImageView.snp.left).offset(-VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
                    }
                    else{
                        make.left.equalTo(self.messageAvatarsImageView.snp.right).offset(VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
                    }
                }
                layoutIfNeeded()
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
        layout.dicSpaceBetweenColumns = [0:4]
        
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
                                      text: "您好，请对本次服务进行评价。",
                                      textColor: UIColor.init().colorFromHexInt(hex: 0x424242),
                                      font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                      andTextAlign: .left)
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
                                        txtFont: UIFont.systemFont(ofSize: 15, weight: .regular),
                                        image: nil,
                                        backgroundColor: VXIUIConfig.shareInstance.getStarSelectColor())
        
        _btn.layer.cornerRadius = 4
        _btn.contentHorizontalAlignment = .center
        
        _btn.rx.safeTap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            self.btnSutmitAction()
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
    
    /// 存在 修改评价，反之 新增
    private lazy var satisfactionId:Int64? = nil
}


//MARK: -
extension ChatEvaluatCell {
    
    //MARK: 评分星星
    /// 创建星星
    private func createStartButtonFor(View _v:UIView){
        
        let _margin_left_right:CGFloat = 23.5
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
                
                let _margin:CGFloat = (parent_view_width - CGFloat(2) * _margin_left_right - CGFloat(VXIUIConfig.shareInstance.getMaxStar()) * start_size.width) / CGFloat(VXIUIConfig.shareInstance.getMaxStar() - 1)
                let _left:CGFloat = _margin_left_right + CGFloat(i) * (start_size.width + _margin)
                
                btnStart?.snp.makeConstraints({[weak self] make in
                    guard let self = self else { return }
                    make.size.equalTo(start_size)
                    make.top.equalTo(30.5)
                    
                    if i == 0 {
                        make.left.equalTo(_margin_left_right)
                    }
                    else if i == VXIUIConfig.shareInstance.getMaxStar() - 1 {
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
        for i in 0..<VXIUIConfig.shareInstance.getMaxStar() {
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
    
    
    //MARK: 提交评价
    /// 提交评价(新增/修改)
    private func btnSutmitAction(){
        if self.isEnable == false {
            print("当前评价时效过期，不可评价")
            return
        }
        
        if self.txtView.text.replacingOccurrences(of: " ", with: "").count <= 0 {
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "请输入内容后再试")
            return
        }
        
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
        
        let _dicTemp = [
            //满意度设置id
            "stfTemplateId":self.stfTemplateId ?? 0,
            //得分
            "score":_source,
            //满意度评价内容
            "comment":self.txtView.text.replacingOccurrences(of: " ", with: "")
        ] as [String : Any]
        
        //新增
        if self.satisfactionId == nil || (self.satisfactionId ?? 0) <= 0 {
            self.viewModel?.evaluatSubmitPublishSubject.onNext((false,
                                                                message?.sessionId ?? "",
                                                                message?.messageBody?.pushType ?? 2,
                                                                _dicTemp,
                                                                _options,
                                                                message?.mId ?? 0))
        }
        //修改
        else{
            self.viewModel?.evaluatupUpdatePublishSubject.onNext((self.satisfactionId!,
                                                                  false,
                                                                  message?.sessionId ?? "",
                                                                  message?.messageBody?.pushType ?? 2,
                                                                  _dicTemp,
                                                                  _options,
                                                                  message?.mId ?? 0))
        }
    }
    
}

//MARK: - UITextViewDelegate
extension ChatEvaluatCell : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let length = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count
        let strLength = text.lengthOfBytes(using: String.Encoding.utf8)
        
        let _max = VXIUIConfig.shareInstance.getStarMaxComment()
        if strLength > 0 && text != "\n" && text != " " {
            self.labPlace.isHidden = true
        }
        else if strLength <= 0 && range.location <= 0 {
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
                self.btnSutmitAction()
            }.disposed(by: rx.disposeBag)
            return false
        }
        
        return true
    }
    
}



//MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension ChatEvaluatCell : UICollectionViewDelegate,UICollectionViewDataSource,SectionBgCollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    //组头尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize.init(width: parent_view_width, height: 82)
        }
        return .zero
    }
    
    //组尾尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 2 {
            return CGSize.init(width: parent_view_width, height: 129)
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
                    make.right.equalTo(-view_margin)
                    make.height.equalTo(20)
                    make.top.equalTo(0)
                }
            }
            
            //评分星
            self.createStartButtonFor(View: collectionReusableView)
            
            //描述
            if collectionReusableView.subviews.contains(self.labSelectSourceInfo) == false {
                collectionReusableView.addSubview(self.labSelectSourceInfo)
                self.labSelectSourceInfo.snp.makeConstraints { make in
                    make.left.right.equalTo(0)
                    make.height.equalTo(14)
                    make.bottom.equalTo(-10)
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
                    make.height.equalTo(29)
                    make.bottom.equalTo(-10)
                }
            }
            
            if collectionReusableView.subviews.contains(self.txtView) == false {
                collectionReusableView.addSubview(self.txtView)
                self.txtView.snp.makeConstraints { make in
                    make.left.equalTo(view_margin)
                    make.right.equalTo(-view_margin)
                    make.height.equalTo(80)
                    make.bottom.equalTo(-49)
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
            if _w > parent_view_width - 2 * view_margin {
                _w = parent_view_width - 2 * view_margin
            }
            return .init(width: _w,
                         height: VXIUIConfig.shareInstance.getStarCellHeight())
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            return UIEdgeInsets.init(top: 0, left: view_margin, bottom: 10, right: view_margin)
        }
        return .zero
    }
    
    //行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return VXIUIConfig.shareInstance.getStarCellRowMargin()
    }
    
    //列间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, backgroundColorForSectionAt section: Int) -> UIColor {
        return .clear
    }
    
}



//MARK: - EvaluatCollectionViewCell
class EvaluatCollectionViewCell : UICollectionViewCell {
    
    //MARK: - override
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        if self.contentView.subviews.contains(self.labTitle) {
            self.labTitle.snp.makeConstraints({ make in
                make.edges.equalToSuperview()
            })
        }
        
        super.updateConstraints()
    }
    
    private func initView(){
        self.contentView.addSubview(self.labTitle)
        
        setNeedsUpdateConstraints()
    }
    
    //MARK: lazy load
    /// 标题
    private lazy var labTitle:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: nil,
                                          textColor: UIColor.init().colorFromHexInt(hex: 0x424242),
                                          font: VXIUIConfig.shareInstance.getStarCellFont(),
                                          andTextAlign: .center,
                                          andisdisplaysAsync: false)
        _lab.layer.cornerRadius = VXIUIConfig.shareInstance.getStarCellHeight() * 0.5
        _lab.layer.borderWidth = 0.5
        _lab.layer.borderColor = UIColor.init().colorFromHexInt(hex: 0xBDBDBD).cgColor
        _lab.numberOfLines = 1
        _lab.lineBreakMode = .byTruncatingTail
        
        return _lab
    }()
    
}


//MARK: -
extension EvaluatCollectionViewCell {
    
    /// 数据绑定
    /// - Parameters:
    ///   - _t: 文案
    ///   - _isSelect: true 标签选中
    func bindValueFor(Text _t:String?,
                      andisSelect _isSelect:Bool) {
        self.labTitle.text = _t
        
        self.labTitle.backgroundColor = _isSelect ? VXIUIConfig.shareInstance.getStarSelectColor() : UIColor.clear
        self.labTitle.textColor = _isSelect ? .white : UIColor.init().colorFromHexInt(hex: 0x424242)
        self.labTitle.layer.borderColor = _isSelect ? VXIUIConfig.shareInstance.getStarSelectColor().cgColor : UIColor.init().colorFromHexInt(hex: 0xBDBDBD).cgColor
    }
}
