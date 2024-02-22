//
//  TGSVerBtn.swift
//  Tool
//
//  Created by CQP-MacPro on 2023/12/26.
//

import UIKit
///UIButton图片与文字多种布局
class TGSVerBtn: UIButton {
    
    enum RGButtonImagePosition {
        case top         //图片在上，文字在下，垂直居中对齐
        case bottom      //图片在下，文字在上，垂直居中对齐
        case left        //图片在左，文字在右，水平居中对齐
        case right       //图片在右，文字在左，水平居中对齐
    }
    
    func imagePosition(style: RGButtonImagePosition, spacing: CGFloat) {
        
        let imageWidth = self.imageView?.frame.size.width
        let imageHeight =  self.imageView?.frame.size.height
        var labelWidth: CGFloat! = 0.0
        var labelHeight: CGFloat! = 0.0
        
        labelWidth = self.titleLabel?.intrinsicContentSize.width
        labelHeight = self.titleLabel?.intrinsicContentSize.height
        
        var imageEdgeInsets =  UIEdgeInsets.zero
        var labelEdgeInsets = UIEdgeInsets.zero
        
        switch style {
        case .top:
            imageEdgeInsets = UIEdgeInsets(top: -labelHeight-spacing/2,left:0,bottom:0,right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets(top:0,left: -imageWidth!,bottom: -imageHeight!-spacing/2,right:0)
            break
            
        case .left:
            imageEdgeInsets = UIEdgeInsets(top:0,left: -spacing/2,bottom:0,right: spacing)
            labelEdgeInsets = UIEdgeInsets(top:0,left: spacing/2,bottom:0,right: -spacing/2)
            break
            
        case .bottom:
            imageEdgeInsets = UIEdgeInsets(top:0,left:0,bottom: -labelHeight!-spacing/2,right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets(top: -imageHeight!-spacing/2,left: -imageWidth!,bottom:0,right:0)
            break
            
        case .right:
            imageEdgeInsets = UIEdgeInsets(top:0,left: labelWidth+spacing/2,bottom:0,right: -labelWidth-spacing/2)
            labelEdgeInsets = UIEdgeInsets(top:0,left: -imageWidth!-spacing/2,bottom:0,right: imageWidth!+spacing/2)
            break
        }
        
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
    }
    
}

