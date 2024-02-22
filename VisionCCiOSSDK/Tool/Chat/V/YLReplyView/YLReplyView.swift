//
//  YLReplyView.swift
//  YLBaseChat
//
//  Created by yl on 17/5/15.
//  Copyright © 2017年 yl. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import Photos

// 表情框
fileprivate let defaultPanelViewH:CGFloat = VXIUIConfig.shareInstance.xp_safeDistanceBottom() + VXIUIConfig.shareInstance.faceFootViewHeight()

enum YLReplyViewState:Int {
    // 普通状态
    case normal = 1
    // 输入状态
    case input
    // 表情状态
    case face
    // 更多状态
    case more
    // 录音状态
    case record
}

//MARK: - YLReplyView
class YLReplyView: UIView {
    
    fileprivate var timer:Timer? = nil
    
    var evReplyViewState:YLReplyViewState = YLReplyViewState.normal
    
    var recordingView:RecordingView!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
        timer = nil
    }
    
    //MARK: - override
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func layoutUI() {
        
        // 默认大小
        frame = CGRect(x: 0, y: 0,
                       width: VXIUIConfig.shareInstance.YLScreenWidth,
                       height: VXIUIConfig.shareInstance.YLScreenHeight)
        backgroundColor = .clear
        
        addSubview(self.evInputView)
        
        editInputViewConstraintWithBottom(0 - VXIUIConfig.shareInstance.xp_safeDistanceBottom())
        
        if self.evFacePanelView != nil {
            editPanelViewConstraintWithPanelView(self.evFacePanelView!)
        }
        
        // 录音样式
        recordingView = RecordingView(frame: CGRect.zero)
        recordingView.center = center
        recordingView.isHidden = true
        
        addSubview(recordingView)
        
        //[S]键盘监听
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification, object: nil).subscribe {[weak self] (_input:Event<Notification>) in
            guard let self = self else { return }
            guard let not = _input.element else { return }
            
            if let info:NSDictionary = not.userInfo as NSDictionary? {
                if let value:NSValue = info.object(forKey: "UIKeyboardFrameEndUserInfoKey") as! NSValue? {
                    
                    let keyboardRect:CGRect? = value.cgRectValue
                    
                    if evInputView.inputTextView.isFirstResponder {
                        editInputViewConstraintWithBottom(-(keyboardRect?.size.height)!)
                        perform(#selector(YLReplyView.efDidRecoverReplyViewStateForEdit), with: nil, afterDelay: 0.0)
                    }
                }
            }
        }.disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification, object: nil).subscribe {[weak self] (_:Event<Notification>) in
            guard let self = self else { return }
            
            if evReplyViewState != YLReplyViewState.face &&
                evReplyViewState != YLReplyViewState.more &&
                evReplyViewState != YLReplyViewState.record &&
                evReplyViewState != YLReplyViewState.normal {
                
                if evInputView.inputTextView.isFirstResponder {
                    editInputViewConstraintWithBottom(0-VXIUIConfig.shareInstance.xp_safeDistanceBottom())
                    updateReplyViewState(YLReplyViewState.normal)
                }
            }
        }.disposed(by: rx.disposeBag)
        //[E]
        
        // recordOperationBtn 添加手势
        let touchGestureRecognizer = YLTouchesGestureRecognizer(target: self, action: #selector(YLReplyView.recoverGesticulation(_:)))
        
        evInputView.recordOperationBtn.addGestureRecognizer(touchGestureRecognizer)
    }
    
    // 编辑InputView 约束
    fileprivate func editInputViewConstraintWithBottom(_ bottom:CGFloat) {
        
        evInputView.textViewFrame.bottom = evInputView.topMenuView.isHidden ? -5 : -5 - VXIUIConfig.shareInstance.faceEmojiMenuheight()
        evInputView.snp.remakeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(bottom)
            make.height.equalTo(defaultInputViewH).priority(750)
        }
        layoutIfNeeded()
    }
    
    // 编辑Panel 约束
    fileprivate func editPanelViewConstraintWithPanelView(_ panelView:UIView) {
        
        panelView.isHidden = true
        addSubview(panelView)
        
        panelView.snp.makeConstraints {[weak self] (make) in
            guard let self = self else { return }
            make.left.right.equalTo(0)
            make.top.equalTo(evInputView.snp.bottom)
            make.height.equalTo(defaultPanelViewH)
        }
        
    }
    
    //MARK: 表情面板
    /// 表情面板
    lazy var evFacePanelView:YLFaceView? = {
        let _v = YLFaceView.init(frame: .init(x: 0, y: 0, width: VXIUIConfig.shareInstance.YLScreenWidth, height: defaultPanelViewH))
        _v.delegate = self
        return _v
    }()
    
    //MARK: 输入面板
    /// 输入面板
    lazy var evInputView:YLInputView = {
        let _v = YLInputView(frame: CGRect.zero)
        _v.delegate = self
        
        return _v
    }()
    
    // 发送消息
    fileprivate func sendMessageText() {
        
        var text = ""
        
        let attributedText = evInputView.inputTextView.attributedText!
        
        if attributedText.length == 0 {return}
        
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length), options: .longestEffectiveRangeNotRequired) { (attrs:[NSAttributedString.Key:Any], range:NSRange, _) in
            
            if let attachment = attrs[NSAttributedString.Key("NSAttachment")] as? NSTextAttachment  {
                
                let img = attachment.image!
                
                if (img.yl_tag?.hasPrefix("["))! && (img.yl_tag?.hasSuffix("]"))! {
                    text = text + img.yl_tag!
                }
                
            }else{
                
                let tmptext:String = attributedText.attributedSubstring(from: range).string
                text = text + tmptext
                
            }
            
        }
        
        evInputView.selectedRange = NSMakeRange(0, 0);
        evInputView.inputTextView.text = ""
        
        evInputView.textViewDidChanged()
        
        efSendMessageText(text)
    }
    
    
    fileprivate func didFinishPickingPhotosHandle(photos: [UIImage]?, _: [Any]?,_: Bool) -> Void {
        
    }
    
    // 设置显示用户讲话音量
    @objc fileprivate func setVoiceSoundSize() {
        recordingView.volume = VoiceManager.shared.getRecordVolume()
    }
    
    // 录音处理
    fileprivate func startRecording() {
        recordingView.recordingState = RecordingState.volumn
        recordingView.volume = 0.0
        VoiceManager.shared.beginRecord()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: (#selector(YLReplyView.setVoiceSoundSize)), userInfo: nil, repeats: true)
    }
    fileprivate func cancelRecording() {
        timer?.invalidate()
        timer = nil
        recordingView.isHidden = true
        VoiceManager.shared.cancelRecord()
    }
    fileprivate func sendRecording() {
        timer?.invalidate()
        timer = nil
        if VoiceManager.shared.duration <= 1 {
            recordingView.recordingState = RecordingState.timeTooShort
            VoiceManager.shared.cancelRecord()
        }else {
            recordingView.isHidden = true
            VoiceManager.shared.stopRecord()
            efSendMessageVoice(VoiceManager.shared.recorder_file_path, VoiceManager.shared.duration)
        }
    }
    fileprivate func slideUpToCancelTheRecording() {
        recordingView.recordingState = RecordingState.volumn
    }
    fileprivate func loosenCancelRecording() {
        recordingView.recordingState = RecordingState.cancel
    }
    
    // recordOperationBtn 手势处理
    @objc fileprivate func recoverGesticulation(_ gesticulation:UIGestureRecognizer) {
        
        if gesticulation.state == UIGestureRecognizer.State.began {
            evInputView.recordOperationBtn.isSelected = true
            evInputView.recordOperationBtn.backgroundColor = .colorFromRGB(0xE0E0E0)
            
            startRecording()
        }else if gesticulation.state == UIGestureRecognizer.State.ended {
            
            let point = gesticulation.location(in: gesticulation.view)
            evInputView.recordOperationBtn.isSelected = false
            evInputView.recordOperationBtn.backgroundColor = .colorFromRGB(0xF5F5F5)
            
            if point.y > 0 {
                sendRecording()
            }else{
                cancelRecording()
            }
        }else if gesticulation.state == UIGestureRecognizer.State.changed {
            
            let point = gesticulation.location(in: gesticulation.view)
            if point.y > 0 {
                slideUpToCancelTheRecording()
            }else{
                loosenCancelRecording()
            }
        }
    }
}


