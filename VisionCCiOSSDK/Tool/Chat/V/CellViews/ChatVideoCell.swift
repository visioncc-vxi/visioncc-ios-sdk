//
//  ChatVideoCell.swift
//  Tool
//
//  Created by apple on 2024/1/6.
//

import UIKit
import Photos
import SnapKit
import RxSwift
@_implementationOnly import VisionCCiOSSDKEngine

/// 自定义视频消息列
class ChatVideoCell: BaseChatCell {
    
    /// 点击回调
    public var clickCellBlock:((_ _localPath:String?,_ _videoPath:String?)->Void)?
    
    private let cell_play_width:CGFloat = 32
    private let cell_cover_size:CGSize = .init(width: 73.25, height: 131)
    
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
        
        if self.contentView.subviews.contains(self.imgCoverView){
            self.imgCoverView.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.size.equalTo(cell_cover_size)
                make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                make.top.equalTo(messageAvatarsImageView.snp.top)
                make.right.equalTo(messageAvatarsImageView.snp.left).offset(-VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
            }
        }
        
        if self.imgCoverView.subviews.contains(self.imgPlay){
            self.imgPlay.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.height.equalTo(cell_play_width)
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        }
        
        if self.imgCoverView.subviews.contains(self.wCircleView){
            self.wCircleView.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.height.equalTo(cell_play_width)
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        }
        
        if self.contentView.subviews.contains(self.btnError){
            self.btnError.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.height.equalTo(17)
                make.centerY.equalTo(self.imgCoverView.snp.centerY)
                make.right.equalTo(self.imgCoverView.snp.left).offset(-6)
            }
        }
        
        if self.imgCoverView.subviews.contains(self.labDuration){
            self.labDuration.snp.makeConstraints { make in
                make.height.equalTo(14)
                make.width.equalTo(35)
                make.right.equalTo(-4)
                make.bottom.equalTo(-2)
            }
        }
        
        super.updateConstraints()
    }
    
    private func initView(){
        
        self.contentView.addSubview(self.imgCoverView)
        self.contentView.addSubview(self.btnError)
        self.btnError.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            self.reloadUpload(isClick: true)
        }.disposed(by: rx.disposeBag)
        
        self.imgCoverView.addSubview(self.imgPlay)
        self.imgCoverView.addSubview(self.wCircleView)
        self.imgCoverView.addSubview(self.labDuration)
        
        setNeedsUpdateConstraints()
    }
    
    //MARK: 数据绑定
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        self.bindValueFor(Data: m)
        layoutIfNeeded()
    }
    
    //MARK: - lazy load
    /// 上传进度
    private lazy var wCircleView:WCircleView = {[unowned self] in
        let _x:CGFloat = (self.cell_cover_size.width - cell_play_width) * 0.5
        let _y:CGFloat = (self.cell_cover_size.height - cell_play_width) * 0.5
        let _v = WCircleView.init(frame: CGRect.init(x: _x, y: _y, width: cell_play_width, height: cell_play_width))
        _v.show_background_color = .clear
        _v.out_circle_border_color = .lightGray
        _v.out_high_light_border_color = .white
        _v.out_circle_radius = cell_play_width * 0.5
        
        return _v
    }()
    
    /// 封面图
    private lazy var imgCoverView:UIImageView = {[unowned self] in
        let _v = TGSUIModel.createImage(rect: .zero,
                                        image: nil,
                                        backgroundColor: .black)
        
        _v.isUserInteractionEnabled = true
        _v.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
        let _tapGest = UITapGestureRecognizer.init(target: self, action: #selector(reviewAction(sender:)))
        _v.addGestureRecognizer(_tapGest)
        
        //长按事件
        let _longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(bassCellLongPressAction(sender:)))
        _v.addGestureRecognizer(_longPress)
        
        return _v
    }()
    
    /// 播放按钮
    private lazy var imgPlay:UIImageView = {
        let _v = TGSUIModel.createImage(rect: .zero,
                                        image: UIImage(named: "icon_video_play.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil),
                                        backgroundColor: .clear)
        _v.isUserInteractionEnabled = false
        _v.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
        return _v
    }()
    
    /// 时长
    private lazy var labDuration:YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "00:00",
                                          textColor: .white,
                                          font: UIFont.systemFont(ofSize: 10, weight: .regular),
                                          andTextAlign: .right)
        return _lab
    }()
    
}


//MARK: -
extension ChatVideoCell {
    
