//
//  LeaveMessageBoxView.swift
//  Tool
//
//  Created by apple on 2024/1/4.
//

import UIKit
import SnapKit
import RxSwift
@_implementationOnly import VisionCCiOSSDKEngine

/// 留言自定义视图
class LeaveMessageBoxView: UIView {
    
    /// 关闭
    var closeBlock:(()->Void)?
    var sessionId:String?  //需要传值指定
    var messageId:Int64?   //留言按钮对应的消息Id
    
    private weak var viewModel:VXIChatViewModel?
    
    private let view_start_tag:Int = 2024
    private let view_margin:CGFloat = 15
    private let view_txt_file_height:CGFloat = 35
    private let view_title_height:CGFloat = 22
    private let view_txt_bottom:CGFloat = -88 - VXIUIConfig.shareInstance.xp_safeDistanceBottom()
    private let view_title_read_color:UIColor = .init().colorFromHexInt(hex: 0xFA5151)
    private let view_txt_border_color:CGColor = UIColor.init().colorFromHexInt(hex: 0xE0E0E0).cgColor
    
    //MARK: init
    init(ViewModel _vm:VXIChatViewModel){
        self.viewModel = _vm
        let _h:CGFloat = 397 + VXIUIConfig.shareInstance.xp_safeDistanceBottom()
        let _frame:CGRect = .init(origin: .zero, size: .init(width: VXIUIConfig.shareInstance.YLScreenWidth, height: _h))
        super.init(frame: _frame)
        self.initView()
        
        //[S]加载默认配置数据
        if let _d = String.readLocalCacheDataWithKey(key: VXIUIConfig.shareInstance.getLeaveMessageDefaultKey()) {
            do{
                let _result = try JSONDecoder.init().decode(LeaveMessageModel.self, from: _d)
                self.dedfaultMode = _result
            }
            catch(let _error){
                debugPrint(_error)
            }
        }
        //[E]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        if self.subviews.contains(self.labTitle){
            self.labTitle.snp.makeConstraints { make in
                make.left.equalTo(view_margin)
                make.right.equalTo(-50)
                make.height.equalTo(25)
                make.top.equalTo(15)
            }
        }
        
