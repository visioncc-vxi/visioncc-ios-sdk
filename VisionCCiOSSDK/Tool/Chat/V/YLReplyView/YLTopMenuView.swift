//
//  YLTopMenuView.swift
//  Tool
//
//  Created by apple on 2024/1/12.
//

import UIKit
import SnapKit
import RxSwift
@_implementationOnly import VisionCCiOSSDKEngine

/// 顶部菜单面板
class YLTopMenuView: UIView {
    
    /// 点击事件
    var clickBlock:((_ _type:YLInputViewBtnState)->Void)?
    
    //MARK: - initView
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        if self.subviews.contains(self.btnChangeEmoji) {
            self.btnChangeEmoji.snp.makeConstraints { make in
                make.left.equalTo(0)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(VXIUIConfig.shareInstance.faceEmojiMenuheight())
            }
        }
        
        if self.subviews.contains(self.btnChoiceImage) {
            self.btnChoiceImage.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(self.btnChangeEmoji.snp.right)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(VXIUIConfig.shareInstance.faceEmojiMenuheight())
            }
        }
        
        if self.subviews.contains(self.btnChoiceAnnes) {
            self.btnChoiceAnnes.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.left.equalTo(self.btnChoiceImage.snp.right)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(VXIUIConfig.shareInstance.faceEmojiMenuheight())
            }
        }
        
        if self.subviews.contains(self.btnEvaluate) {
            self.btnEvaluate.snp.makeConstraints { make in
                make.right.equalTo(-15)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(VXIUIConfig.shareInstance.faceEmojiMenuheight())
            }
        }
        
        super.updateConstraints()
    }
    
    private func initView(){
        self.isUserInteractionEnabled = true
        self.addSubview(self.btnChangeEmoji)
        self.addSubview(self.btnChoiceImage)
        self.addSubview(self.btnChoiceAnnes)
        self.addSubview(self.btnEvaluate)
        
        //监听通知
        NotificationCenter.default.rx.notification(VXIUIConfig.shareInstance.getEnabledGuestSensitiveKey(), object: nil).subscribe {[weak self] (_input:Event<Notification>) in
            guard let self = self else { return }
            guard let _enable = _input.element?.userInfo?["isShow"] as? Bool else { return }
            self.btnEvaluate.isHidden = !_enable
        }.disposed(by: rx.disposeBag)
        
        setNeedsUpdateConstraints()
    }
    
    
    //MARK: 菜单面板
    private lazy var _bundle:Bundle? = VXIUIConfig.shareInstance.getBundle()
    
    /// emoji 标签切换
    fileprivate lazy var btnChangeEmoji:UIButton = {[unowned self] in
        let _img = UIImage(named: "foot_face_emoji.png", in: self._bundle, compatibleWith: nil)
        let _btn = TGSUIModel.createBtn(rect: .zero,
                                        image: _img)
        
        _btn.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            self.clickBlock?(YLInputViewBtnState.face)
        }.disposed(by: rx.disposeBag)
        
        return _btn
    }()
    
    /// 选择图片
    fileprivate lazy var btnChoiceImage:UIButton = {[unowned self] in
        let _img = UIImage(named: "foot_face_image.png", in:self._bundle, compatibleWith: nil)
        let _btn = TGSUIModel.createBtn(rect: .zero,
                                        image: _img)
        
        _btn.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            self.clickBlock?(YLInputViewBtnState.image)
        }.disposed(by: rx.disposeBag)
        
        return _btn
    }()
    
    /// 选择附件
    fileprivate lazy var btnChoiceAnnes:UIButton = {[unowned self] in
        let _img = UIImage(named: "foot_face_annex.png", in: self._bundle, compatibleWith: nil)
        let _btn = TGSUIModel.createBtn(rect: .zero,
                                        image: _img)
        
        _btn.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            self.clickBlock?(YLInputViewBtnState.annex)
        }.disposed(by: rx.disposeBag)
        
        return _btn
    }()
    
    /// 满意度评价
    fileprivate lazy var btnEvaluate:UIButton = {[unowned self] in
        let _img = UIImage(named: "foot_face_evaluate.png", in: self._bundle, compatibleWith: nil)
        let _btn = TGSUIModel.createBtn(rect: .zero,
                                        image: _img)
        
        _btn.rx.tap.subscribe {[weak self] (_:Event<Void>) in
            guard let self = self else { return }
            
            //发起
            VXIChatViewModel.sessionSatisfactionPushFor(isLoading: false) {[weak self] (_isOK:Bool, _msg:String) in
                guard let self = self else { return }
                if _isOK == false {
                    VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _msg)
                }
                else{
                    self.clickBlock?(YLInputViewBtnState.evaluate)
                }
            }
        }.disposed(by: rx.disposeBag)
        
        _btn.isHidden = true
        return _btn
    }()
    
}