    /// 数据绑定
    /// - Parameter _d: <#_d description#>
    private func bindValueFor(Data _d:MessageModel) {
        
        if _d.mType == MessageBodyType.video.rawValue {
            
            //[S] 更新样式
            let _isSend = MessageDirection.init(rawValue: _d.renderMemberType ?? 0).isSend()
            if _isSend == true {
                self.imgCoverView.snp.remakeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.size.equalTo(cell_cover_size)
                    make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                    make.top.equalTo(messageAvatarsImageView.snp.top)
                    make.right.equalTo(messageAvatarsImageView.snp.left).offset(-VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
                }
                
                self.btnError.snp.remakeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.width.height.equalTo(17)
                    make.centerY.equalTo(self.imgCoverView.snp.centerY)
                    make.right.equalTo(self.imgCoverView.snp.left).offset(-6)
                }
            }
            else{
                self.imgCoverView.snp.remakeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.size.equalTo(cell_cover_size)
                    make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                    make.top.equalTo(messageAvatarsImageView.snp.top)
                    make.left.equalTo(messageAvatarsImageView.snp.right).offset(VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
                }
                
                self.btnError.snp.remakeConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.width.height.equalTo(17)
                    make.centerY.equalTo(self.imgCoverView.snp.centerY)
                    make.left.equalTo(self.imgCoverView.snp.right).offset(6)
                }
            }
            //[E]
            
            // 加载
            self.reloadUpload()
            
            //[S]时长
            var _duration:Double = 0
            if let _vd = _d.messageBody?.duration,_vd > 0{
                _duration = _vd / 1000
            }
            let _info:String = TGSUIModel.getDurationFor(Timeinterval: _duration)
            self.labDuration.text = _info
            let _w = _info.yl_getLabelWidth(Font: self.labDuration.font, andHeight: 14) + 5
            self.labDuration.snp.remakeConstraints { make in
                make.height.equalTo(14)
                make.width.equalTo(_w)
                make.right.equalTo(-4)
                make.bottom.equalTo(-2)
            }
            //[E]
            
            //封面图(//封面图是 mediaUrl?view=h5)
            var _path:String? = _d.messageBody?.coverUrl
            if (_path == nil || _path?.isEmpty == true),let _murl = _d.messageBody?.mediaUrl,_murl.isEmpty == false {
                _path = _murl
            }
            