        if self.subviews.contains(self.btnClose){
            self.btnClose.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.height.equalTo(40)
                make.right.equalTo(-5)
                make.centerY.equalTo(self.labTitle.snp.centerY)
            }
        }
        
        //MARK: 留言、附件
        if self.subviews.contains(self.labMessageTitle){
            self.labMessageTitle.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(view_margin)
                make.right.equalTo(-view_margin)
                make.height.equalTo(view_title_height)
                make.bottom.equalTo(self.txtMessage.snp.top).offset(-10)
            }
        }
        
        if self.subviews.contains(self.txtMessage){
            self.txtMessage.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(view_margin)
                make.right.equalTo(-view_margin)
                make.height.equalTo(80)
                make.bottom.equalTo(view_txt_bottom)
            }
        }
        
        if self.subviews.contains(self.btnAnnex){
            self.btnAnnex.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(view_margin)
                make.height.equalTo(20)
                make.width.equalTo(18.6)
                make.bottom.equalTo(view_txt_bottom + 24)
            }
        }
        
        if self.subviews.contains(self.labAnnexName){
            self.labAnnexName.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(view_margin)
                make.height.equalTo(20)
                make.centerY.equalTo(self.btnRemove.snp.centerY)
                make.right.equalTo(self.btnRemove.snp.left).offset(-11)
            }
        }
        
        if self.subviews.contains(self.btnRemove){
            self.btnRemove.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.right.equalTo(-view_margin)
                make.height.equalTo(14)
                make.width.equalTo(13.3)
                make.centerY.equalTo(self.btnAnnex.snp.centerY)
            }
        }
        
        //MARK: 提交
        if self.subviews.contains(self.labFootCount){
            self.labFootCount.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(view_margin)
                make.right.equalTo(-view_margin-6)
                make.height.equalTo(16.5)
                make.bottom.equalTo(view_txt_bottom - 6)
            }
        }
        
        if self.subviews.contains(self.btnSubmit){
            self.btnSubmit.snp.makeConstraints { make in
                make.left.equalTo(view_margin)
                make.right.equalTo(-view_margin)
                make.height.equalTo(42)
                make.bottom.equalTo(-10-VXIUIConfig.shareInstance.xp_safeDistanceBottom())
            }
        }
        
        super.updateConstraints()
    }
    
    private func initView(){
        self.backgroundColor = .white
        self.bindValueModel()
        
        TGSUIModel.addCornerFor(View: self,
                                andCorners: [.topLeft,.topRight],
                                widthRadius: 10,
                                heightRadius: 10)
        
        self.addSubview(self.labTitle)
        self.addSubview(self.btnClose)
        
        self.addSubview(self.btnAnnex)
        self.addSubview(self.labAnnexName)
        self.addSubview(self.btnRemove)
        
        self.addSubview(self.labFootCount)
        self.addSubview(self.btnSubmit)
        
        setNeedsUpdateConstraints()
    }
    
    //MARK: bindValueModel
    private func bindValueModel(){
        
        /// 默认配置结果
        self.viewModel?.leaveMessageLoadConfigPublishSubject.subscribe({[weak self] (_input:Event<Any>) in
            guard let self = self else { return }
            guard let (_isOK,_any,_msg) = _input.element as? (Bool,Any,String) else { return }
            if _isOK,let _m =  _any as? LeaveMessageModel {
                self.dedfaultMode = _m
            }
            else{
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    
    //MARK: - lazy load
    /// 默认配置模型
    private lazy var dedfaultMode:LeaveMessageModel? = nil {
        didSet{
            self.createSubView()
        }
    }
    
    /// 标题
    private lazy var labTitle:YYLabel = {
        return TGSUIModel.createLable(rect: .zero,
                                      text: "请留言，我们将尽快联系您。",
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
    
    //MARK: 留言内容
    /// 字数统计
    private lazy var labFootCount:YYLabel = {
        return TGSUIModel.createLable(rect: .zero,
                                      text: "0/100",
                                      textColor: UIColor.init().colorFromHexInt(hex: 0xBDBDBD),
                                      font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                      andTextAlign: .right,
                                      andisdisplaysAsync: false)
    }()
    
    /// 留言描述
    private lazy var labMessageTitle:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "*留言内容描述",
                                          textColor: UIColor.init().colorFromHexInt(hex: 0x131412),
                                          font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                          andTextAlign: .left)
        
        _lab.attributedText = _lab.text!.yl_setAttributeStringText(FullTextFont: _lab.font!,
                                                                   andFullTextColor: _lab.textColor,
                                                                   withChangeText: "*",
                                                                   withChangeFont:  _lab.font!,
                                                                   withChangeColor: view_title_read_color)
        return _lab
    }()
    
    /// 留言框
    public private(set) lazy var txtMessage:UITextView = {[unowned self] in
        let _txt = UITextView.init(frame:.init(x: 0, y: 0, width: VXIUIConfig.shareInstance.YLScreenWidth - 2 * view_margin, height: view_txt_file_height))
        _txt.shouldIgnoreScrollingAdjustment = true
        
        //防止向上偏移
        //_txt.inputAccessoryView = UIView.init()
        _txt.keyboardDistanceFromTextField = 90
        
        _txt.delegate = self
        _txt.isOpaque = false
        _txt.toolbarPlaceholder = "请留言"
        
        _txt.textColor = UIColor.init().colorFromHexInt(hex: 0x353A44)
        _txt.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        _txt.backgroundColor = .clear
        
        _txt.layer.cornerRadius = 4
        _txt.layer.borderWidth = 1
        _txt.layer.borderColor = view_txt_border_color
        
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
                                          text: "请留言",
                                          textColor: UIColor.init().colorFromHexInt(hex: 0xBDBDBD),
                                          font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                          andTextAlign: .left)
        
        return _lab
    }()
    
    //MARK: 附件
    /// 选择的附件地址(ex:file:///Users/apple/Library/Developer/CoreSimulator/Devices/A757E8B2-847F-4F27-8F28-561F15CE3151/data/Library/Mobile%20Documents/com~apple~CloudDocs/WechatIMG791.jpg)
    private lazy var annex_data:Data? = nil
    private lazy var annex_name:String? = nil {
        didSet {
            if self.annex_name == nil || self.annex_name?.isEmpty == true {
                self.btnAnnex.isHidden = false
                self.btnRemove.isHidden = true
                self.labAnnexName.isHidden = true
            }
            else{
                self.btnAnnex.isHidden = true
                self.btnRemove.isHidden = false
                self.labAnnexName.isHidden = false
                self.labAnnexName.text = self.annex_name
            }
        }
    }
    
    /// 选择附件
    private lazy var btnAnnex:UIButton = {[unowned self] in
        let _img:UIImage? = TGSUIModel.imageForBuncle(Class: nil,
                                                      andBundleName: VXIUIConfig.shareInstance.getConfigBundleName(),
                                                      withImageName: "leave_message_annex.png",
                                                      andImagesFileName: nil)
        let btnStart = TGSUIModel.createBtn(rect: .zero,
                                            image: nil,
                                            backgroundImage: _img)
        
        btnStart.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            VXIDownLoadFileManager.share.openFile()
            VXIDownLoadFileManager.share.choiceFileInfoBlock = nil
            VXIDownLoadFileManager.share.choiceFileInfoBlock = {[weak self] (_filePath:URL?,_data:Data?,_fileName:String?,_fileSize:Double?) in
                guard let self = self else { return }
                self.annex_data = _data
                self.annex_name = _fileName
            }
        }.disposed(by: rx.disposeBag)
        
        return btnStart
    }()
    
    /// 已选择的附件名称
    private lazy var labAnnexName:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: nil,
                                          textColor: UIColor.init().colorFromHexInt(hex: 0x424242),
                                          font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                          andTextAlign: .left,
                                          andLineBreakMode: .byTruncatingMiddle)
        _lab.isUserInteractionEnabled = false
        _lab.numberOfLines = 1
        _lab.isHidden = true
        
        return _lab
    }()
    
    /// 移除
    private lazy var btnRemove:UIButton = {[unowned self] in
        let _img:UIImage? = TGSUIModel.imageForBuncle(Class: nil,
                                                      andBundleName: VXIUIConfig.shareInstance.getConfigBundleName(),
                                                      withImageName: "leave_message_delete.png",
                                                      andImagesFileName: nil)
        let btn = TGSUIModel.createBtn(rect: .zero,
                                       image: nil,
                                       backgroundImage: _img)
        
        btn.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            self.annex_data = nil
            self.annex_name = nil
        }.disposed(by: rx.disposeBag)
        
        btn.isHidden = true
        return btn
    }()
    
    //MARK: 提交
    /// 提交
    private lazy var btnSubmit:UIButton = {[unowned self] in
        let _btn = TGSUIModel.createBtn(rect: .zero,
                                        strTitle: "提交",
                                        titleColor: .white,
                                        txtFont: UIFont.systemFont(ofSize: 18, weight: .regular),
                                        image: nil,
                                        backgroundColor: UIColor.init().colorFromHexInt(hex: 0x02C161))
        
        _btn.layer.cornerRadius = 4
        _btn.contentHorizontalAlignment = .center
        
        _btn.rx.safeTap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            self.btnSubmitAction()
        }.disposed(by: rx.disposeBag)
        
        return _btn
    }()
}


