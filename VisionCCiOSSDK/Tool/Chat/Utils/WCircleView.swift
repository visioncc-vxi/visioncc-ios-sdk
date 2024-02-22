//
//  WCircleView.swift
//  JunYiProject
//
//  Created by xiaogxjkz on 2022/4/1.
//

import UIKit
@_implementationOnly import VisionCCiOSSDKEngine

/// 圆环图标
class WCircleView: UIView {
    
    //MARK: - override
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("WCircleView 已销毁")
    }
    
    
    //MARK: - lazy property
    //[S] 显示信息
    /// 显示信息字体
    lazy var show_font:UIFont = UIFont.init(name: "HelveticaNeue", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
    
    /// 显示信息文本颜色
    lazy var show_text_color:UIColor = UIColor.init().colorFromHexInt(hex: 0x333333)
    
    /// 显示信息背景色
    lazy var show_background_color:UIColor = UIColor.init().colorFromHexInt(hex: 0xEDEEF6)
    //[E]
    
    //[S] 外环信息
    /// 外环半径
    lazy var out_circle_radius:CGFloat = 35
    
    /// 开口角度
    lazy var out_circle_start_angle:CGFloat = -0.55 * Double.pi
    
    /// 外环边框
    lazy var out_circle_border_width:CGFloat = 3
    
    /// 外环边框颜色
    lazy var out_circle_border_color:UIColor = UIColor.init().colorFromHexInt(hex: 0xEDEEF6)
    
    /// 外环高亮边框颜色
    lazy var out_high_light_border_color:UIColor = UIColor.init().colorFromHexInt(hex: 0x3FC40B)
    
    /// 外环与内部的边距
    lazy var out_circle_border_margin:CGFloat = 3
    //[E]
    
    
    //MARK: - lazy load
    /// 动画对象
    private lazy var animation:CABasicAnimation = {
        let _animation = CABasicAnimation.init(keyPath: "strokeEnd")
        _animation.duration = 1.5
        _animation.fromValue = 0.0
        _animation.toValue = 1.0
        _animation.repeatCount = 1
        
        return _animation
    }()
    
    /// 中间显示信息
    private lazy var labShowInfo:UILabel = {[unowned self] in
        let _v = 2 * (out_circle_radius - out_circle_border_width - out_circle_border_margin)
        let _lab = UILabel.init(frame: CGRect.init(origin: .zero,
                                                   size: CGSize.init(width: _v, height: _v)))
        
        _lab.textColor = self.show_text_color
        _lab.textAlignment = .center
        _lab.font = self.show_font
        
        _lab.backgroundColor = .clear
        _lab.adjustsFontSizeToFitWidth = true
        
        //圆角
        _lab.layer.cornerRadius = _v * 0.5
        _lab.layer.backgroundColor = self.show_background_color.cgColor
        
        return _lab
    }()
    
    /// 外环
    private lazy var outCircle:CAShapeLayer = {[unowned self] in
        let _layer = CAShapeLayer.init()
        
        let _v:CGFloat = 2 * out_circle_radius
        _layer.frame = .init(origin: .zero, size: CGSize.init(width: _v, height: _v))
        
        //样式
        _layer.lineCap = .round
        _layer.lineJoin = .round
        
        //设置中心
        let _rect:CGRect = _layer.bounds
        _layer.position = .init(x: _rect.origin.x + _rect.size.width * 0.5, y: _rect.origin.y + _rect.size.height * 0.5)
        
        //填充颜色(此处为透明填充)
        _layer.fillColor = UIColor.clear.cgColor
        
        //线条宽度
        _layer.lineWidth = out_circle_border_width
        
        //线条颜色
        _layer.strokeColor = out_circle_border_color.cgColor
        
        //创建贝塞尔曲线
        let _bezierPath = UIBezierPath.init(roundedRect: _layer.bounds, cornerRadius: out_circle_radius)
        _layer.path = _bezierPath.cgPath
        
        return _layer
    }()
    
    /// 高亮外环
    private lazy var outHighlightCircle:CAShapeLayer = {[unowned self] in
        let _layer = CAShapeLayer.init()
        
        let _v:CGFloat = 2 * out_circle_radius
        _layer.frame = .init(origin: .zero, size: CGSize.init(width: _v, height: _v))
        
        //样式
        _layer.lineCap = .round
        _layer.lineJoin = .round
        
        //设置中心
        let _rect:CGRect = _layer.bounds
        _layer.position = .init(x: _rect.origin.x + _rect.size.width * 0.5, y: _rect.origin.y + _rect.size.height * 0.5)
        
        //填充颜色
        _layer.fillColor = UIColor.clear.cgColor
        
        //线条宽度
        _layer.lineWidth = out_circle_border_width
        
        //线条颜色
        _layer.strokeColor = out_high_light_border_color.cgColor
        
        return _layer
    }()
}


//MARK: -
extension WCircleView {
    
    /// 开始绘制(动画版)
    /// - Parameters:
    ///   - _c: 当前值
    ///   - _t: 合计值
    ///   - _s: 显示信息
    func startAnimationDrawFor(Current _c:CGFloat,
                               andTotal _t:CGFloat,
                               andShowInfo _s:String,
                               withHighLightColor _hc:UIColor? = nil) {
        //[S] 中间显示信息
        let _v:CGFloat = 2 * (out_circle_radius - out_circle_border_width - out_circle_border_margin)
        
        if !self.subviews.contains(self.labShowInfo) {
            self.addSubview(self.labShowInfo)
            self.labShowInfo.snp.makeConstraints {[weak self] make in
                guard let self = self else { return }
                make.width.height.equalTo(_v)
                make.center.equalTo(self.snp.center)
            }
        }
        
        //赋值
        self.labShowInfo.text = _s
        //[E]
        
        //[S] 外圆环
        if self.layer.sublayers?.contains(self.outCircle) == false {
            self.outCircle.add(self.animation, forKey: "strokeEndAnimation")
            self.layer.addSublayer(self.outCircle)
        }
        //[E]
        
        //[S] 高亮外环
        if _hc != nil {
            self.outHighlightCircle.strokeColor = _hc!.cgColor
        }
        
        if self.layer.sublayers?.contains(self.outHighlightCircle) == false {
            self.outHighlightCircle.add(self.animation, forKey: "strokeEndAnimation")
            self.layer.addSublayer(self.outHighlightCircle)
        }
        
        //创建贝塞尔曲线
        let _bezierPath = UIBezierPath.init(arcCenter: .init(x: out_circle_radius, y: out_circle_radius),
                                            radius: out_circle_radius,
                                            startAngle: out_circle_start_angle,
                                            endAngle: self.getEndRangFor(Value: _c, andTo: _t),
                                            clockwise: true)
        
        self.outHighlightCircle.path = _bezierPath.cgPath
        //[E]
    }
    
    /// 获取闭口角度
    /// - Parameters:
    ///   - _v: 当前值
    ///   - _t: 统计值
    private func getEndRangFor(Value _v:CGFloat,
                               andTo _t:CGFloat) -> CGFloat {
        if _v == _t {
            return Double.pi - out_circle_start_angle
        }
        else{
            return _v * (Double.pi * 2 / _t) + out_circle_start_angle
        }
    }
}
