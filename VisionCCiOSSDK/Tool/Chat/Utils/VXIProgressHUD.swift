//
//  VXIProgressHUD.swift
//  Tool
//
//  Created by CQP-MacPro on 2023/12/25.
//

import UIKit
@_implementationOnly import VisionCCiOSSDKEngine

/**
 *  设定HUD样式的类
 */
class VXIProgressHUD: NSObject {
    /// tost框类型
    enum VXIHUDToastType {
        /// 普通样式(显示loading)
        case defaultToastType
        /// 普通提示类型
        case tipToastType
        /// 失败提示类型
        case faildToastType
        /// 成功提示类型
        case successToastType
    }
}

// MARK: - public API
extension VXIProgressHUD {
    
    static func showToastHUD(type: VXIHUDToastType , 
                             showText: String? ,
                             delayDismiss: Double? = nil ,
                             showView: UIView? = VXIUIConfig.shareInstance.keyWindow() ,
                             textFont: UIFont = UIFont.systemFont(ofSize: 16)) {
        SVProgressHUD.setFont(textFont) // 设置字体大小
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark) // 设置样式
        SVProgressHUD.setContainerView(showView) // 设置父试图View
        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: -20)) // 设置为正中心
        SVProgressHUD.setDefaultMaskType(.clear) // 设置透明遮照，不允许交互
        switch type {
        case .defaultToastType:
            if let text = showText , text.isEmpty == false {
                SVProgressHUD.show(withStatus: text)
            }else {
                SVProgressHUD.show()
            }
        case .faildToastType:
            SVProgressHUD.showError(withStatus: showText)
        case .tipToastType:
            SVProgressHUD.showInfo(withStatus: showText)
        case .successToastType:
            SVProgressHUD.showSuccess(withStatus: showText)
        }
        if let delay = delayDismiss {
            SVProgressHUD.dismiss(withDelay: delay)
            SVProgressHUD.setContainerView(nil)
        }
    }
}

// MARK: - View常用 API
extension UIView {
    
    /// 数据请求加载
    /// - Parameter info: 提示信息
    func showHud(at info: String? = "请稍后") {
        self.hiddenHud()
        VXIProgressHUD.showToastHUD(type: VXIProgressHUD.VXIHUDToastType.defaultToastType, showText: info, showView: self)
    }
    
    /// 隐藏Hud
    func hiddenHud() {
        SVProgressHUD.setContainerView(nil)
        SVProgressHUD.dismiss()
    }
    
    /// 请求成功
    func showSuccessInfo(at info: String? , dissmissTime: Double = 1.5) {
        VXIProgressHUD.showToastHUD(type: VXIProgressHUD.VXIHUDToastType.successToastType, showText: info , delayDismiss: dissmissTime , showView: self)
    }
    
    /// 错误信息提示
    func showErrInfo(at info: String?) {
        VXIProgressHUD.showToastHUD(type: VXIProgressHUD.VXIHUDToastType.tipToastType, showText: info, delayDismiss: 1.5 ,showView: self)
    }
    
    /// 显示百分比
    func showProgress(process: Float , text: String? = nil) {
        SVProgressHUD.showProgress(process, status: text)
    }
}
