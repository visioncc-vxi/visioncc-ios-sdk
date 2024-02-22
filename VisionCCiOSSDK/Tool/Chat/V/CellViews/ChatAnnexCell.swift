//
//  ChatAnnexCell.swift
//  Tool
//
//  Created by apple on 2024/1/6.
//

import UIKit
import SnapKit
import RxSwift
@_implementationOnly import VisionCCiOSSDKEngine

/// 附件自定义消息
class ChatAnnexCell: BaseChatCell {
    
    private let cell_circle_width:CGFloat = 32
    private let cell_parent_size:CGSize = .init(width: 220.5, height: 79)
    
    /// 点击预览
    /// (本地地址, 服务端返回地址 ,文件名称)
    public var clickCellBlock:((_ _path:String?,_ _fileName:String?)->Void)?
    
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
                make.size.equalTo(cell_parent_size)
                make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                make.top.equalTo(messageAvatarsImageView.snp.top)
                make.right.equalTo(messageAvatarsImageView.snp.left).offset(-VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
            }
        }
        
        if self.contentView.subviews.contains(self.activeInfoView){
            self.activeInfoView.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.height.equalTo(16)
                make.centerY.equalTo(self.parentView.snp.centerY)
                make.right.equalTo(self.parentView.snp.left).offset(-6)
            }
        }
        
        if self.contentView.subviews.contains(self.btnError){
            self.btnError.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.height.equalTo(17)
                make.centerY.equalTo(self.parentView.snp.centerY)
                make.right.equalTo(self.parentView.snp.left).offset(-6)
            }
        }
        
        //MARK: -
        if self.parentView.subviews.contains(self.labName){
            self.labName.snp.makeConstraints { make in
                make.left.top.equalTo(10)
                make.height.equalTo(40)
                make.right.equalTo(-60)
            }
        }
        
        if self.parentView.subviews.contains(self.imgRight){
            self.imgRight.snp.makeConstraints { make in
                make.width.equalTo(30.48)
                make.height.equalTo(34.29)
                make.right.equalTo(-14.5)
                make.top.equalTo(13)
            }
        }
        
        if self.parentView.subviews.contains(self.labSize){
            self.labSize.snp.makeConstraints { make in
                make.left.equalTo(10)
                make.height.equalTo(15)
                make.width.equalTo(35)
                make.bottom.equalTo(-10)
            }
        }
        
        if self.parentView.subviews.contains(self.labStatus){
            self.labStatus.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(self.labSize.snp.right).offset(10)
                make.height.equalTo(15)
                make.width.equalTo(50)
                make.centerY.equalTo(self.labSize.snp.centerY)
            }
        }
        
        super.updateConstraints()
    }
    
    
    //MARK: - initView
    private func initView(){
        
        self.contentView.addSubview(self.parentView)
        self.contentView.addSubview(self.activeInfoView)
        self.contentView.addSubview(self.btnError)
        
        self.parentView.addSubview(self.labName)
        self.parentView.addSubview(self.imgRight)
        self.parentView.addSubview(self.labSize)
        self.parentView.addSubview(self.labStatus)
        
        weak var weakSelf = self
        self.parentView.isUserInteractionEnabled = true
        let _tapGest = UITapGestureRecognizer.init(target: weakSelf, action: #selector(reviewAction(sender:)))
        self.parentView.addGestureRecognizer(_tapGest)
        
        //下载事件
        self.btnError.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            if self.isSend {
                self.btnError.isHidden = true
                self.activeInfoView.isHidden = false
                self.reloadUpload(isClick: true)
            }
            //下载
            else{
                if let _real_path = message?.messageBody?.mediaUrl,!_real_path.isEmpty {
                    self.downloaAnnexFor(RealUrl: TGSUIModel.getFileRealUrlFor(Path: _real_path, andisThumbnail: false),
                                         andName: self.labName.text)
                }
            }
        }.disposed(by: rx.disposeBag)
        
        //长按事件
        let _longPress = UILongPressGestureRecognizer.init(target: weakSelf, action: #selector(bassCellLongPressAction(sender:)))
        self.parentView.addGestureRecognizer(_longPress)
        
        setNeedsUpdateConstraints()
    }
    
    
    //MARK: 数据绑定
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        self.isSend = false
        self.bindValueFor(Data: m)
        layoutIfNeeded()
    }
    
    //MARK: - lazy load
    ///true 发送，false 下载
    private lazy var isSend:Bool = false
    
    private lazy var parentView:UIView = {
        let _c:String = TGSUIModel.getThemColorsConfig()?.cckf_chat_file_bgColor ?? "#FFFFFF"
        let _v = TGSUIModel.createView(bgColor: .init().colorFromHexString(hex: _c))
        _v.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
        
        return _v
    }()
    
    /// 标题
    private lazy var labName:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: nil,
                                          textColor: UIColor.init().colorFromHexInt(hex: 0x424242),
                                          font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                          andTextAlign: .left,
                                          andLineBreakMode: .byTruncatingMiddle)
        _lab.isUserInteractionEnabled = false
        _lab.textVerticalAlignment = .top
        _lab.numberOfLines = 2
        
        return _lab
    }()
    
    /// 文件图片
    private lazy var imgRight:UIImageView = {
        let _img = TGSUIModel.createImageView()
        _img.image = UIImage(named: "icon_annex_other.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
        return _img
    }()
    
    /// 大小
    private lazy var labSize:YYLabel = {
        return TGSUIModel.createLable(rect: .zero,
                                      text: "0M",
                                      textColor: UIColor.init().colorFromHexInt(hex: 0x9E9E9E),
                                      font: UIFont.systemFont(ofSize: 11, weight: .regular),
                                      andTextAlign: .left)
    }()
    
    /// 状态
    private lazy var labStatus:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "发送失败",
                                          textColor: UIColor.init().colorFromHexInt(hex: 0x9E9E9E),
                                          font: UIFont.systemFont(ofSize: 11, weight: .regular),
                                          andTextAlign: .left)
        _lab.isHidden = true
        return _lab
    }()
    
    /// 发送状态
    private lazy var activeInfoView:UIActivityIndicatorView = {
        let _activityV = UIActivityIndicatorView.init()
        if #available(iOS 13.0, *) {
            _activityV.style = .medium
        } else {
            // Fallback on earlier versions
        }
        _activityV.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
        _activityV.color = UIColor.init().colorFromHexInt(hex: 0xC0C4CC)
        _activityV.backgroundColor = .clear
        _activityV.hidesWhenStopped = true
        _activityV.isHidden = true
        return _activityV
    }()
    
}