            if _path != nil && _path?.isEmpty == false,
               let _url = URL.init(string: TGSUIModel.getFileRealUrlFor(Path: _path!, andisThumbnail: true)) {
                self.imgCoverView.yy_setImage(with: _url,
                                              placeholder: VXIUIConfig.shareInstance.cellDefaultImage(),
                                              options: VXIUIConfig.shareInstance.requestOption()) { [weak self] (_img:UIImage?, _:URL, _:YYWebImageFromType, _:YYWebImageStage, _error:Error?) in
                    guard let self = self else { return }
                    let _tBlock = {
                        if let _image = _img {
                            self.resetStyleFor(Image: _image,andisSend: _isSend,andNeedResetSize: false)
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
            //本地图片
            else if let _file_data = _d.messageBody?.videoCoverImage,
                    let _img = UIImage.init(data: _file_data) {
                self.resetStyleFor(Image: _img,andisSend: _isSend)
            }
        }
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - _img: UIImage
    ///   - _isSend: Bool true 发送
    ///   - _isnrs: Bool true 需要重新处理尺寸
    private func resetStyleFor(Image _img:UIImage,
                               andisSend _isSend:Bool,
                               andNeedResetSize _isnrs:Bool = true){
        
        var _w:CGFloat = _img.size.width
        var _h:CGFloat = _img.size.height
        
        if _isnrs {
            let _size = TGSUIModel.pictureResetSizeFor(Image: _img, orOriginalSize: nil)
            _w = _size.width
            _h =  _size.height
//            //横图
//            if _size.width > _size.height {
//                _h = _w * 9 / 16 //横版视频宽高比 16:9
//            }
//            //竖图
//            else {
//                _h = _w * 16 / 9 //竖版视频宽高比 9:16
//            }
        }
        else{
            _w = _img.size.width * UIScreen.main.scale
            _h = _img.size.height * UIScreen.main.scale
        }
        
        if _isSend == true {
            self.imgCoverView.snp.remakeConstraints {[weak self] make in
                guard let self = self else { return }
                make.size.equalTo(CGSize.init(width: _w, height: _h))
                make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                make.top.equalTo(messageAvatarsImageView.snp.top)
                make.right.equalTo(messageAvatarsImageView.snp.left).offset(-VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
            }
        }
        else{
            self.imgCoverView.snp.remakeConstraints {[weak self] make in
                guard let self = self else { return }
                make.size.equalTo(CGSize.init(width: _w, height: _h))
                make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                make.top.equalTo(messageAvatarsImageView.snp.top)
                make.left.equalTo(messageAvatarsImageView.snp.right).offset(VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
            }
        }
        
        let imgNew:UIImage? = _img.yy_imageByResize(to: .init(width: _w, height: _h),
                                                    contentMode: VXIUIConfig.shareInstance.cellImageContentMode())?.yy_image(byRoundCornerRadius: VXIUIConfig.shareInstance.bubbleCornerRadius())
        self.imgCoverView.image = imgNew
    }
    
    
    //MARK: 点击预览
    ///点击预览
    @IBAction private func reviewAction(sender:UITapGestureRecognizer) {
        let _localPath = self.message?.messageBody?.videoLocalPath
        let _videPath = self.message?.messageBody?.mediaUrl?.yl_urlEncoded()
        if _videPath != nil  && _videPath?.isEmpty == false {
            //下载视频
            VXIDownLoadFileManager.share.downloadFileInCacheFor(Url: TGSUIModel.getFileRealUrlFor(Path: _videPath!, andisThumbnail: false),
                                                                andTitle: self.message?.messageBody?.videoName ?? URL.init(string: _videPath!)?.lastPathComponent ?? (NSUUID().uuidString + ".mp4"),
                                                                andLoading: false) {[weak self] _progress in
                guard let self =  self else { return }
                self.wCircleView.isHidden = false
                self.wCircleView.startAnimationDrawFor(Current: _progress,
                                                       andTotal: 1,
                                                       andShowInfo: "")
                if _progress >= 1 {
                    self.wCircleView.isHidden = true
                    self.imgPlay.isHidden = false
                    self.imgCoverView.isUserInteractionEnabled = true
                }
            } andFinishBlock: {[weak self](_isOK, _, _fileCachePath, _msg) in
                guard let self = self else { return  }
                if _isOK {
                    self.btnError.isHidden = true
                    self.wCircleView.isHidden = true
                    self.imgPlay.isHidden = false
                    self.imgCoverView.isUserInteractionEnabled = true
                    
                    //开始预览
                    if _fileCachePath != nil && _fileCachePath?.isEmpty == false {
                        self.clickCellBlock?(_fileCachePath!,nil)
                        self.message?.messageBody?.videoLocalPath = _fileCachePath
                        
                        //获取时长
                        let _url = NSURL.init(fileURLWithPath: _fileCachePath!) as URL
                        let _duration = AVAsset(url: _url).duration.seconds
                        self.message?.messageBody?.duration = _duration * 1000
                        let _info:String = TGSUIModel.getDurationFor(Timeinterval: _duration)
                        self.labDuration.text = _info
                    }
                    else{
                        self.clickCellBlock?(_localPath,TGSUIModel.getFileRealUrlFor(Path: _videPath!, andisThumbnail: false))
                    }
                }
                else{
                    self.btnError.isHidden = false
                    self.wCircleView.isHidden = true
                    VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
                    self.clickCellBlock?(_localPath,TGSUIModel.getFileRealUrlFor(Path: _videPath!, andisThumbnail: false))
                }
            }
        }
        else{
            self.clickCellBlock?(_localPath,nil)
        }
    }
    
    
    //MARK: 上传失败重新上传并发送消息
    /// 发送消息
    private func reloadUpload(isClick _ic:Bool = false){
        if let _d = self.message,self.cellisFirstResponse == true || (self.cellisFirstResponse == false && _ic) {
            if MessageDirection.init(rawValue: _d.renderMemberType ?? 0).isSend() == true && (_d.mId ?? 0) <= 0,
               let _path = _d.messageBody?.videoLocalPath,_path.isEmpty == false {
                let _url:NSURL = NSURL.init(fileURLWithPath: _path)
                
                if let _data = try? Data.init(contentsOf: _url as URL) {
                    let _mime = TGSUIModel.getMimeTypeFor(FileName: _url.lastPathComponent ?? "")
                    let _fn:String = (_d.messageBody?.videoName ?? _url.lastPathComponent)!
                    
                    VXIChatViewModel.conversationUploadFor(FileData: _data,
                                                           andFileName: _fn,
                                                           andMimeType: _mime,
                                                           withFinishblock: {[weak self] (_isOK:Bool, _url:String, _:Data, _:String) in
                        guard let self = self else { return }
                        if _isOK {
                            self.btnError.isHidden = true
                            self.wCircleView.isHidden = true
                            self.imgPlay.isHidden = false
                            self.imgCoverView.isUserInteractionEnabled = true
                            
                            //视频、封面上传成功，发送消息
                            self.delegate?.epSendMessage(MessageBodyType.video.rawValue,
                                                         _d.cMid ?? NSUUID().uuidString, [
                                                            //视频Url
                                                            "mediaUrl": _url
                                                         ])
                        }
                        else{
                            //上传失败，重发
                            self.btnError.isHidden = false
                            self.cellisFirstResponse = false
                            self.wCircleView.isHidden = true
                            self.imgPlay.isHidden = false
                            self.imgCoverView.isUserInteractionEnabled = true
                        }
                    },
                                                           andProgressBlock: { [weak self] _progress in
                        guard let self = self else { return }
                        self.wCircleView.startAnimationDrawFor(Current: _progress,
                                                               andTotal: 1,
                                                               andShowInfo: "")
                        if _progress >= 1 {
                            self.wCircleView.isHidden = true
                            self.imgPlay.isHidden = false
                            self.imgCoverView.isUserInteractionEnabled = true
                        }
                    },
                                                           andLoading: false,
                                                           andisFullPath: false)
                }
            }
        }
    }
}
