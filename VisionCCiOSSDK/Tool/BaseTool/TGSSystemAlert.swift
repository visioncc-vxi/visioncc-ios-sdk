//
//  TGSSystemAlert.swift
//  tgs-swift
//
//  Created by CQP-MacPro on 2020/11/13.
//

import UIKit

///显示系统弹框
class TGSSystemAlert: NSObject {
    
    /// 没有顶部大标题的系统弹框
    /// - Parameters:
    ///   - vc: 现实的控制器
    ///   - tipStr: 最上方的标题
    ///   - leftStr: 左侧文字
    ///   - leftColor: 左边文字颜色
    ///   - leftBlock: 左边点击事件
    ///   - rightStr: 右边文字
    ///   - rightColor: 右边文字颜色
    ///   - rightBlock: 右边点击事件
    static func showTipAlert(vc:UIViewController,
                             tipStr:String,
                             leftStr:String? = nil,
                             leftColor:UIColor? = nil,
                             leftBlock:(()->())? = nil,
                             rightStr:String? = nil,
                             rightColor:UIColor? = nil,
                             rightBlock:(()->())? = nil){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.alert)
        
        //修改title
        let alertTitle = NSMutableAttributedString(string: tipStr, attributes: [NSAttributedString.Key.foregroundColor :  TGSUIModel.createColorHexString("#424242") ,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        
        alert.setValue(alertTitle, forKey: "attributedTitle")
        
        /// 左边的按钮
        if leftStr != nil{
            let leftAction = UIAlertAction(title: leftStr, style: UIAlertAction.Style.default) { (_) in
                leftBlock?()
            }
            leftAction.setValue(leftColor, forKey: "titleTextColor")
            alert.addAction(leftAction)
        }
        
        /// 右边的按钮
        if rightStr != nil{
            let rightAction = UIAlertAction(title: rightStr, style: UIAlertAction.Style.default, handler: { (_) in
                rightBlock?()
            })
            rightAction.setValue(rightColor, forKey: "titleTextColor")
            alert.addAction(rightAction)
        }
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    
    /// 有顶部大标题的系统弹框
    /// - Parameters:
    ///   - vc: 显示的控制器
    ///   - titleStr: 顶部标题
    ///   - tipStr: 中间提示信息
    ///   - leftStr: 左边文字
    ///   - leftColor: 左边文字颜色
    ///   - leftBlock: 左边点击事件
    ///   - rightStr: 有汉文字
    ///   - rightColor: 右边文字颜色
    ///   - rightBlock: 右边点击事件
    static func showTipWithTitleAlert(vc:UIViewController,
                                      titleStr:String? = nil,
                                      tipStr:String,
                                      leftStr:String? = nil,
                                      leftColor:UIColor? = nil,
                                      leftBlock:(()->())? = nil,
                                      rightStr:String? = nil,
                                      rightColor:UIColor? = nil,
                                      rightBlock:(()->())? = nil){
        let alert = UIAlertController(title: titleStr, message: tipStr, preferredStyle: UIAlertController.Style.alert)
        
        /// 左边的按钮
        if leftStr != nil{
            let leftAction = UIAlertAction(title: leftStr, style: UIAlertAction.Style.default) { (_) in
                leftBlock?()
            }
            leftAction.setValue(leftColor, forKey: "titleTextColor")
            alert.addAction(leftAction)
        }
        
        if rightStr != nil{
            /// 右边的按钮
            let rightAction = UIAlertAction(title: rightStr, style: UIAlertAction.Style.default, handler: { (_) in
                rightBlock?()
            })
            rightAction.setValue(rightColor, forKey: "titleTextColor")
            alert.addAction(rightAction)
        }
        
        vc.present(alert, animated: true, completion: nil)
    }
}
