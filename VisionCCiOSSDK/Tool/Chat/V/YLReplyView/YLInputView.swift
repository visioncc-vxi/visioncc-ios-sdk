//
//  YLInputView.swift
//  YLBaseChat
//
//  Created by yl on 17/5/15.
//  Copyright © 2017年 yl. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import SocketIO
@_implementationOnly import VisionCCiOSSDKEngine

let defaultInputViewH = 46.0
let defaultInputViewBtnWH = 30.0

fileprivate let defaultTextViewMaxH = 100.0
fileprivate let defaultTextViewMinH = 38.0

enum YLInputViewBtnState:Int{
    case record = 101 // 录音
    case face         // 表情
    case more         // 更多
    case keyboard     // 键盘
    case send         // 发送
    case annex        // 附件
    case image        // 图片(视频)
    case evaluate     // 满意度评价
}

protocol YLInputViewDelegate:NSObjectProtocol {
    // 按钮点击
    func epBtnClickHandle(_ inputViewBtnState:YLInputViewBtnState)
    // 发送操作
    func epSendMessageText()
    func epSendMessageText(_ _txt:String)
    // 发送留言消息
    func epSendLeaveMessage()
    
}

struct YLTextViewFrame {
    var top:CGFloat    = 5
    var bottom:CGFloat = -5
    var left:CGFloat   = 10
    var right:CGFloat  = -15
}


/// 底部输入面板
class YLInputView: UIView {
    
    weak var delegate:YLInputViewDelegate?
    
    private let cell_font:UIFont = .systemFont(ofSize: 15, weight: .regular)
    private let cell_identify:String = "YLInputView.identify"
    private let cell_margin:CGFloat = 15
    private let cell_height:CGFloat = 25
    private let cell_margin_top:CGFloat = 8
    private let cell_margin_bottom:CGFloat = 9
    private let cell_talk_size:CGSize = .init(width: 20, height: 38)
    
    
    //MARK: - override
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
        