//MARK: -
extension YLReplyView {
    
    //MARK: 选择相片
    @objc fileprivate func handlePhotos() {
        if let vc = self.getVC(){
            let config = ZLPhotoConfiguration.default()
            config.allowSelectImage = true
            config.allowSelectVideo = true //视频和图片选择在一起
            config.downloadVideoBeforeSelecting = true
            config.maxSelectCount = 9
            
            let photoPicker = ZLPhotoPreviewSheet()
            photoPicker.selectImageBlock = { [weak self] (results, _) in
                guard let self = self else { return }
                self.actionFor(SelectResult: results)
            }
            
            photoPicker.showPhotoLibrary(sender: vc)
        }
    }
    
    private func actionFor(SelectResult results:[ZLResultModel]) {
        //图片
        let arrImages:[UIImage] = results.filter { $0.asset.mediaType == .image }.compactMap { $0.image }
        let arrNames:[String] = results.filter { $0.asset.mediaType == .image }.compactMap { $0.asset.localIdentifier + ".jpg" }
        if arrImages.count > 0 {
            self.efSendMessageImage(arrImages,arrNames)
        }
        
        //视频
        let arrVideos:[ZLResultModel] = results.filter { $0.asset.mediaType == .video }
        if arrVideos.count > 0 {
            for _model in arrVideos {
                PHCachingImageManager().requestAVAsset(forVideo: _model.asset,
                                                       options: nil) { (asset:AVAsset?, _:AVAudioMix?, _:[AnyHashable : Any]?) in
                    DispatchQueue.main.async {
                        if let _asset = asset as? AVURLAsset {
                            self.efSendMessageVideo(_asset.url.path,
                                                    _asset.url.lastPathComponent,
                                                    _model.image,
                                                    _model.asset.duration * 1000,//单位是秒，服务端 统一规定单位毫秒
                                                    _model.image.size)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: 选择附件
    /// 选择附件
    @objc fileprivate func btnChoiceAnnex(sender:UIButton?) {
        VXIDownLoadFileManager.share.openFile()//打开文档
        VXIDownLoadFileManager.share.choiceFileInfoBlock = nil
        VXIDownLoadFileManager.share.choiceFileInfoBlock = {[weak self] (_filePath:URL?,_data:Data?,_fileName:String?,_fileSize:Double?) in
            guard let self = self else { return }
            if _data != nil {
                let _name = _fileName ?? ""
                //判断是否为视频
                if TGSUIModel.isVideoFor(FileName: _name),_filePath != nil {
                    let _p = VXIUIConfig.shareInstance.getCachePath() + "/\(_name.yl_isChinese() ? _name.yl_urlEncoded() : _name)"
                    if FileManager.default.createFile(atPath: _p, contents: _data!) {
                        //获取时长
                        let _url = NSURL.init(fileURLWithPath: _p) as URL
                        let _duration = AVAsset(url: _url).duration.seconds
                        
                        let _img:UIImage = UIImage(data: _data!) ?? .init()
                        self.efSendMessageVideo(_p,
                                                _name,
                                                _img,
                                                _duration * 1000,//单位是秒，服务端 统一规定单位毫秒
                                                .zero)
                    }
                    else{
                        debugPrint("附件获取视频处理失败")
                    }
                }
                //判断是否为图片
                else if TGSUIModel.isPictureFor(FileName: _name),
                        let _img = UIImage.init(data: _data!) {
                    self.efSendMessageImage([_img],[_name])
                }
                else{
                    self.efSendMessageFile(_filePath?.path,_data!, _name, _fileSize ?? 0)
                }
            }
            else{
                debugPrint("文件信息不存在")
            }
        }
    }
}


// MARK: - 子类可以重写/外部调用
extension YLReplyView{
    
    // 已经恢复普通状态
    @objc func efDidRecoverReplyViewStateForNormal() {}
    
    // 已经恢复编辑状态
    @objc func efDidRecoverReplyViewStateForEdit() {}
    
    // 收起输入框
    @objc func efPackUpInputView() {
        if  evReplyViewState == .input ||
                evReplyViewState == .face ||
                evReplyViewState == .more {
            updateReplyViewState(YLReplyViewState.normal)
        }
    }
    
    // 发送消息
    @objc func efSendMessageText(_ _text: String) {}
    @objc func efSendMessageImage(_ _images:[UIImage]?, _ names:[String]?) {}
    /// 发送自定义图片表情
    @objc func efSendFaceoImage(_ _name: String, _ _mediaUrl: String){}
    @objc func efSendMessageVoice(_ _path: String?,_ _duration: Double){}
    
    /// 发送附件
    /// - Parameters:
    ///   - filePath: 附件的地址
    ///   - _fileName: 附件名称(带后缀)
    ///   - _fileSize: 附件大小(KB 为单位)
    @objc func efSendMessageFile(_ _path:String?,_ _data:Data,_ _fileName:String,_ _fileSize:Double) {}
    
    /// 发送视频消息
    /// - Parameters:
    ///   - _localPath: String 本地视频地址
    ///   - _videoName: String 名称
    ///   - _coverImage: UIImage 封面图
    ///   - _duration: TimeInterval 时长(单位：秒)
    @objc func efSendMessageVideo(_ _localPath:String,_ _videoName:String,_ _coverImage:UIImage,_ _duration:TimeInterval,_ _imgSize:CGSize){}
    
    /// 发送单商品信息
    @objc func efSendMessageCardSingle(_ _productId:String?){}
    
    /// 发送多单商品信息
    @objc func efSendMessageCardMutable(_ _productIds:[String]?){}
    
    /// 发送评价消息
    @objc func efSendMessageEvaluate(){}
    
    /// 发送留言消息
    @objc func efSendLeaveMessage(){}
    
}


// MARK: - 状态切换
extension YLReplyView{
    
    fileprivate func updateReplyViewState(_ state:YLReplyViewState) {
        
        if(evReplyViewState == state) {return}
        
        resetInputView()
        
        evReplyViewState = state
        
        switch state {
        case .normal:
            
            evInputView.inputTextView.resignFirstResponder()
            evInputView.textViewDidChanged()
            
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.editInputViewConstraintWithBottom(0 - VXIUIConfig.shareInstance.xp_safeDistanceBottom())
            }, completion: { [weak self] (_) in
                guard let self = self else { return }
                self.evFacePanelView?.isHidden = true
            })
            
            perform(#selector(YLReplyView.efDidRecoverReplyViewStateForNormal), with: nil, afterDelay: 0.0)
            
            break
            
        case .record:
            evInputView.inputTextView.resignFirstResponder()
            
            evInputView.inputTextView.snp.remakeConstraints({ (make) in
                make.edges.equalTo(evInputView.recordOperationBtn)
            })
            
            showKeyboardBtn(evInputView.faceSenderBtn)
            
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.editInputViewConstraintWithBottom(0 - VXIUIConfig.shareInstance.xp_safeDistanceBottom())
                
            }, completion: { [weak self] (_) in
                guard let self = self else { return }
                self.evFacePanelView?.isHidden = true
                self.evInputView.recordOperationBtn.isHidden = false
                self.evInputView.inputTextView.isHidden = true
                self.evInputView.faceSenderBtn.isHidden = true
            })
            
            perform(#selector(YLReplyView.efDidRecoverReplyViewStateForEdit), with: nil, afterDelay: 0.0)
            
            break
            
        case .face:
            
            evFacePanelView?.isHidden = false
            evInputView.inputTextView.resignFirstResponder()
            
            evInputView.textViewDidChanged()
            
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.editInputViewConstraintWithBottom(-defaultPanelViewH)
            })
            
            perform(#selector(YLReplyView.efDidRecoverReplyViewStateForEdit), with: nil, afterDelay: 0.0)
            
            break
            
        case .more:
            evFacePanelView?.isHidden = true
            evInputView.inputTextView.resignFirstResponder()
            evInputView.textViewDidChanged()
            
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.editInputViewConstraintWithBottom(-defaultPanelViewH)
            })
            
            perform(#selector(YLReplyView.efDidRecoverReplyViewStateForEdit), with: nil, afterDelay: 0.0)
            
            break
            
        case .input:
            evInputView.inputTextView.becomeFirstResponder()
            evInputView.textViewDidChanged()
            
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.editInputViewConstraintWithBottom(0 - VXIUIConfig.shareInstance.xp_safeDistanceBottom())
            }, completion: { [weak self] (_) in
                guard let self = self else { return }
                self.evFacePanelView?.isHidden = true
            })
            
            perform(#selector(YLReplyView.efDidRecoverReplyViewStateForNormal), with: nil, afterDelay: 0.0)
            
            break
            
        }
        
    }
    
    // 恢复输入框的初始状态
    fileprivate func resetInputView() {
        evInputView.recordBtn.isHidden = false
        evInputView.inputTextView.isHidden = false
        evInputView.topMenuView.isHidden = false
        evInputView.faceSenderBtn.isHidden = false
        evInputView.recordOperationBtn.isHidden = true
    }
    
    // 显示键盘按钮.隐藏点击的按钮
    fileprivate func showKeyboardBtn(_ btn:UIButton) {
        btn.isHidden = true
        layoutIfNeeded()
    }
    
}


// MARK: - YLFaceViewDelegate
extension YLReplyView:YLFaceViewDelegate {
    
