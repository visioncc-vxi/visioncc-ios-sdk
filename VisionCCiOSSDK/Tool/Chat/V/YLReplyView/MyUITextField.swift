//
//  MyUITextField.swift
//  JunYiProject
//
//  Created by xiaogxjkz on 2021/9/17.
//

import Foundation
import UIKit

class MyUITextField : UITextField {
    
    
    /// leftView/文本与左边的间距设置
    /// - Parameter bounds: bounds description
    /// - Returns: description
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let iconRect:CGRect = super.leftViewRect(forBounds: bounds)
        return iconRect
    }
    
    /// rightView/文本与左边的间距设置
    /// - Parameter bounds: bounds description
    /// - Returns: description
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let iconRect:CGRect = super.rightViewRect(forBounds: bounds)
        return iconRect
    }
    
    
    /// leftView 与右边文本的间距设置
    /// - Parameter bounds: bounds description
    /// - Returns: description
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var left:CGFloat = self.leftView?.frame.size.width ?? 0
        var right:CGFloat = self.rightView?.frame.size.width ?? 0
        if #available(iOS 13.0, *) {
            if self.leftView?.frame.size.width != nil {
                left = 10 + self.leftView!.frame.size.width
            }
            
            if self.rightView?.frame.size.width != nil {
                right = 10 + self.rightView!.frame.size.width
            }
        }
        return bounds.inset(by: .init(top: 0, left: left, bottom: 0, right: right))
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        
        var left:CGFloat = 0
        if #available(iOS 13.0, *), rect.width > 0 {
            left = 10
        }
        
        return rect.inset(by: .init(top: 0, left: left, bottom: 0, right: 0))
    }
}