//MARK: -
extension LeaveMessageBoxView {
    
    //MARK: 创建子视图
    /// 动态创建子视图
    private func createSubView(){
        
        if let _fields = self.dedfaultMode?.fields,_fields.count > 0 {
            //先移除
            for _v in self.subviews where _v.tag >= view_start_tag {
                _v.removeFromSuperview()
            }
            
            //再添加
            var _index = 0
            let _y:CGFloat = 55//起始距离
            for _item in _fields {
                
                //[S]标题
                let _isRequired = _item.required == true
                let _lab = TGSUIModel.createLable(rect: .zero,
                                                  text: "\(_isRequired ? "*":"")\(_item.fieldName ?? "")",
                                                  textColor: UIColor.init().colorFromHexInt(hex: 0x131412),
                                                  font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                                  andTextAlign: .left)
                
                if _isRequired {
                    _lab.attributedText = _lab.text!.yl_setAttributeStringText(FullTextFont: _lab.font!,
                                                                               andFullTextColor: _lab.textColor,
                                                                               withChangeText: "*",
                                                                               withChangeFont:  _lab.font!,
                                                                               withChangeColor: view_title_read_color)
                }
                _lab.tag = view_start_tag + _index + 1
                self.addSubview(_lab)
                _lab.snp.makeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.left.equalTo(view_margin)
                    make.right.equalTo(-view_margin)
                    make.height.equalTo(view_title_height)
                    make.top.equalTo(_y + CGFloat(_index) * CGFloat(view_title_height + 4 + view_txt_file_height + 10))
                }
                //[E]
                
                //[S] 输入框
                let _txt = TGSUIModel.createTextFiled(rect: .init(x: view_margin,
                                                                  y: _y + CGFloat(_index + 1) * (view_title_height + 4) + CGFloat(_index) * CGFloat(view_txt_file_height + 10),
                                                                  width: VXIUIConfig.shareInstance.YLScreenWidth - 2 * view_margin,
                                                                  height: view_txt_file_height),
                                                      placeHoled: _item.fieldName ?? "",
                                                      placeHoledColor: UIColor.init().colorFromHexInt(hex: 0xBDBDBD),
                                                      placeHoledFont: UIFont.systemFont(ofSize: 14, weight: .regular),
                                                      textMarginLeft: 0)
                _txt.shouldResignOnTouchOutsideMode = .enabled
                _txt.returnKeyType = .send
                if _item.fieldName?.contains("手机") == true || _item.fieldName?.contains("联系") == true {
                    _txt.keyboardType = .phonePad
                }
                else if _item.fieldName?.contains("年龄") == true {
                    _txt.keyboardType = .numberPad
                }
                else{
                    _txt.keyboardType = .default
                }
                
                //防止向上偏移
                _txt.keyboardDistanceFromTextField = CGFloat(200) - CGFloat(_index * 70)
                
                _txt.delegate = self
                _txt.isOpaque = false
                
                _txt.textColor = UIColor.init().colorFromHexInt(hex: 0x353A44)
                _txt.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                _txt.backgroundColor = .clear
                
                _txt.layer.cornerRadius = 4
                _txt.layer.borderWidth = 1
                _txt.layer.borderColor = view_txt_border_color
                
                _txt.tag = view_start_tag + _index
                self.addSubview(_txt)
                //[E]
                
                _index += 1
            }
            
            self.labPlace.text = self.dedfaultMode?.contentWord
            self.txtMessage.toolbarPlaceholder = self.dedfaultMode?.contentWord
            self.btnAnnex.isHidden = !(self.dedfaultMode?.enableAttachment ?? true)
            
            //[S]高度更新
            let _h:CGFloat = CGFloat(255) + CGFloat(_fields.count * 71) + VXIUIConfig.shareInstance.xp_safeDistanceBottom()
            self.frame = .init(origin: .init(x: 0, y: VXIUIConfig.shareInstance.YLScreenHeight - _h),
                               size: .init(width: VXIUIConfig.shareInstance.YLScreenWidth, height: _h))
            
            self.backgroundColor = .white
            TGSUIModel.addCornerFor(View: self,
                                    andCorners: [.topLeft,.topRight],
                                    widthRadius: 10,
                                    heightRadius: 10)
            //[E]
        }
        