    func epButtonClick(_ _type: YLInputViewBtnState) {
        if _type == .face {
            updateReplyViewState(YLReplyViewState.input)
        }
        else{
            switch _type {
            case .annex:
                self.btnChoiceAnnex(sender: nil)
                break
                
            case .image:
                self.handlePhotos()
                break
                
            case .evaluate:
                self.endEditing(true)
                VXIUIConfig.shareInstance.keyWindow().endEditing(true)
                self.efSendMessageEvaluate()
                break
                
            default:
                break
            }
        }
    }
    
    /// 发送自定义表情图片
    func epSendFaceoImage(_ _name: String, _ _mediaUrl: String) {
        self.efSendFaceoImage(_name, _mediaUrl)
    }
    
    func epSendMessage() {
        sendMessageText()
    }
    
    func epInsertFace(_ emoji: String) {
        var _atte = NSMutableAttributedString.init()
        if let _txt = evInputView.inputTextView.attributedText {
            _atte = NSMutableAttributedString.init(attributedString: _txt)
        }
        _atte.append(NSAttributedString.init(string: emoji))
        evInputView.inputTextView.attributedText = _atte
        
        evInputView.textViewDidChanged()
    }
    
    func epDeleteTextFromTheBack() {
        var mutableStr = NSMutableAttributedString.init()
        if let _txt = evInputView.inputTextView.attributedText {
            mutableStr = NSMutableAttributedString(attributedString: _txt)
        }
        
        if mutableStr.length > 0 {
            var _rang = NSRange(location: mutableStr.length-2, length: 2)
            if TGSUIModel.stringContainsEmoji(string: mutableStr.attributedSubstring(from: NSRange(location: mutableStr.length-2, length: 2)).string) == false {
                _rang = NSRange(location: mutableStr.length-1, length: 1)
            }
            mutableStr.deleteCharacters(in: _rang)
            
            evInputView.inputTextView.attributedText = mutableStr
            evInputView.selectedRange = NSRange(location: mutableStr.length, length: 0)
        }
    }
    
}


// MARK: - YLInputViewDelegate
extension YLReplyView : YLInputViewDelegate{
    