//MARK: -
extension ChatAnnexCell {
    
    //MARK: 绑定数据
    /// 绑定数据
    /// - Parameter _d: <#_d description#>
    private func bindValueFor(Data _d:MessageModel?){
        if _d?.mType == MessageBodyType.annex.rawValue {
            
            //[S]样式更新
            if MessageDirection.init(rawValue: _d?.renderMemberType ?? 0).isSend() == true {
                self.parentView.snp.remakeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.size.equalTo(cell_parent_size)
                    make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                    make.top.equalTo(messageAvatarsImageView.snp.top)
                    make.right.equalTo(messageAvatarsImageView.snp.left).offset(-VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
                }
                
                self.activeInfoView.snp.remakeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.width.height.equalTo(16)
                    make.centerY.equalTo(self.parentView.snp.centerY)
                    make.right.equalTo(self.parentView.snp.left).offset(-6)
                }
                
                self.btnError.snp.remakeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.width.height.equalTo(17)
                    make.centerY.equalTo(self.parentView.snp.centerY)
                    make.right.equalTo(self.parentView.snp.left).offset(-6)
                }
            }else {
                self.parentView.snp.remakeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.size.equalTo(cell_parent_size)
                    make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                    make.top.equalTo(messageAvatarsImageView.snp.top)
                    make.left.equalTo(messageAvatarsImageView.snp.right).offset(VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
                }
                
                self.activeInfoView.snp.remakeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.width.height.equalTo(16)
                    make.centerY.equalTo(self.parentView.snp.centerY)
                    make.left.equalTo(self.parentView.snp.right).offset(-6)
                }
                