        //在此之后添加，否则toolbar 的上下箭头顺序不对
        self.addSubview(self.labMessageTitle)
        self.addSubview(self.txtMessage)
        setNeedsUpdateConstraints()
    }
    
    
    //MARK: 提交
    private func btnSubmitAction(){
        
        if self.sessionId == nil || self.sessionId?.isEmpty == true {
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "会话编号不存在")
            return
        }
        
        if self.messageId == nil {
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "消息编号不存在")
            return
        }
        
        guard let _tid = self.dedfaultMode?.templateId,_tid > 0 else {
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "模板编号不存在，请退出再试")
            return
        }
        
        var dicContent = [String:Any]()
        if let _fields = self.dedfaultMode?.fields,_fields.count > 0 {
            for i in 0..<_fields.count {
                let txt:YYTextView? = self.viewWithTag(view_start_tag + i) as? YYTextView
                if (txt?.text == nil || txt?.text.replacingOccurrences(of: " ", with: "").isEmpty == true) && _fields[i].required == true {
                    VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "内容不为空")
                    txt?.becomeFirstResponder()
                }
                if let _key = _fields[i].fieldName?.replacingOccurrences(of: " ", with: ""),_key.isEmpty == false {
                    dicContent[_key] = txt?.text
                }
            }
        }
        
        //留言
        guard let _ly = self.txtMessage.text,_ly.isEmpty != true else {
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "请输入留言内容")
            return
        }
        dicContent["留言"] = _ly
        
        //启用附件(启用附件也可以不用上传)
        if self.dedfaultMode?.enableAttachment == true {
            //无附件
            if self.annex_name == nil || self.annex_name?.isEmpty == true || self.annex_data == nil {
                self.viewModel?.leaveMessageSubmitPublishSubject.onNext((true,self.sessionId!,_tid,self.messageId!,dicContent, [String:Any]()))
            }
            //有附件
            else{
                //先上传，上传成功再提交
                let _mime = TGSUIModel.getMimeTypeFor(FileName: self.annex_name!)
                VXIChatViewModel.conversationUploadFor(FileData: self.annex_data!,
                                                       andFileName: self.annex_name!,
                                                       andMimeType: _mime,
                                                       withFinishblock: {[weak self] (_isok:Bool, _path:String, _:Data, _type:String) in
                    guard let self = self else { return }
                    
                    //附件信息
                    let dicAttachments:[String:Any] = [
                        "fileSize":self.annex_data!.count / 1024, //文件大小(kb)
                        "fileName":self.annex_name!,
                        "contentType": _type.isEmpty == true ? _mime : _type,
                        "mediaUrl":_path
                    ]
                    
                    //提交
                    self.viewModel?.leaveMessageSubmitPublishSubject.onNext((true,self.sessionId!,_tid,self.messageId!,dicContent, dicAttachments))
                },
                                                       andProgressBlock: nil,
                                                       andLoading: true,
                                                       andisFullPath: false)
            }
        }
        //不用上传附件
        else{
            //提交
            self.viewModel?.leaveMessageSubmitPublishSubject.onNext((true,self.sessionId!,_tid,self.messageId!,dicContent, [String:Any]()))
        }
    }
    
    //MARK: 清除
    /// 清除信息
    public func clearInfo(){
        for _v in self.subviews where _v.isKind(of: YYTextView.classForCoder()) && _v.tag >= view_start_tag {
            (_v as? YYTextView)?.text = nil
        }
        
        self.txtMessage.text = nil
        self.labFootCount.text = "0/\(VXIUIConfig.shareInstance.getStarMaxComment())"
        
        self.btnAnnex.isHidden = false
        self.labAnnexName.isHidden = true
        self.btnRemove.isHidden = true
    }
    
}


//MARK: - LeaveMessageBoxView
extension LeaveMessageBoxView : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //发送
        if string == "\n" {
            self.btnSubmitAction()
            return false
        }
        
        return true
    }
}


//MARK: - UITextViewDelegate
extension LeaveMessageBoxView : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let length = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count
        let strLength = text.lengthOfBytes(using: String.Encoding.utf8)
        
        if strLength > 0 && text != "\n" && text != " " {
            self.labPlace.isHidden = true
        }
        else if strLength <= 0 && range.location <= 0 {
            self.labPlace.isHidden = false
        }
        
        let _max = VXIUIConfig.shareInstance.getStarMaxComment()
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
