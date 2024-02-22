//
//  ChatImageCell.swift
//  YLBaseChat
//
//  Created by yl on 17/5/25.
//  Copyright © 2017年 yl. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
@_implementationOnly import VisionCCiOSSDKEngine

/// 图片消息
class ChatImageCell: BaseChatCell {
    
    private let cell_circle_width:CGFloat = 32
    
    //MARK: - override
    override func layoutUI() {
        isNeedBubbleBackground = false
        super.layoutUI()
        
        self.contentView.addSubview(self.messagePhotoImageView)
        self.messagePhotoImageView.addSubview(self.wCircleView)
        self.wCircleView.snp.makeConstraints {[weak self] make in
            guard let self = self else { return }
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(self.cell_circle_width)
        }
        
        self.contentView.addSubview(self.btnError)
        self.btnError.rx.safeTap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            if (message?.mId == nil || (message?.mId ?? 0) <= 0) && message?.cMid != nil && message?.cMid?.isEmpty == false {
                if let _data = message?.messageBody?.image,
                   let _img:UIImage = UIImage(data: _data) {
                    self.reloadUploadFor(Data: _data,
                                         andImageSize: _img.size,
                                         andImageName: message?.messageBody?.name ?? "picture.jpg",
                                         isClick: true)
                }
                else{
                    VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "数据不存在，稍后再试")
                }
            }
        }.disposed(by: rx.disposeBag)
        
        //长按事件
        weak var weakSelf = self
        let _longPress = UILongPressGestureRecognizer.init(target: weakSelf, action: #selector(bassCellLongPressAction(sender:)))
        self.messagePhotoImageView.addGestureRecognizer(_longPress)
        self.messagePhotoImageView.isUserInteractionEnabled = true
        
        setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        
        if self.contentView.subviews.contains(self.btnError){
            self.btnError.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.height.equalTo(17)
                make.centerY.equalTo(self.messagePhotoImageView.snp.centerY)
                make.right.equalTo(self.messagePhotoImageView.snp.left).offset(-6)
            }
        }
        
        super.updateConstraints()
    }
    
    
    //MARK: 绑定数据
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        
        //绑定
        self.bindValueFor(Message: m)
        
        layoutIfNeeded()
    }
    
    //MARK: - lazy load
    private lazy var longPressImg:UIImage? = nil
    
    /// 动图
    public private(set) lazy var messagePhotoImageView:YYAnimatedImageView = {
        let _pic = TGSUIModel.createAnimationImageFor(Rect: .zero, andImage: nil)
        
        _pic.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
        
        _pic.isUserInteractionEnabled = true
        _pic.addGestureRecognizer(UITapGestureRecognizer.init(target: self,
                                                              action: #selector(ChatImageCell.tapHandle)))
        
        return _pic
    }()
    
    /// 上传进度
    private lazy var wCircleView:WCircleView = {[unowned self] in
        let _v = WCircleView.init(frame: CGRect.init(x: 0, y: 0, width: cell_circle_width, height: cell_circle_width))
        _v.show_background_color = .clear
        _v.out_circle_border_color = .lightGray
        _v.out_high_light_border_color = .white
        _v.out_circle_radius = cell_circle_width * 0.5
        _v.isHidden = true
        return _v
    }()
    
}


//MARK: -
extension ChatImageCell {
    
    //MARK: bindValue
    /// 绑定数据
    /// - Parameter m: MessageModel
    private func bindValueFor(Message m:MessageModel){
        self.longPressImg = nil
        self.messagePhotoImageView.isHighlighted = true
        
        //根据尺寸预先显示并设置加载进度
        let _tempBlock:((CGSize,UIImage?,Bool)->Void) = {[weak self] (_size,_img,_isUpdate) in
            guard let self = self else { return }
            
            if _isUpdate == false {
                self.wCircleView.frame.size = _size
            }
            
            if MessageDirection.init(rawValue: m.renderMemberType ?? 0).isSend() == true {
                messagePhotoImageView.snp.remakeConstraints({[weak self] (make) in
                    guard let self = self else { return }
                    make.size.equalTo(_size)
                    make.right.equalTo(messageAvatarsImageView.snp.left).offset(-VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
                    make.top.equalTo(messageAvatarsImageView)
                    make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                })
            }
            else {
                messagePhotoImageView.snp.remakeConstraints({[weak self] (make) in
                    guard let self = self else { return }
                    make.size.equalTo(_size)
                    make.left.equalTo(messageAvatarsImageView.snp.right).offset(VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
                    make.top.equalTo(messageAvatarsImageView)
                    make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
                })
            }
            
            //本地图
            if _img != nil && _isUpdate == false {
                let imgNew:UIImage? = _img!.yy_imageByResize(to: _size,
                                                             contentMode: VXIUIConfig.shareInstance.cellImageContentMode())?.yy_image(byRoundCornerRadius: VXIUIConfig.shareInstance.bubbleCornerRadius())
                self.messagePhotoImageView.image = imgNew
                self.longPressImg = imgNew
            }
        }
        
        //已存储到本地的图片
        if let _data = m.messageBody?.image,
           let _img:UIImage = UIImage(data: _data) {
            let _size:CGSize = TGSUIModel.pictureResetSizeFor(Image: _img, orOriginalSize: nil)
            _tempBlock(_size,_img,false)
            
            // 上传
            if m.mId == nil && m.cMid != nil && m.cMid?.isEmpty == false {
                self.reloadUploadFor(Data: _data, andImageSize: _size, andImageName: m.messageBody?.name ?? NSUUID().uuidString + ".jpg")
            }
        }
        //线上图
        else if let _path = m.messageBody?.mediaUrl,_path.isEmpty == false {
            var _size:CGSize = .init(width: VXIUIConfig.shareInstance.cellMaxWidth() / 4, height: VXIUIConfig.shareInstance.cellMaxWidth() / 3)
            if let _w = m.messageBody?.width,let _h = m.messageBody?.height {
                _size = CGSize.init(width: CGFloat(_w), height: CGFloat(_h))
            }
            _tempBlock(TGSUIModel.pictureResetSizeFor(Image: nil,orOriginalSize: _size),nil,false)
            
            //加载图片并缓存
            let _url = TGSUIModel.getFileRealUrlFor(Path: _path, andisThumbnail: true)
            guard let _newUrl = URL.init(string: _url) else { return }
            self.messagePhotoImageView.yy_setImage(with: _newUrl,
                                                   placeholder: VXIUIConfig.shareInstance.cellDefaultImage(),
                                                   options: VXIUIConfig.shareInstance.requestOption()) { [weak self] (_img:UIImage?, _:URL, _:YYWebImageFromType, _:YYWebImageStage, _error:Error?) in
                guard let self = self else { return }
                if let _image = _img{
                    _tempBlock(TGSUIModel.pictureResetSizeFor(Image: _image, orOriginalSize: nil),nil,true)
                    
                    self.longPressImg = _image
                    //m.messageBody?.image = _image.jpegData(compressionQuality: VXIUIConfig.shareInstance.imageCompressionQuality())
                }
            }
        }
    }
    
    
    //MARK: 点击事件
    @objc private func tapHandle() {
        if let  _m = self.message {
            delegate?.epDidImageClick(FromView: self.messagePhotoImageView,
                                      andToView: UIApplication.shared.keyWindow?.rootViewController?.view ?? self,
                                      andMessageUUId: _m.messageUUId,
                                      andMessagecmid: _m.cMid,
                                      andFinishBlock: {[weak self] (pbv:YYPhotoBrowseView) in
                guard let self = self else { return }
                let longpress = UILongPressGestureRecognizer.init(target: self,
                                                                  action: #selector(self.longGestureAction(sender:)))
                pbv.addGestureRecognizer(longpress)
            })
        }
    }
    
    
    //MARK: 上传失败重新上传并发送消息
    /// 发送图片消息
    /// - Parameters:
    ///   - _data: <#_data description#>
    ///   - _size: <#_size description#>
    ///   - _n: <#_n description#>
    ///   - _ic: <#_ic description#>
    private func reloadUploadFor(Data _data:Data,
                                 andImageSize _size:CGSize,
                                 andImageName _n:String,
                                 isClick _ic:Bool = false){
        if let _d = self.message,self.cellisFirstResponse == true || (self.cellisFirstResponse == false && _ic) {
            if MessageDirection.init(rawValue: _d.renderMemberType ?? 0).isSend() == true && (_d.mId ??  0) <= 0 {
                
                VXIChatViewModel.conversationUploadFor(FileData: _data,
                                                       andFileName: _n,
                                                       andMimeType: TGSUIModel.getMimeTypeFor(FileName: _n),
                                                       withFinishblock: {[weak self] (_isOk:Bool, _info:String, _:Data,_:String) in
                    guard let self = self else { return }
                    if _isOk {
                        self.btnError.isHidden = true
                        self.wCircleView.isHidden = true
                        
                        //图片上传成功，发送消息
                        self.delegate?.epSendMessage(MessageBodyType.image.rawValue, _d.cMid ?? UUID().uuidString, [
                            "width": _size.width,
                            "height": _size.height,
                            "mediaUrl": _info as Any,
                        ])
                    }
                    else{
                        //上传失败，重发
                        self.cellisFirstResponse = false
                        self.btnError.isHidden = false
                        self.wCircleView.isHidden = true
                        VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _info)
                    }
                    
                },
                                                       andProgressBlock: {[weak self] _progress in
                    guard let self = self else { return }
                    self.wCircleView.isHidden = false
                    self.wCircleView.startAnimationDrawFor(Current: _progress,
                                                           andTotal: 1,
                                                           andShowInfo: "")
                    if _progress >= 1 {
                        self.wCircleView.isHidden = true
                    }
                },
                                                       andLoading: false,
                                                       andisFullPath: false)
            }
        }
    }
    
    
    //MARK: 长按保存或识别二维码
    /// 长按事件
    /// - Parameter sender: <#sender description#>
    @objc private func longGestureAction(sender:UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .began:
            let alertAction = UIAlertController.init(title: nil, message: "选择操作", preferredStyle: .actionSheet)
            
            let saveLocalhost = UIAlertAction.init(title: "保存图片到本地", style: .destructive) { (_:UIAlertAction) in
                if let _image = self.longPressImg {
                    TGSUIModel.saveLocalhostFor(Image: _image)
                }
                else{
                    VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "保存的图片不存在")
                }
            }
            alertAction.addAction(saveLocalhost)
            
            let identifyQRCode = UIAlertAction.init(title: "识别图中二维码", style: .default) { (_:UIAlertAction) in
                if let _image = self.longPressImg {
                    if let _strInfo = TGSUIModel.discernQRCodeFor(Image: _image) {
                        
                        //关闭当前预览图层
                        let _select = #selector(YYPhotoBrowseView.dismiss as (YYPhotoBrowseView) -> () -> Void)
                        sender.view?.perform(_select)
                        
                        if let _url = URL(string: _strInfo.yl_urlEncoded()),UIApplication.shared.canOpenURL(_url){
                            UIApplication.shared.canOpenURL(_url)
                        }
                        else if _strInfo.isEmpty == false {
                            VXIUIConfig.shareInstance.keyWindow().showSuccessInfo(at: _strInfo)
                        }
                    }
                    else{
                        VXIUIConfig.shareInstance.keyWindow().showErrInfo(at:"识别失败，请稍后重试")
                    }
                }
                else{
                    VXIUIConfig.shareInstance.keyWindow().showErrInfo(at:"识别的图片不存在")
                }
            }
            alertAction.addAction(identifyQRCode)
            alertAction.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alertAction, animated: true, completion: {
                print("图片操作")
            })
            break
            
        default:
            break
        }
    }
}