                self.btnError.snp.remakeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.width.height.equalTo(17)
                    make.centerY.equalTo(self.parentView.snp.centerY)
                    make.left.equalTo(self.parentView.snp.right).offset(-6)
                }
            }
            //[E]
            
            //文件名
            self.labName.text = _d?.messageBody?.fileName
            
            //[S]文件大小(默认单位：KB)
            if let _s:Double = _d?.messageBody?.fileSize {
                let _s_info = VXIDownLoadFileManager.share.foramtFileStringFor(Size: _s)
                self.labSize.text = _s_info
            }
            else{
                self.labSize.text = "0KB"
            }
            
            if let _w = self.labSize.text?.yl_getLabelWidth(Font: self.labSize.font, andHeight: 15) {
                self.labSize.snp.updateConstraints { make in
                    make.width.equalTo(_w + 5)
                }
            }
            //[E]
            
            //文件类型
            let _p = _d?.messageBody?.mediaUrl ?? _d?.messageBody?.fileName
            if _p != nil, let _url = URL(string: _p!.yl_urlEncoded()) {
                self.imgRight.image = self.getAnneImageFor(Suffix: _url.pathExtension)
            }
            else{
                self.imgRight.image = self.getAnneImageFor(Suffix: _p)
            }
            
            // 加载
            if _d?.mId == nil  && _d?.cMid != nil && _d?.cMid?.isEmpty == false {
                self.reloadUpload()
            }
        }
    }
    
    
    /// 根据文件后缀设置图片
    /// - Parameter _s: String? 后缀名(pdf,...)
    /// - Returns: <#description#>
    private func getAnneImageFor(Suffix _s:String?) -> UIImage? {
        var _img:UIImage? = UIImage(named: "icon_annex_other.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
        switch _s?.lowercased() {
        case .some("pdf"),
                .some("xps"):
            _img = UIImage(named: "icon_annex_pdf.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
            break
            
        case .some("ppt"),
                .some("pptx"),
                .some("pptm"),
                .some("pps"),
                .some("ppsx"),
                .some("ppsm"),
                .some("potm"):
            _img = UIImage(named: "icon_annex_ppt.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
            break
            
        case .some("zip"),
                .some("rar"),
                .some("7z"),
                .some("gz"),
                .some("bz2"),
                .some("xz"),
                .some("tar"):
            _img = UIImage(named: "icon_annex_zip.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
            break
            
        case .some("docx"),
                .some("doc"),
                .some("doc"):
            _img = UIImage(named: "icon_annex_word.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
            break
            
        case .some("csv"),
                .some("xlsx"),
                .some("xlsm"),
                .some("xls"):
            _img = UIImage(named: "icon_annex_xls.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
            break
            
        default:
            _img = UIImage(named: "icon_annex_other.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
            break
        }
        
        return _img
    }
    
    
    //MARK: 文件预览
    ///文件预览
    @IBAction private func reviewAction(sender:UITapGestureRecognizer) {
        
        if let _p = message?.messageBody?.mediaUrl,!_p.isEmpty {
            let _real_path = TGSUIModel.getFileRealUrlFor(Path: _p, andisThumbnail: false)
            self.downloaAnnexFor(RealUrl: _real_path, andName: self.labName.text)
        }
        else {
            self.clickCellBlock?(message?.messageBody?.annexLocalPath,
                                 self.labName.text)
        }
    }
    
    //MARK: 发送文件
    /// 发送文件
    private func reloadUpload(isClick _ic:Bool = false){
        if let _d = self.message,self.cellisFirstResponse == true || (self.cellisFirstResponse == false && _ic) {
            if MessageDirection.init(rawValue: _d.renderMemberType ?? 0).isSend() == true && (_d.mId ?? 0) <= 0,
               let _data = _d.messageBody?.annexLocalData {
                self.isSend = true
                let _name = _d.messageBody?.fileName ?? NSUUID().uuidString
                VXIChatViewModel.conversationUploadFor(FileData: _data,
                                                       andFileName: _name,
                                                       andMimeType: TGSUIModel.getMimeTypeFor(FileName: _name),
                                                       withFinishblock: {[weak self] (_isOk:Bool, _info:String, _:Data,_actualContentType) in
                    guard let self = self else { return }
                    if _isOk {
                        self.btnError.isHidden = true
                        
                        //文件(附件)上传成功，发送消息
                        self.delegate?.epSendMessage(MessageBodyType.annex.rawValue, _d.cMid ?? NSUUID().uuidString, [
                            "mediaUrl": _info as Any,
                            "fileSize": _data.count / 1024, //kb
                            "fileName": _name,
                            "contentType":_actualContentType.isEmpty == false ? _actualContentType : TGSUIModel.getMimeTypeFor(FileName: _name),
                        ])
                    }
                    else{
                        //上传失败，重发
                        self.btnError.isHidden = false
                        self.cellisFirstResponse = false
                        VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _info)
                    }
                    self.activeInfoView.stopAnimating()
                },
                                                       andProgressBlock: {[weak self] _progress in
                    guard let self = self else { return }
                    self.activeInfoView.isHidden = false
                    self.activeInfoView.startAnimating()
                    if _progress >= 1 {
                        self.activeInfoView.stopAnimating()
                    }
                },
                                                       andLoading: false,
                                                       andisFullPath: false)
            }
        }
    }
    
    
    //MARK: 附件点击处理
    /// 预览（下载附件）
    /// - Parameters:
    ///   - _url: <#_url description#>
    ///   - _name: <#_name description#>
    private func downloaAnnexFor(RealUrl _url:String,
                                 andName _name:String?){
        self.isSend = false
        self.btnError.isHidden = true
        self.activeInfoView.isHidden = false
        self.activeInfoView.startAnimating()
        let _vc:BaseChatVC? = self.yy_viewController as? BaseChatVC
        
        VXIDownLoadFileManager.share.downloadFileInCacheFor(Url: _url,
                                                            andTitle: _name ?? NSUUID().uuidString,
                                                            andLoading: false) {[weak self] progress in
            guard let self =  self else { return }
            if progress >= 1 {
                self.activeInfoView.stopAnimating()
            }
        } andFinishBlock: {[weak self](_isOK, _, _fileCachePath, _msg) in
        guard let self = self else { return  }
        if _isOK {
            self.btnError.isHidden = true
            self.activeInfoView.isHidden = true
            
            //开始预览
            if _fileCachePath != nil && _fileCachePath?.isEmpty == false {
                self.message?.messageBody?.annexLocalPath = _fileCachePath!
                VXIDownLoadFileManager.share.previewFile(filePath: _fileCachePath!,
                                                         andFileName: _name,
                                                         withDelegate: _vc)
            }
        }
        else{
            self.btnError.isHidden = false
            self.activeInfoView.isHidden = true
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
        }
    }
    }
}