        //获取数据
        self.arrList = TGSUIModel.getSystemInfoModel(key: VXIUIConfig.shareInstance.getGlobalCgaKey())?.shortcuts
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        
        if self.subviews.contains(self.listCollectionView){
            self.listCollectionView.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.right.top.equalTo(0)
                make.height.equalTo(cell_height + cell_margin_top + cell_margin_bottom)
            }
        }
        
        if self.subviews.contains(self.recordBtn) {
            self.recordBtn.snp.makeConstraints {[weak self] (make) in
                guard let self = self else { return }
                make.height.width.equalTo(defaultInputViewBtnWH)
                make.left.equalTo(5)
                make.bottom.equalTo(self.inputTextView.snp.bottom).offset(-2.5)
            }
        }
        
        if self.subviews.contains(self.inputTextView){
            inputTextView.snp.remakeConstraints {[weak self] (make) in
                guard let self = self else { return }
                make.top.equalTo(textViewFrame.top)
                make.bottom.equalTo(textViewFrame.bottom)
                make.left.equalTo(textViewFrame.left)
                make.right.equalTo(textViewFrame.right)
                make.height.equalTo(defaultTextViewMinH)
            }
        }
        
        if self.subviews.contains(self.faceSenderBtn){
            self.faceSenderBtn.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.height.equalTo(28)
                make.right.equalTo(self.inputTextView.snp.right).offset(-10)
                make.centerY.equalTo(self.inputTextView.snp.centerY)
            }
        }
        
        if self.subviews.contains(self.recordOperationBtn){
            recordOperationBtn.snp.makeConstraints {[weak self] (make) in
                guard let self = self else { return }
                make.top.equalTo(textViewFrame.top)
                make.bottom.equalTo(textViewFrame.bottom)
                make.left.equalTo(textViewFrame.left)
                make.right.equalTo(textViewFrame.right)
            }
        }
        
        if self.subviews.contains(self.topMenuView){
            self.topMenuView.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.right.bottom.equalTo(0)
                make.top.equalTo(self.inputTextView.snp.bottom)
                make.height.equalTo(VXIUIConfig.shareInstance.faceEmojiMenuheight())
            }
        }
        
        super.updateConstraints()
    }
    
    // 初始化UI
    fileprivate func layoutUI() {
        self.backgroundColor = VXIUIConfig.shareInstance.appViewBottomBackgroundColor()
        isUserInteractionEnabled = true
        
        self.addSubview(self.listCollectionView) //快捷回复
        
        self.addSubview(self.recordBtn)          //语音
        self.addSubview(self.recordOperationBtn)
        
        self.addSubview(self.inputTextView)      //输入框
        self.addSubview(self.faceSenderBtn)
        
        self.addSubview(self.topMenuView)        //菜单面板
        
        NotificationCenter.default.rx.notification(UITextView.textDidChangeNotification, object: nil).subscribe {[weak self] (_:Event<Notification>) in
            guard let self = self else { return }
            self.textViewDidChanged()
        }.disposed(by: rx.disposeBag)
        
        /// 快捷回复语显示或隐藏
        NotificationCenter.default.rx.notification(VXIUIConfig.shareInstance.getInputQuickReplyHandleKey(),object: nil).subscribe {[weak self] (_notice:Event<Notification>) in
            guard let self = self else { return }
            guard let _userInfo = _notice.element?.userInfo else { return }
            
            let _isShow:Bool? = _userInfo["isShow"] as? Bool
            if _isShow == true,let _data = TGSUIModel.getSystemInfoModel(key: VXIUIConfig.shareInstance.getGlobalCgaKey())?.shortcuts,_data.count > 0 {
                self.arrList = _data
            }
            else {
                self.arrList = nil
            }
            setNeedsUpdateConstraints()
        }.disposed(by: rx.disposeBag)
        
        setNeedsUpdateConstraints()
    }
    
    deinit {
        debugPrint("YLInputView - 已销毁")
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - 输入框
    /// 输入框
    public private(set) lazy var inputTextView:UITextView = {[unowned self] in
        let _txt = UITextView.init(frame:.zero)
        _txt.shouldIgnoreScrollingAdjustment = true
        _txt.contentInset = .init(top: 9, left: 10, bottom: 9, right: 48)
        
        //防止向上偏移
        _txt.inputAccessoryView = UIView.init()
        _txt.keyboardDistanceFromTextField = VXIUIConfig.shareInstance.faceEmojiMenuheight()
        
        _txt.delegate = self
        _txt.isOpaque = false
        
        _txt.textColor = .colorFromRGB(0x424242)
        _txt.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        _txt.backgroundColor = .colorFromRGB(0xF5F5F5)
        _txt.layer.cornerRadius = 19
        _txt.keyboardType = .default
        _txt.returnKeyType = .send
        
        //发送用户输入信息(1秒发一次)
        _txt.rx.text.orEmpty.changed
            .throttle(DispatchTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
            .asObservable()
            .subscribe(onNext: { [weak self] response in
                debugPrint(response)
                VXISocketManager.share.socketIOClient?.rawEmitView.emit(SocketSendEvent.typing.rawValue,response)
            }).disposed(by: rx.disposeBag)
        
        return _txt
    }()
    
    lazy var textViewFrame:YLTextViewFrame = {
        var _v:YLTextViewFrame = YLTextViewFrame()
        _v.left = 42
        _v.top = cell_height + cell_margin_top + cell_margin_bottom
        return _v
    }()
    
    //MARK: 菜单面板
    /// 菜单面板
    public private(set) lazy var topMenuView:YLTopMenuView = {
        let _v = YLTopMenuView.init(frame: .zero)
        _v.backgroundColor = .clear
        _v.clickBlock = {[weak self] (_type) in
            guard let self = self else { return }
            self.delegate?.epBtnClickHandle(_type)
        }
        
        return  _v
    }()
    
    //MARK: 录音按钮
    /// 录音按钮
    public private(set) lazy var recordBtn:UIButton = {[unowned self] in
        let _btn = createBtn("foot_sound")
        _btn.setBackgroundImage(UIImage(named: "foot_sound_down", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil), for: .selected)
        _btn.tag = YLInputViewBtnState.record.rawValue
        
        return _btn
    }()
    
    public private(set) lazy var recordOperationBtn:UIButton = {
        let _btn = UIButton.init(type: .custom)
        _btn.layer.cornerRadius = cell_talk_size.height * 0.5
        
        _btn.setTitle("按住 说话", for: UIControl.State.normal)
        _btn.setTitle("松开 结束", for: UIControl.State.selected)
        _btn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        
        _btn.backgroundColor = .colorFromRGB(0xF5F5F5)
        _btn.isHidden = true
        
        return _btn
    }()
    
    //MARK: 表情
    /// 发送按钮
    public private(set) lazy var faceSenderBtn:UIButton = {[unowned self] in
        let _btn = TGSUIModel.createBtn(rect: .zero,
                                        image: UIImage(named: "foot_face_sender.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil),
                                        backgroundColor: .colorFromRGB(0x757575))
        _btn.addTarget(self, action: #selector(YLInputView.btnClickHandle(_:)), for: UIControl.Event.touchUpInside)
        _btn.layer.cornerRadius = 14
        _btn.tag = YLInputViewBtnState.send.rawValue
        
        return _btn
    }()
    
    lazy var selectedRange:NSRange = NSRange(location: 0, length: 0)
    
    //MARK: 快捷回复语
    public private(set) lazy var listCollectionView:UICollectionView = {[unowned self] in
        let _v = TGSUIModel.createCollectionViewFor(ScrollDirection: .horizontal,
                                                    andBackgroundColor: .clear,
                                                    withLayout: nil)
        _v.delegate = self
        _v.dataSource = self
        _v.showsHorizontalScrollIndicator = false
        
        //注册列
        _v.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cell_identify)
        
        return _v
    }()
    
    private lazy var arrList:[ShortcutsModel]? = TGSUIModel.getSystemInfoModel(key: VXIUIConfig.shareInstance.getGlobalCgaKey())?.shortcuts {
        didSet{
            //隐藏
            if self.arrList == nil || (self.arrList?.count ?? 0) <= 0 {
                self.textViewFrame.top = 5
                self.inputTextView.snp.updateConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.top.equalTo(self.textViewFrame.top)
                }
                
                self.listCollectionView.removeFromSuperview()
            }
            //显示
            else{
                self.textViewFrame.top = cell_height + cell_margin_top + cell_margin_bottom
                self.inputTextView.snp.updateConstraints {[weak self] make in
                    guard let self = self else { return }
                    make.top.equalTo(textViewFrame.top)
                }
                
                if self.subviews.contains(self.listCollectionView) {
                    self.listCollectionView.snp.updateConstraints {[weak self] make in
                        guard let self = self else { return }
                        make.height.equalTo(cell_height + cell_margin_top + cell_margin_bottom)
                    }
                }
                else{
                    self.addSubview(self.listCollectionView)
                    self.listCollectionView.snp.makeConstraints {[weak self] make in
                        guard let self = self else { return }
                        make.left.right.top.equalTo(0)
                        make.height.equalTo(cell_height + cell_margin_top + cell_margin_bottom)
                    }
                }
                
                self.listCollectionView.reloadData()
            }
        }
    }
}


// MARK: -
extension YLInputView {
    
    //MARK: 创建按钮
    // 创建按钮
    fileprivate func createBtn(_ imageName:String)-> UIButton {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(named: imageName, in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil), for: UIControl.State.normal)
        
        btn.addTarget(self, action: #selector(YLInputView.btnClickHandle(_:)), for: UIControl.Event.touchUpInside)
        return btn
    }
    
    // 按钮点击处理
    @objc fileprivate func btnClickHandle(_ btn:UIButton){
        if btn.tag == YLInputViewBtnState.send.rawValue {
            delegate?.epSendMessageText()
        }
        else{
            delegate?.epBtnClickHandle(YLInputViewBtnState(rawValue: btn.tag)!)
        }
    }
    
    //MARK: 文本内容改变
    // textView 文本内容改变
    @objc func textViewDidChanged() {
        perform(#selector(YLInputView.updateDisplayByInputContentTextChange), with: nil, afterDelay: 0.1)
    }
    
    @objc fileprivate func updateDisplayByInputContentTextChange() {
        
        var height = ceilf(Float(inputTextView.sizeThatFits(inputTextView.frame.size).height))
        
        if height <= Float(defaultTextViewMinH) {
            height = Float(defaultTextViewMinH)
        }else if height >= Float(defaultTextViewMaxH) {
            height = Float(defaultTextViewMaxH)
        }
        
        inputTextView.snp.remakeConstraints {[weak self] (make) in
            guard let self = self else { return }
            make.top.equalTo(textViewFrame.top)
            make.bottom.equalTo(textViewFrame.bottom)
            make.left.equalTo(textViewFrame.left)
            make.right.equalTo(textViewFrame.right)
            make.height.equalTo(height)
        }
        
        layoutIfNeeded()
    }
}


// MARK: - UITextViewDelegate
extension YLInputView : UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        IQKeyboardManager.shared.enable = true
        delegate?.epBtnClickHandle(YLInputViewBtnState.keyboard)
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        selectedRange = textView.selectedRange
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            delegate?.epSendMessageText()
            textView.text = nil
            return false
        }
        
        return true
    }
}


//MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension YLInputView : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell_identify, for: indexPath)
        
        var labName:VisionCCiOSSDKEngine.YYLabel? = cell.contentView.viewWithTag(1234) as? VisionCCiOSSDKEngine.YYLabel
        if labName == nil {
            labName = TGSUIModel.createLable(rect: .zero,
                                             text: nil,
                                             textColor: .colorFromRGB(0x424242),
                                             font: cell_font,
                                             andTextAlign: .center,
                                             andisdisplaysAsync: false)
            labName?.tag = 1234
            labName?.layer.cornerRadius = cell_height * 0.5
            labName?.layer.borderWidth = 0.68
            labName?.layer.borderColor = UIColor.colorFromRGB(0xBDBDBD).cgColor
            
            cell.contentView.addSubview(labName!)
            labName?.snp.makeConstraints({ make in
                make.edges.equalToSuperview()
            })
        }
        
        if (self.arrList?.count ?? 0) > indexPath.row {
            labName?.text = self.arrList?[indexPath.row].title
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer{
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        if (self.arrList?.count ?? 0) > indexPath.row {
            let _m = self.arrList![indexPath.row]
            guard let _txt = _m.command,_txt.isEmpty == false else {
                debugPrint(_m)
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "对应指令不存在")
                return
            }
            
            //快捷语类型  1:发送消息；2:打开Url；3:调用接口 4: 发起留言，5：传递上层应用
            switch _m.shortcutType {
            case .some(1):
                delegate?.epSendMessageText(_txt)
                break
                
            case .some(2):
                TGSUIModel.gotoWebViewFor(Path: _txt)
                break
                
            case .some(3):
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _txt)
                break
                
                //发起留言
            case .some(4):
                delegate?.epSendLeaveMessage()
                break
                
                //传递上层应用
            case .some(5):
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _txt)
                NotificationCenter.default.post(name: VXIUIConfig.shareInstance.getQuickPhrases(),
                                                object: nil, userInfo: ["5":_m])
                break
                
            default:
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "未知类型:\(_m.shortcutType ?? 0)")
                break
            }
        }
    }
    
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (self.arrList?.count ?? 0) > indexPath.row {
            let _txt:String = self.arrList![indexPath.row].title ?? ""
            let _w:CGFloat = _txt.yl_getWidthFor(Font: cell_font) + 16
            return .init(width: _w, height: cell_height)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: cell_margin_top, left: cell_margin, bottom: cell_margin_bottom, right: cell_margin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