    // 按钮点击
    func epBtnClickHandle(_ inputViewBtnState:YLInputViewBtnState) {
        
        switch inputViewBtnState {
        case .record:
            if evReplyViewState == .record {
                evInputView.recordBtn.isSelected = false
                updateReplyViewState(YLReplyViewState.normal)
            }
            else{
                updateReplyViewState(YLReplyViewState.record)
                evInputView.recordBtn.isSelected = true
            }
            break
        case .face:
            if evReplyViewState == .face {
                updateReplyViewState(YLReplyViewState.normal)
            }
            else{
                updateReplyViewState(YLReplyViewState.face)
            }
            break
        case .more:
            updateReplyViewState(YLReplyViewState.more)
            break
        case .keyboard:
            updateReplyViewState(YLReplyViewState.input)
            break
        case .send:
            
            break
            
        case .annex:
            self.btnChoiceAnnex(sender: nil)
            break
            
        case .image:
            self.handlePhotos()
            break
            
        case .evaluate:
            self.endEditing(true)
            window?.endEditing(true)
            self.efSendMessageEvaluate()
            break
        }
    }
    
    /// 发送操作
    func epSendMessageText() {
        sendMessageText()
    }
    
    /// 文本消息
    func epSendMessageText(_ _txt: String) {
        efSendMessageText(_txt)
    }
    
    /// 留言消息
    func epSendLeaveMessage() {
        efSendLeaveMessage()
    }
}
