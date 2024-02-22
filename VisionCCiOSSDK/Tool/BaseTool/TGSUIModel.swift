//
//  TGSUIModel.swift
//  tgs-Swift
//
//  Created by CQP-MacPro on 2020/9/22.
//  Copyright © 2020 CQP-MacPro. All rights reserved.
//

import Foundation
import UIKit
import Photos
import RxSwift
import LocalAuthentication
@_implementationOnly import VisionCCiOSSDKEngine

/**
 * 快速创建基本控件
 */
class TGSUIModel: NSObject {
    
    //MARK: 快速创建Lab,默认只支持layout，默认显示一行，默认自动撑满
    /// 快速创建Lab,默认只支持layout，默认显示一行，默认自动撑满
    /// - Parameters:
    ///   - text: 显示的内容
    ///   - font: 文字大小
    ///   - textColor: 文字的颜色
    ///   - textAlignment: 文字对齐方式,默认居左
    static func creatLabe(text: String?  = nil,
                          font: UIFont = UIFont.systemFont(ofSize: 14),
                          textColor: UIColor = createColorHexString("#424242"),
                          textAlignment: NSTextAlignment = .left) -> UILabel {
        let lab = UILabel()
        lab.translatesAutoresizingMaskIntoConstraints = false
        lab.text = text
        lab.sizeToFit()
        lab.textAlignment = textAlignment
        lab.font = font
        lab.textColor = textColor
        return lab
    }
    
    /**
     * 创建Lable
     * @retuen VisionCCiOSSDKEngine.YYLabel
     */
    static func createLable(rect:CGRect,
                            text:String? = nil,
                            textColor:UIColor? = nil,
                            font:UIFont? = nil,
                            backgroundColor:UIColor = UIColor.clear,
                            andTextAlign align:NSTextAlignment = .left,
                            andisdisplaysAsync _isdisplaysAsync:Bool = true,
                            andLineBreakMode _lbm:NSLineBreakMode? = nil) -> VisionCCiOSSDKEngine.YYLabel {
        let labTemp:VisionCCiOSSDKEngine.YYLabel = VisionCCiOSSDKEngine.YYLabel.init(frame: rect)
        if _lbm != nil {
            labTemp.lineBreakMode = _lbm!
        }
        labTemp.isOpaque = false
        labTemp.isUserInteractionEnabled = false
        
        //异步显示
        labTemp.displaysAsynchronously = _isdisplaysAsync
        
        labTemp.backgroundColor = backgroundColor
        labTemp.textAlignment = align
        
        if text != nil {
            labTemp.text = text!
        }
        
        if font != nil {
            labTemp.font = font!
        }
        
        if textColor != nil {
            labTemp.textColor = textColor!
        }
        
        return labTemp
    }
    
    
    //MARK: 创建按钮(文本),默认只支持layout
    /// 创建按钮(文本),默认只支持layout
    ///
    /// - Parameters:
    ///   - font: 文本大小
    ///   - textColor: 文本颜色
    ///   - titleStr: 文本
    ///   - backgroundColor: 背景色
    /// - Returns: TGSBaseButton
    static func createBtn(font: UIFont = UIFont.systemFont(ofSize: 14),
                          textColor: UIColor = UIColor.white,
                          titleStr: String? = nil ,
                          backgroundColor: UIColor = UIColor.clear) -> UIButton{
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle(titleStr, for: .normal)
        btn.titleLabel?.font = font
        btn.setTitleColor(textColor, for: .normal)
        btn.backgroundColor = backgroundColor
        return btn
    }
    
    //MARK: 创建背景渐变色button（通用于View or Controller底部按钮），bounds计算后传入
    // 创建背景渐变色button（通用于View or Controller底部按钮），bounds计算后传入
    static func createGradientButton(font: UIFont = UIFont.systemFont(ofSize: 14),
                                     textColor: UIColor = UIColor.white,
                                     titleStr: String? = nil,
                                     bounds:CGRect,
                                     colors:[CGColor] = [createColorHexString("#262626").cgColor,
                                                         createColorHexString("#3C3C3C").cgColor]) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle(titleStr, for: .normal)
        btn.titleLabel?.font = font
        btn.setTitleColor(textColor, for: .normal)
        btn.backgroundColor = UIColor.clear
        let caGradientLayer:CAGradientLayer = CAGradientLayer()
        caGradientLayer.colors = colors
        caGradientLayer.locations = [0, 1]
        caGradientLayer.startPoint = CGPoint(x: 0, y: 1)
        caGradientLayer.endPoint = CGPoint(x: 0.8, y: 1)
        caGradientLayer.frame = bounds
        btn.layer.insertSublayer(caGradientLayer, at: 0)
        return btn
    }
    
    /**
     * 创建按钮
     * @return UIButton
     */
    static func createBtn(rect:CGRect,
                          strTitle:String? = nil,
                          titleColor:UIColor? = nil,
                          txtFont:UIFont? = nil,
                          image:UIImage?,
                          backgroundColor:UIColor? = UIColor.clear,
                          borderColor:UIColor? = nil,
                          cornerRadius:CGFloat? = CGFloat.init(5),
                          isRadius:Bool = false,
                          backgroundImage:UIImage? = nil,
                          borderWidth:CGFloat? = nil)->UIButton{
        let btnTemp = UIButton.init(type: .custom)
        btnTemp.showsTouchWhenHighlighted = true
        btnTemp.isOpaque = false
        
        btnTemp.frame = rect
        btnTemp.titleLabel?.font = txtFont
        
        if backgroundColor != nil {
            btnTemp.backgroundColor = backgroundColor
        }
        
        if strTitle != nil {
            btnTemp.setTitle(strTitle, for: .normal)
        }
        
        if titleColor != nil {
            btnTemp.setTitleColor(titleColor, for: .normal)
        }
        
        if txtFont != nil {
            btnTemp.titleLabel?.font = txtFont
        }
        
        if image != nil {
            btnTemp.setImage(image, for: .normal)
        }
        
        if backgroundImage != nil {
            btnTemp.setBackgroundImage(backgroundImage, for: .normal)
        }
        
        //圆角
        if isRadius {
            btnTemp.layer.borderColor = UIColor.clear.cgColor
            if borderColor != nil {
                btnTemp.layer.borderColor = borderColor!.cgColor
            }
            
            //masksToBounds 会造成离屏渲染
            if cornerRadius != nil {
                btnTemp.layer.cornerRadius = cornerRadius!
            }
        }
        
        if borderWidth != nil {
            btnTemp.layer.borderWidth = borderWidth!
        }
        
        return btnTemp
    }
    
    
    //MARK: 快速创建 图片UIImageView
    /// 快速创建 图片UIImageView
    ///
    /// - Parameter name: 图像名称字符串
    /// - Returns: TGSBaseImageView
    static func createImageView(name: String? = nil) -> UIImageView {
        let imgView = UIImageView()
        if let nameStr = name{
            let image = UIImage(named: nameStr, in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
            imgView.image = image
        }
        imgView.contentMode = VXIUIConfig.shareInstance.cellImageContentMode()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }
    
    
    /// 访问Bundle资源包中的图片
    /// - Parameters:
    ///   - bclass: Bundle的class([self class]?可选)
    ///   - bName: Bundle的名称
    ///   - imgName: 带后缀的图片名 "xx.png"
    ///   - _imgFileName: 图片资源所在文件夹名称，可选
    static func imageForBuncle(Class _bclass:AnyClass?,
                               andBundleName _bName:String,
                               withImageName _imgName:String,
                               andImagesFileName _imgFileName:String?) -> UIImage?  {
        
        var _img:UIImage?
        var _class:AnyClass? = _bclass
        if _bclass == nil {
            _class = NSClassFromString(_bName)
        }
        
        let _bundle:Bundle = _class == nil ? Bundle.main : Bundle.init(for: _class!)
        let _url:URL? = _bundle.url(forResource: _bName, withExtension: "bundle")
        
        var _imgFN:String = _imgName
        if _imgFileName != nil && _imgFileName?.isEmpty == false {
            _imgFN = String.init(format:"%@/%@",_imgFileName!,_imgName)
        }
        
        if #available(iOS 13.0, *) {
            if _url != nil,let _imageBundle:Bundle = Bundle.init(url: _url!) {
                _img = UIImage.init(named: _imgFN, in: _imageBundle, with: .none)
            }
            else if _imgFN.isEmpty == false {
                _img = UIImage(named: _imgFN, in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
            }
        } else {
            // Fallback on earlier versions
            if _url != nil {
                let _path:String = String.init(format:"%@/%@",_url!.pathExtension,_imgFN)
                _img = UIImage.init(contentsOfFile: _path)
            }
            else if _imgFN.isEmpty == false {
                _img = UIImage(named: _imgFN, in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)
            }
        }
        
        return _img
    }
    
    
    /**
     * 创建图片
     * @return UIImageView
     */
    static func createImage(rect:CGRect,
                            image:UIImage?,
                            backgroundColor:UIColor?,
                            isRadius:Bool = false) -> UIImageView {
        
        let imageView = UIImageView.init(frame: rect)
        imageView.isOpaque = false
        
        if backgroundColor != nil {
            imageView.backgroundColor = backgroundColor
        }
        
        if image != nil {
            imageView.image = image
        }
        
        if isRadius == true {
            //masksToBounds会造成离屏渲染
            imageView.layer.cornerRadius = rect.size.height / 2
        }
        
        return imageView
    }
    
    
    /// 根据颜色创建图片
    /// - Parameters:
    ///   - _c: <#_c description#>
    ///   - _s: <#_s description#>
    /// - Returns: <#description#>
    static func createImageFor(Color _c:UIColor,andSize _s:CGSize) -> UIImage? {
        if _s.width <= 0 || _s.height <= 0 { return nil}
        if #available(iOS 17.0, *) {
            let format:UIGraphicsImageRendererFormat = UIGraphicsImageRendererFormat.init()
            format.opaque = false
            format.scale = 0.0
            
            let render:UIGraphicsImageRenderer = UIGraphicsImageRenderer.init(size: _s, format: format)
            let image = render.image { rendererContext in
                let rect:CGRect = .init(origin: .zero, size: _s)
                _c.setFill()
                UIRectFill(rect)
            }
            
            return image
        }
        else{
            let rect:CGRect = .init(origin: .zero, size: _s)
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
            let context:CGContext? = UIGraphicsGetCurrentContext()
            
            context?.setFillColor(_c.cgColor)
            context?.fillEllipse(in: rect)
            let image:UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image
        }
    }
    
    
    /// 自定义导航栏
    /// - Parameter titleStr: 标题
    /// - Returns: UIView
    static func createDiyNavgationalViewFor(TitleStr _t: String,
                                            andDisposeBag _dispos:DisposeBag,
                                            andBackblock _bb:(()->Void)?,
                                            withOtherblock _ob:((_ _bgView:UIView,_ _titleLabel:VisionCCiOSSDKEngine.YYLabel)->Void)? = nil,
                                            andBackgroundColoe _bgc:UIColor = TGSUIModel.createColorHexString(TGSUIModel.getThemColorsConfig()?.cckf_online_base_header_bg_color ?? "#FFFFFF"),
                                            andBackImage _bi:UIImage? = UIImage(named: "login_back", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil)) -> UIView {
        let bgView = UIView()
        bgView.backgroundColor = _bgc
        
        //底部视图
        let _vbottom:VisionCCiOSSDKEngine.YYLabel = {
            let _c:String = TGSUIModel.getThemColorsConfig()?.cckf_online_base_header_bg_color ?? "#FFFFFF"
            return TGSUIModel.createLable(rect: .zero,
                                          backgroundColor: UIColor.init().colorFromHexString(hex: _c))
        }()
        bgView.addSubview(_vbottom)
        _vbottom.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(44)
        }
        
        ///返回按钮
        let backBtn = UIButton(type: UIButton.ButtonType.custom)
        backBtn.setImage(_bi, for: .normal)
        backBtn.rx.tap.subscribe {event in
            _bb?()
        }.disposed(by: _dispos)
        backBtn.adjustsImageWhenHighlighted = false
        backBtn.layer.removeAllAnimations()
        bgView.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(VXIUIConfig.shareInstance.xp_statusBarHeight())
            make.width.equalTo(50)
            make.height.equalTo(44)
        }
        
        let _f:CGFloat = TGSUIModel.getThemFontsConfig()?.cckf_title_top_text_size ?? 17
        let _c:String = TGSUIModel.getThemColorsConfig()?.cckf_chat_title_text_color ?? "#424242"
        let titleLabel = TGSUIModel.createLable(rect: .zero,
                                                text: _t,
                                                textColor: .init().colorFromHexString(hex: _c),
                                                font: UIFont.boldSystemFont(ofSize: _f),
                                                andTextAlign: .center)
        bgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backBtn)
            make.centerX.equalToSuperview()
        }
        
        _ob?(bgView,titleLabel)
        
        return bgView
    }
    
    /// 获取文件真实地址
    /// - Parameters:
    ///   - _p: 服务端返回的地址(前面需要拼接host)
    ///   - _thumbnail: Bool true 缩略图，false 原图
    /// - Returns: String
    static func getFileRealUrlFor(Path _p:String,
                                  andisThumbnail _thumbnail:Bool) -> String {
        if _p.hasPrefix("http") == false {
            let _file_host = VXIUrlSetting.shareInstance.fileHost
            let _url = String.init(format:"%@%@%@",_file_host,_p,_thumbnail ? "?view=h5":"")
            debugPrint("getFileRealUrlFor:\(_url)")
            
            //地址中带中文或中文符号的需要编码，在否则低系统转URL 为nil,有崩溃风险
            if _url.yl_isChinese() {//防止重复编码
                return _url.yl_urlEncoded()
            }
            return _url
        }
        debugPrint("getFileRealUrlFor:\(_p)")
        if _p.yl_isChinese() {
            return _p.yl_urlEncoded()
        }
        return _p
    }
    
    
    /// 图片尺寸处理
    /// - Parameters:
    ///   - _image: UIImage?
    ///   - _os: CGSize?
    /// - Returns: <#description#>
    static func pictureResetSizeFor(Image _image:UIImage?,
                                    orOriginalSize _os:CGSize?) -> CGSize {
        let _scale:CGFloat = max(UIScreen.main.scale,1)
        var imageWidth: CGFloat =  0
        var imageHeight: CGFloat = 0
        let maxWidth: CGFloat = VXIUIConfig.shareInstance.cellMaxWidth()
        
        if let image = _image {
            imageWidth = image.size.width / _scale
            imageHeight = image.size.height / _scale
            
            if imageWidth > maxWidth {
                imageWidth = maxWidth / 1.297
                imageHeight = (imageHeight / 1.297 * imageWidth) / (image.size.width / _scale)
            }
            
            if imageHeight < 80 {
                imageWidth = maxWidth * 0.6
                imageHeight = (imageHeight * imageWidth) / (image.size.width / _scale)
            }
        }
        else if let _size = _os {
            imageWidth = _size.width / _scale
            imageHeight = _size.height / _scale
            
            if imageWidth > maxWidth {
                imageWidth = maxWidth
                imageHeight = (imageHeight * imageWidth) / (_size.width / _scale)
            }
            
            if imageHeight < 80 {
                imageWidth = maxWidth * 0.5
                imageHeight = (imageHeight * imageWidth) / (_size.width / _scale)
            }
            else if imageHeight > VXIUIConfig.shareInstance.YLScreenHeight {
                imageWidth = imageWidth * (imageHeight * 0.2) / imageHeight
                imageHeight = imageHeight * 0.2
            }
        }
        
        debugPrint("imageWidth:\(imageWidth),imageHeight:\(imageHeight)")
        return .init(width: imageWidth, height: imageHeight)
    }
    
    /// 识别图中二维码
    /// - Parameter img: UIImage
    /// - Returns: String 识别结果
    static func discernQRCodeFor(Image img:UIImage) -> String? {
        var _data:Data? = img.pngData()
        if _data == nil {
            _data = img.jpegData(compressionQuality: 0.75)
        }
        
        if _data == nil { return nil }
        let ciImg:CIImage = CIImage.init(data: _data!)!
        
        //创建探测器
        let detector:CIDetector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [
            CIDetectorAccuracy:CIDetectorAccuracyLow
        ])!
        
        //结果处理
        let arrResult:[CIFeature] = detector.features(in: ciImg)
        if arrResult.count <= 0 { return nil}
        
        //系统处于铃声模式下扫描到结果会调用"卡擦"声音;
        AudioServicesPlaySystemSound(1305)
        
        //系统处于震动模式扫描到结果会震动一下;
        let _playSound = PlaySound.init()
        _playSound.systemVibration()
        
        //遍历数组可以获取多个扫码结果(如果有多个)
        if let result = arrResult.first as? CIQRCodeFeature {
            if let content:String = result.messageString {
                var strResult = content.trimmingCharacters(in: .whitespacesAndNewlines)
                strResult = strResult.replacingOccurrences(of: "*", with: "")
                
                debugPrint("二维码：\(strResult)")
                return strResult
            }
        }
        
        return nil
    }
    
    
    /// 保存图片到相册
    /// - Parameter img: img description
    static func saveLocalhostFor(Image _image:UIImage) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum){
            //相册权限检测
            PHPhotoLibrary.requestAuthorization({ (status:PHAuthorizationStatus) in
                if status != .authorized {
                    DispatchQueue.main.async {
                        VXIUIConfig.shareInstance.keyWindow().showErrInfo(at:"请先开启相册访问权限")
                    }
                }
                else {
                    DispatchQueue.main.async {
                        PHPhotoLibrary.shared().performChanges {
                            PHAssetChangeRequest.creationRequestForAsset(from: _image)
                        } completionHandler: { (_isOK:Bool, _error:Error?) in
                            if _isOK {
                                VXIUIConfig.shareInstance.keyWindow().showSuccessInfo(at: "保存成功")
                            }
                            else{
                                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: _error?.localizedDescription)
                            }
                        }
                        
                    }
                }
            })
        }
    }
    
    
    /// 创建动图对象
    /// - Parameters:
    ///   - _rect: CGRect
    ///   - _image: VisionCCiOSSDKEngine.YYImage?
    ///   - _loop: Bool true 循环播放
    ///   - _bgColor: UIColor
    /// - Returns: YYAnimatedImageView
    static func createAnimationImageFor(Rect _rect:CGRect,
                                        andImage _image:VisionCCiOSSDKEngine.YYImage?,
                                        andisLoopPlayback _loop:Bool = true,
                                        andBackgroundColor _bgColor:UIColor = .clear) -> YYAnimatedImageView {
        let _view = YYAnimatedImageView.init(frame: _rect)
        _view.backgroundColor = _bgColor
        _view.image = _image
        if _loop {
            _view.setValue(0, forKey: "_totalLoop")
        }
        
        return _view
    }
    
    /// 跳转浏览器打开
    static func gotoWebViewFor(Path _p:String?) {
        if _p == nil || _p?.isEmpty == true {
            return
        }
        
        let _np:String = _p!.yl_isChinese() ? _p!.yl_urlEncoded() : _p!
        let _url:URL? = URL(string: _np)
        if _url != nil {
            if UIApplication.shared.canOpenURL(_url!) {
                debugPrint(_url!)
                UIApplication.shared.open(_url!, options: [:], completionHandler: nil)
            }
            else{
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "地址无法打开")
            }
        }
        else{
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "地址转URL失败")
        }
    }
    
    //MARK: 快速创建 UIView
    /// 快速创建 View
    /// - Parameter bgColor: 背景色
    static func createView(bgColor: UIColor? = .white) -> UIView {
        let view = UIView()
        view.backgroundColor = bgColor
        return view
    }
    
    /// 设置圆角
    /// - Parameters:
    ///   - corners: corners description
    ///   - widthRadius: widthRadius description
    ///   - heightRadius: heightRadius description
    static func addCornerFor(View _v:UIView,
                             andCorners corners: UIRectCorner,
                             widthRadius: CGFloat,
                             heightRadius: CGFloat,
                             withBorderWidth _bw:CGFloat = 0,
                             andBorderColor _bc:UIColor = .clear) {
        
        if _v.layer.sublayers != nil {
            for layer in _v.layer.sublayers! {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        if corners.contains(.topLeft) && corners.contains(.topRight)
            && corners.contains(.bottomLeft) && corners.contains(.bottomRight) {
            _v.layer.cornerRadius = widthRadius
            _v.layer.borderWidth = _bw
            _v.layer.borderColor = _bc.cgColor
        }
        else{
            let maskPath = UIBezierPath.init(roundedRect: _v.bounds,
                                             byRoundingCorners: corners,
                                             cornerRadii: CGSize(width: widthRadius, height: heightRadius))
            
            //新建一个图层
            let layer:CAShapeLayer = CAShapeLayer.init()
            layer.borderWidth = _bw
            layer.borderColor = _bc.cgColor
            
            //图层边框路径
            layer.path = maskPath.cgPath
            
            //图层填充色,也就是cell的底色
            if _bw > 0 {
                layer.strokeColor = _bc.cgColor
                layer.lineWidth = _bw
            }
            layer.fillColor = _v.backgroundColor?.cgColor ?? UIColor.clear.cgColor
            _v.backgroundColor = .clear
            
            //将图层添加到cell的图层中,并插到最底层
            _v.layer.insertSublayer(layer, at: 0)
        }
    }
    
    //MARK: 快速创建 列表
    /// 快速创建UITableView
    /// - Parameters:
    ///   - style: 类型 UITableView.Style = .plain
    ///   - separatorStyle: 分割线类型 UITableViewCell.SeparatorStyle = .none
    static func createTableView(style: UITableView.Style = .plain,
                                separatorStyle: UITableViewCell.SeparatorStyle = .none) -> UITableView{
        let _tb = UITableView.init(frame: CGRect.zero,
                                   style: style)
        _tb.backgroundColor = UIColor.clear
        _tb.isScrollEnabled = true
        
        _tb.showsVerticalScrollIndicator = false
        _tb.showsHorizontalScrollIndicator = false
        
        //适配平板
        _tb.cellLayoutMarginsFollowReadableWidth = false
        
        //分割线
        _tb.separatorStyle = separatorStyle
        _tb.separatorColor = .clear
        _tb.separatorInset = .zero
        
        //行选中
        _tb.allowsSelection = true
        _tb.allowsMultipleSelection = false
        
        //表头、表尾
        _tb.tableHeaderView = UIView.init(frame: .zero)
        _tb.tableFooterView = UIView.init(frame: .zero)
        
        //防止顶部空白
        if #available(iOS 11.0, *) {
            _tb.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        }
        
        if #available(iOS 15.0, *) {
            _tb.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        return _tb
    }
    
    
    /// 创建UICollection
    /// - Parameters:
    ///   - _sd: <#_sd description#>
    ///   - _bgc: <#_bgc description#>
    /// - Returns: <#description#>
    static func createCollectionViewFor(ScrollDirection _sd:UICollectionView.ScrollDirection = .vertical,
                                        andBackgroundColor _bgc:UIColor? = nil,
                                        withLayout _layout:UICollectionViewFlowLayout? = nil) -> UICollectionView {
        var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = _sd
        if _layout != nil {
            layout = _layout!
        }
        
        let contain: UICollectionView = UICollectionView.init(frame: .zero,collectionViewLayout: layout)
        
        if #available(iOS 13.0, *) {
            contain.automaticallyAdjustsScrollIndicatorInsets = false
        }
        
        if #available(iOS 11.0, *) {
            contain.contentInsetAdjustmentBehavior = .never
        }
        
        contain.backgroundColor = _bgc ?? .clear
        
        return contain
    }
    
    
    //MARK: 快速创建 UIScrollView
    /// 创建ScrollView
    ///
    /// - Parameters:
    ///   - showVScrollIndicator: 是否显示竖直方向滚动条
    ///   - showHScrollIndicator: 是否显示水平方向滚动条
    ///   - bounces: bounces past edge of content and back again
    /// - Returns: TGSBaseScrollView
    static func createScrollView(showVScrollIndicator: Bool = false,
                                 showHScrollIndicator: Bool = false,
                                 bounces: Bool = true) -> UIScrollView{
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.showsVerticalScrollIndicator = showVScrollIndicator
        s.showsHorizontalScrollIndicator = showHScrollIndicator
        s.bounces = bounces
        if #available(iOS 11.0, *) {
            s.contentInsetAdjustmentBehavior = .never
        }
        return s
    }
    
    //MARK: 快速创建 调用系统键盘的UITextField
    /// 快速创建 调用系统键盘的UITextField
    /// - Parameters:
    ///   - font: 字号
    ///   - textColor: 字体颜色
    ///   - textAlignment: 对齐方式
    static func createTextField(font: UIFont , textColor: UIColor , textAlignment: NSTextAlignment = .left) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = font
        textField.textColor = textColor
        textField.textAlignment = textAlignment
        return textField
    }
    
    //MARK: 快速创建 富文本 NSMutableAttributedString 高亮字体颜色和大小
    /// 快速创建 富文本NSMutableAttributedString 高亮字体颜色和大小
    /// - Parameters:
    ///   - textString: 所有文字
    ///   - highLightString: 所有文字中需要显示的高亮文字
    ///   - normalFont: 常规文字字体
    ///   - highLightFont: 高亮文字字体
    ///   - normalColor: 常规文字颜色
    ///   - highLightColor: 高亮颜色
    static func createAttributed(textString: String,
                                 normalFont: UIFont? = nil,
                                 normalColor: UIColor? = nil,
                                 highLightString: String = "",
                                 highLightFont:UIFont? = nil,
                                 highLightColor: UIColor? = nil) -> NSMutableAttributedString {
        //定义富文本即有格式的字符串
        let attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
        let strings = textString.components(separatedBy: highLightString)
        for i in 0..<strings.count {
            // 设置常规字体及颜色
            let item = strings[i]
            var dict:[NSAttributedString.Key:Any] = [:]
            if let normalF = normalFont {
                dict[NSAttributedString.Key.font] = normalF
            }
            if let normalC = normalColor {
                dict[NSAttributedString.Key.foregroundColor] = normalC
            }
            let content = NSAttributedString(string: item, attributes: dict)
            attributedStrM.append(content)
            // 设置高亮字体及颜色
            if i != strings.count - 1 {
                var dict1:[NSAttributedString.Key:Any] = [:]
                if let heightF = highLightFont {
                    dict1[NSAttributedString.Key.font] = heightF
                }
                if let heightC = highLightColor {
                    dict1[NSAttributedString.Key.foregroundColor] = heightC
                }
                let content2 = NSAttributedString(string: highLightString,attributes: dict1)
                attributedStrM.append(content2)
            }
        }
        return attributedStrM
    }
    
    
    /// 批量设置富文本
    /// - Parameters:
    ///   - strFullText: <#strFullText description#>
    ///   - textFont: <#textFont description#>
    ///   - textColor: <#textColor description#>
    ///   - changeTexts: <#changeTexts description#>
    ///   - changFont: <#changFont description#>
    ///   - changeColor: <#changeColor description#>
    ///   - isLineThrough: <#isLineThrough description#>
    /// - Returns: NSAttributedString
    static func setAttributeStringTexts(strFullText:String,
                                        andFullTextFont textFont:UIFont,
                                        andFullTextColor textColor:UIColor,
                                        withChangeText changeTexts:[String],
                                        withChangeFont changFont:UIFont,
                                        withChangeColor changeColor:UIColor,
                                        andLineSpacing spacing:CGFloat = 6,
                                        andAlign _align:NSTextAlignment = .left,
                                        isLineThrough:Bool = false) -> NSAttributedString {
        
        //字间距
        let paraStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        paraStyle.lineBreakMode = .byWordWrapping
        paraStyle.lineSpacing = spacing //设置行间距
        paraStyle.hyphenationFactor = 1.0
        paraStyle.firstLineHeadIndent = 0.0
        paraStyle.paragraphSpacingBefore = 0.0
        paraStyle.alignment = _align
        
        paraStyle.headIndent = 0
        paraStyle.tailIndent = 0
        
        var range:NSRange?
        var dicAttr:[NSAttributedString.Key:Any]?
        let attributeString = NSMutableAttributedString.init(string: strFullText)
        
        //不需要改变的文本
        range = NSString.init(string: strFullText).range(of: String.init(strFullText))
        
        dicAttr = [
            NSAttributedString.Key.paragraphStyle:paraStyle,
            NSAttributedString.Key.font:textFont,
            NSAttributedString.Key.foregroundColor:textColor,
        ]
        
        if #available(iOS 14.0, *) {
            dicAttr?[.tracking] = 1.0
        }
        
        attributeString.addAttributes(dicAttr!, range: range!)
        
        //需要改变的文本
        for i in 0..<changeTexts.count {
            let item = changeTexts[i]
            range = NSString.init(string: strFullText).range(of: item)
            
            dicAttr = [
                NSAttributedString.Key.font:changFont,
                NSAttributedString.Key.foregroundColor:changeColor,
            ]
            
            if isLineThrough {
                dicAttr?[NSAttributedString.Key.strikethroughStyle] = NSNumber.init(value: 1)
            }
            attributeString.addAttributes(dicAttr!, range: range!)
        }
        
        return attributeString
    }
    
    //MARK: 快速创建 一张指定颜色的图片
    /// 创建一张指定颜色的图片
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 尺寸
    static func createColorImage(color: UIColor , size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: rect)
        context.clip()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    //MARK: 创建UITextField
    /**
     * 创建UITextField
     * @retuen UITextField
     */
    static func createTextFiled(rect:CGRect,
                                textFont:UIFont = UIFont.systemFont(ofSize: 14),
                                textColor:UIColor = UIColor.black,
                                placeHoled:String,
                                borderColor:CGColor? = nil,
                                bottomBoder:UIColor? = nil,
                                placeHoledColor:UIColor = UIColor.gray,
                                placeHoledFont:UIFont = UIFont.systemFont(ofSize: 11),
                                textMarginLeft:CGFloat = CGFloat.init(5),
                                isRadius:Bool = false,
                                placeHoledAlignCenter ac:Bool = false,
                                andLeftView lv:UIView? = nil) -> MyUITextField {
        
        let txtField = MyUITextField.init(frame: rect)
        txtField.font = textFont
        txtField.isOpaque = false
        
        let str = NSAttributedString(string: placeHoled,
                                     attributes: [
                                        NSAttributedString.Key.foregroundColor:placeHoledColor,
                                        NSAttributedString.Key.font:placeHoledFont,
                                     ])
        txtField.attributedPlaceholder = str
        
        if ac == true {
            let _w = placeHoled.yl_getWidthFor(Font: placeHoledFont)
            txtField.placeholderRect(forBounds: CGRect.init(x: (rect.width - _w) * 0.5, y: 0,
                                                            width: _w, height: 21))
        }
        
        if borderColor != nil {
            txtField.layer.borderColor = borderColor!
            txtField.layer.borderWidth = 1
        }
        
        if borderColor == nil && bottomBoder != nil {
            let tempRect = CGRect.init(x: 0, y: rect.size.height - 0.5, width: rect.size.width, height: 0.5)
            let labLine = TGSUIModel.createLable(rect: tempRect,backgroundColor: bottomBoder!)
            
            txtField.addSubview(labLine)
        }
        
        if isRadius == true {
            //masksToBounds会造成离屏渲染
            txtField.layer.cornerRadius = 5
        }
        
        if lv != nil {
            txtField.leftView = lv!
        }
        else{
            txtField.leftView = UIView.init(frame: .init(x: 0, y: 0, width: textMarginLeft, height: rect.size.height))
        }
        
        txtField.leftViewMode = .always
        txtField.textColor = textColor
        
        //清除按钮
        txtField.clearButtonMode = .whileEditing
        
        return txtField
    }
    
    //MARK: - 生成随机数
    /**! 生成指定范围内的帧数随机数  */
    static func randomIn(min: Int, max: Int) -> UInt {
        return UInt(arc4random()) % UInt(max - min + 1) + UInt(min)
    }
    
    /**! 生成指定长度的字符串随机数 */
    static func randomString(len:Int) -> String {
        var _r:String = ""
        for _ in 0..<len {
            let index = Int(randomIn(min: 0, max: VXIUIConfig.shareInstance.K_APP_RANDOM_ARRAY.count - 1))
            if VXIUIConfig.shareInstance.K_APP_RANDOM_ARRAY.count > index {
                _r += VXIUIConfig.shareInstance.K_APP_RANDOM_ARRAY[index]
            }
        }
        return _r
    }
    
    
    //MARK: - 数据处理
    /// 获取Data
    /// - Parameter _any: Any
    static func getJsonDataFor(Any _any:Any) -> Data? {
        
        if !JSONSerialization.isValidJSONObject(_any) {
            print("无法解析出JSONString!详见：\(_any)")
            return nil
        }
        
        var jsonData:Data? = try? JSONSerialization.data(withJSONObject: _any, options: .prettyPrinted)
        if jsonData == nil || jsonData!.count <= 0 {
            jsonData = try? JSONSerialization.data(withJSONObject: _any, options: [])
        }
        
        return jsonData
    }
    
    /** 根据Data获取字典或数组 */
    static func getDicDataFor(Data d:Data?) -> [String:Any]? {
        guard let _d = d else {
            return nil
        }
        
        let _dic = try? JSONSerialization.jsonObject(with: _d, options: [])
        return _dic as? [String : Any]
    }
    
    static func getArrDataFor(Data d:Data?) -> [Any]? {
        guard let _d = d else {
            return nil
        }
        
        let _arr = try? JSONSerialization.jsonObject(with: _d, options: [])
        return _arr as? [Any]
    }
    
    static func jsonEncodeFor(jsonString js:String) -> Any? {
        let data:Data = js.data(using: .utf8)!
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
    
    //MARK: 时间 处理
    /**! 获取本地字符串时间戳 */
    static func localUnixTime() -> String {
        let time:TimeInterval = Date.init().timeIntervalSince1970
        let timeStamp = UInt32(time)
        return String.init(format: "%lD", timeStamp)
    }
    
    /**! 获取本地整数时间戳(单位：秒) */
    static func localUnixTimeForInt() -> TimeInterval {
        let time:TimeInterval = Date().timeIntervalSince1970
        return time
    }
    
    /// 单位：毫秒
    static func localUnixTimeDouble() -> Double {
        return Double(Date().timeIntervalSince1970 * 1000)
    }
    
    /// 获取时长
    static func getDurationFor(Timeinterval _ti:Double) -> String {
        var _strTime:String = ""
        
        //hh:mm:ss(3600:一小时的秒数)
        if _ti >= 3600 {
            let _hv = _ti / 3600
            var _hvs = String.init(format:"%.f",_hv)
            if _hv < 10 {
                _hvs = String.init(format:"0%.f",_hv)
            }
            
            let _mv = (_ti / 60).truncatingRemainder(dividingBy: 60)
            var _mvs = String.init(format:"%.f",floor(_mv))
            if _mv < 10 {
                _mvs = String.init(format:"0%.f",floor(_mv))
            }
            
            let _sv = _ti.truncatingRemainder(dividingBy: 60)
            var _svs = String.init(format:"%.f",_sv)
            if _sv < 10 {
                _svs = String.init(format:"0%.f",_sv)
            }
            
            _strTime = String.init(format:"%@:%@:%@",_hvs,_mvs,_svs)
        }
        //00:ss(小于一分钟)
        else if _ti < 60 {
            if _ti < 10 {
                _strTime = String.init(format:"00:0%.f", _ti)
            }
            else{
                _strTime = String.init(format:"00:%.f", _ti)
            }
        }
        //mm:ss
        else{
            let _mv = (_ti / 60).truncatingRemainder(dividingBy: 60)
            var _mvs = String.init(format:"%.f",floor(_mv))
            if _mv < 10 {
                _mvs = String.init(format:"0%.f",floor(_mv))
            }
            
            let _sv = _ti.truncatingRemainder(dividingBy: 60)
            var _svs = String.init(format:"%.f",_sv)
            if _sv < 10 {
                _svs = String.init(format:"0%.f",_sv)
            }
            
            _strTime = String.init(format:"%@:%@",_mvs,_svs)
        }
        
        return _strTime
    }
    
    /// 计算时间
    /// - Parameters:
    ///   - st: 指定时间字符串
    ///   - t: 类型 0 天 1 小时 2分钟
    ///   - p: true 相加，反之相减(前天、前小时、前年)
    ///   - ft: String 格式化 时间
    ///   - _v: Float 对应的天数或小时(0.5天/小时)
    /// - Returns: <#description#>
    static func calcFor(StartTime st:String,
                        andActionType t:Int,
                        withPlus p:Bool,
                        andFormatType ft:String,
                        andValue _v:Float? = nil) -> String {
        
        guard let date = getDateForStringDate(strDateTime: st, convertType: t) else { return st }
        
        var timeInterval = TimeInterval.init(24 * 60 * 60)
        if _v != nil {
            timeInterval = TimeInterval.init(_v! * 24 * 60 * 60)
        }
        
        if t == 1 {
            timeInterval = TimeInterval.init(60 * 60)
            if _v != nil {
                timeInterval = TimeInterval.init(_v! * 60 * 60)
            }
        }
        else if t == 2 {
            timeInterval = TimeInterval.init(60)
            if _v != nil {
                timeInterval = TimeInterval.init(_v! * 60)
            }
        }
        
        var newDara:Date = date.addingTimeInterval(timeInterval)
        if p == false {
            newDara = date.addingTimeInterval(-timeInterval)
        }
        
        let formatter = DateFormatter.init()
        formatter.dateFormat = ft
        return formatter.string(from: newDara)
    }
    
    /**!
     * 根据字符串时间获取 Date
     * @para strDateTime String   字符串时间
     * @para type Int 时间格式(0：yyyy-MM-dd 1: yyyy/MM/dd 2: yyyy-MM-dd HH:mm:ss 3: yyyy/MM/dd HH:mm)
     */
    static func getDateForStringDate(strDateTime:String,
                                     convertType type:Int = 0) -> Date? {
        var date:Date?
        
        let formatter:DateFormatter = DateFormatter.init()
        switch type {
        case 1:
            formatter.dateFormat = "yyyy/MM/dd"
            
        case 2:
            if self.use24HourClock() {
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            }
            else{
                formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            }
        case 3:
            if self.use24HourClock() {
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
            }
            else{
                formatter.dateFormat = "yyyy/MM/dd hh:mm"
            }
            
        default:
            formatter.dateFormat = "yyyy-MM-dd"
        }
        
        date = formatter.date(from: strDateTime)
        
        return date
    }
    
    /// 判断当前设备是24小时制还是12小时制
    private static func use24HourClock() -> Bool {
        var using24HourClock = false
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        // get date/time (1Jan2001 0000UTC)
        let midnight = Date.init(timeIntervalSinceReferenceDate: 0)
        let dateString = dateFormatter.string(from: midnight)
        // dateString will either be "15:00" or "16:00" (depending on DST) or
        // it will be "4:00 PM" or "3:00 PM" (depending on DST)
        using24HourClock = dateString.count == 5
        
        return using24HourClock
    }
    
    /// UnixTime转Date
    /// - Parameter un: Double
    /// - Returns: Date?
    private static func getDateForUnixtime(un:Double) -> Date {
        var tm = TimeInterval.init(un)
        if fabsf(Float(tm)) >= 10000000000.0 {
            //毫秒转为秒
            tm = TimeInterval.init(un / 1000)
        }
        return Date.init(timeIntervalSince1970: tm)
    }
    
    /**!
     * 获取当前时间
     * @param m String 时间格式
     */
    static func localDateTime(Formatter m:String) -> String {
        let date = Date.init()
        
        let dateFormat:DateFormatter = DateFormatter.init()
        if m.contains("hh") && self.use24HourClock() {
            let _m = m.replacingOccurrences(of: "hh:", with: "HH:")
            dateFormat.dateFormat = _m
        }
        else if m.contains("HH") && !self.use24HourClock() {
            //手机设置的12小时制，强制转换为24小时制
            let zh_CNLocale = Locale.init(identifier: "en_US_POSIX")
            dateFormat.locale = zh_CNLocale
            dateFormat.dateFormat = m
        }
        else{
            dateFormat.dateFormat = m
        }
        
        return dateFormat.string(from: date)
    }
    
    /**!
     * 将Unix 时间戳转换为 字符串时间
     * @para unixTime  UInt32
     * @para strFormat String 转换格式
     */
    static func getDateTimeForUnix(unixTime:TimeInterval,
                                   strFormat:String) -> String {
        
        var date:Date? = Date.init(timeIntervalSince1970: unixTime)
        if fabsf(Float(unixTime)) >= 10000000000.0 {
            date = Date.init(timeIntervalSince1970: unixTime / 1000)
        }
        
        let dateFormat:DateFormatter = DateFormatter.init()
        if strFormat.contains("hh:") && self.use24HourClock() {
            let _m = strFormat.replacingOccurrences(of: "hh:", with: "HH:")
            dateFormat.dateFormat = _m
        }
        else{
            dateFormat.dateFormat = strFormat
        }
        //设置为中文，否则会显示英文星期
        dateFormat.locale = .init(identifier: "zh_cn")
        
        return dateFormat.string(from: date!)
    }
    
    
    //MARK: 消息时间处理
    /// 消息时间计算处理
    /// 前后消息相差5分钟内前一条消息显示时间
    /// - Parameter d: [MessageModel]
    /// - Parameter od: [MessageModel] 之前的数据集合
    static func calcMessageTimeFor(Data d:[MessageModel],
                                   andOldData od:[MessageModel]) {
        if d.count > 0 {
            for i in 0..<d.count - 1 {
                var ct:TimeInterval = localUnixTimeForInt()
                if let _ct = d[i].createTime ?? d[i].timestamp {
                    ct = TimeInterval.init(_ct)
                }
                
                var lt:TimeInterval = localUnixTimeForInt()
                if let _lt = d[i+1].createTime ?? d[i+1].timestamp {
                    lt = TimeInterval.init(_lt)
                }
                
                //两条消息发送时间相隔5分钟以上显示
                if abs(ct - lt) <= 300000 {
                    d[i+1].timeFormatInfo = nil
                    continue
                }
                
                d[i].timeFormatInfo = setIMMessageTimeFor(LastTime: ct)
                d[i+1].timeFormatInfo = setIMMessageTimeFor(LastTime: lt)
            }
            
            if od.count > 0 {
                var ct:TimeInterval = localUnixTimeForInt()
                if let _ct = d.last!.createTime ?? d.last!.timestamp {
                    ct = TimeInterval.init(_ct)
                }
                
                var lt:TimeInterval = localUnixTimeForInt()
                if let _lt = od.first!.createTime ?? od.first!.timestamp {
                    lt = TimeInterval.init(_lt)
                }
                
                //两条消息发送时间相隔5分钟以上显示
                if abs(ct - lt) <= 300000 {
                    od.first?.timeFormatInfo = nil
                }
                else{
                    d.last?.timeFormatInfo = setIMMessageTimeFor(LastTime: ct)
                    if od.count > 0 {
                        od.first?.timeFormatInfo = setIMMessageTimeFor(LastTime: lt)
                    }
                }
            }
        }
    }
    
    /// 计算IM消息的显示时间
    static func setIMMessageTimeFor(LastTime lt:TimeInterval?) -> String? {
        if lt == nil { return nil }
        
        let format = "yyyy-MM-dd"
        //当前系统时间
        var ct_string = self.localDateTime(Formatter: format)
        
        //后数据
        let lt_string = self.getDateTimeForUnix(unixTime: lt!, strFormat: format)
        
        //在同一天 HH:mm
        if ct_string == lt_string {
            return self.getDateTimeForUnix(unixTime: lt!, strFormat: "HH:mm")
        }
        else{
            ct_string = self.calcFor(StartTime: ct_string, andActionType: 0, withPlus: false, andFormatType: "yyyyMMdd",andValue: 7)
            
            //消息超过1天、小于1周，显示星期+收发消息的时间；格式：周几 时分【周三 HH:mm】
            if (Int(ct_string) ?? 0) <= (Int(lt_string.replacingOccurrences(of: "-", with: "")) ?? 0) {
                return TGSUIModel.getDateTimeForUnix(unixTime: lt!,
                                                     strFormat: "EEEE HH:mm").replacingOccurrences(of: "星期", with: "周")
            }
            //消息大于1周，显示手机收发时间的日期；格式：年月日 时分【yyyy-MM-dd HH:mm】
            else{
                return self.getDateTimeForUnix(unixTime: lt!, strFormat: "yyyy-MM-dd HH:mm")
            }
        }
    }
    
    //MARK: 字符
    /**!
     * 是否含有Emoji 表情(true 含有)
     */
    static func stringContainsEmoji(string:String)->Bool{
        var returnValue = false;
        let Str = NSString(format: "%@", string);
        
        Str.enumerateSubstrings(in: NSMakeRange(0, Str.length), options: NSString.EnumerationOptions.byComposedCharacterSequences) { (substring, substringRange, enclosingRange, stop) in
            
            let subStr = NSString(format: "%@", substring!);
            let hs = subStr.character(at: 0);
            // surrogate pair
            if (0xd800 <= hs && hs <= 0xdbff) {
                if (subStr.length > 1) {
                    let ls = subStr.character(at: 1);
                    let uc = Int(((hs - 0xd800) * 0x400) + (ls - 0xdc00)) + 0x10000;
                    if (0x1d000 <= uc && uc <= 0x1f77f){
                        returnValue = true;
                    }
                }
            }
            else if (subStr.length > 1) {
                let ls = subStr.character(at: 1);
                if (ls == 0x20e3){
                    returnValue = true;
                }
            }
            else {
                // non surrogate
                if (0x2100 <= hs && hs <= 0x27ff){
                    returnValue = true;
                }
                else if (0x2B05 <= hs && hs <= 0x2b07){
                    returnValue = true;
                }
                else if (0x2934 <= hs && hs <= 0x2935){
                    returnValue = true;
                }
                else if (0x3297 <= hs && hs <= 0x3299){
                    returnValue = true;
                }
                else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50){
                    returnValue = true;
                }
            }
        };
        
        return returnValue;
    }
    
    
    /// 获取iP
    /// - Returns: String?
    static func getIPAddress() -> String? {
        var ipAddress: String? = nil
        
        if let url = URL(string: "https://api.ipify.org") { // 这里使用了一个公共 API 提供商（ipify）来获取当前设备的 IP 地址
            do {
                let data = try Data(contentsOf: url)
                
                if let addressString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), !addressString.isEmpty {
                    ipAddress = addressString
                }
            } catch {
                debugPrint("Error getting IP address: \(error)")
            }
        } else {
            print("Invalid URL")
        }
        
        return ipAddress
    }
    
    
    /// 计算文本框输入字符数
    /// - Parameters:
    ///   - _max: <#_max description#>
    ///   - _toBeString: <#_toBeString description#>
    ///   - _ipx: <#_ipx description#>
    ///   - _rang: <#_rang description#>
    ///   - _lang: <#_lang description#>
    ///   - _txtView: <#_txtView description#>
    /// - Returns: <#description#>
    static func getCountFor(MaxLength _max:Int,
                            andOriginalText _toBeString:String,
                            andInputText _ipx:String,
                            andRang _rang:NSRange,
                            withPrimaryLanguage _lang:String?,
                            andTextView _txtView:UITextView) -> Int {
        var _len:Int = 0
        
        //简体中文输入
        if _lang == "zh-Hans" {
            //获取高亮部分
            if let selectedRange:UITextRange = _txtView.markedTextRange {
                let position:UITextPosition? = _txtView.position(from: selectedRange.start, offset: 0)
                
                //没有高亮选择的字，则对已输入的文字进行字数统计和限制
                if position == nil {
                    _len = _toBeString.count + _rang.length
                }
                // 有高亮选择的字符串，则暂不对文字进行统计和限制
                else{
                    _len = _rang.location + _rang.length
                }
            }//中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        }
        
        if _ipx.count <= 0 {//表示删除
            _len = _toBeString.count - _rang.length
        }
        _len = _toBeString.count + _ipx.count
        
        return max(_len, 0)
    }
    
    //MARK: 读取配置信息
    /// 获取系统配置信息
    /// - Parameter key: key description
    /// - Returns: GlobalCgaModel?
    static func getSystemInfoModel(key: String) -> GlobalCgaModel? {
        if let _data = String.readLocalCacheDataWithKey(key: key) {
            let _decode = JSONDecoder.init()
            do {
                let _result = try _decode.decode(GlobalCgaModel.self, from: _data)
                return _result
            }
            catch(let _error){
                debugPrint("getSystemInfoModel:\(_error)")
                return nil
            }
        }
        return nil
    }
    
    /// 获取字体配置
    /// - Returns: VXIThemFontsModel?
    static func getThemFontsConfig() -> VXIThemFontsModel? {
        if let _strParh = VXIUIConfig.shareInstance.getBundle()?.path(forResource: "ThemFonts", ofType: "json"),_strParh != "" {
            do{
                if let _data = try? Data.init(contentsOf: URL.init(fileURLWithPath: _strParh)) {
                    let _result = try JSONDecoder.init().decode(VXIThemFontsModel.self, from: _data)
                    return _result
                }
            }
            catch(let _error){
                debugPrint("getThemFontsConfig,异常！详见:\(_error)")
            }
        }
        
        return nil
    }
    
    /// 获取颜色配置
    /// - Returns: VXIThemColorsModel?
    static func getThemColorsConfig() -> VXIThemColorsModel? {
        if let _strParh = VXIUIConfig.shareInstance.getBundle()?.path(forResource: "ThemColors", ofType: "json"),_strParh != "" {
            do{
                if let _data = try? Data.init(contentsOf: URL.init(fileURLWithPath: _strParh)) {
                    let _result = try JSONDecoder.init().decode(VXIThemColorsModel.self, from: _data)
                    return _result
                }
            }
            catch(let _error){
                debugPrint("getThemColorsConfig,异常！详见：\(_error)")
            }
        }
        
        return nil
    }
    
    
    //MARK: 获取文件MimeType
    /// 获取文件MimeType
    /// https://www.runoob.com/http/mime-types.html
    /// - Parameter _fn: <#_fn description#>
    /// - Returns: <#description#>
    static func getMimeTypeFor(FileName _fn:String) -> String {
        if _fn.isEmpty == false,
           let _suffix = _fn.components(separatedBy: ".").last?.lowercased() {
            switch _suffix {
            case "doc":
                //微软 Office Word 格式（Microsoft Word 97 - 2004 document）
                return "application/msword"
            case "docx":
                //微软 Office Word 文档格式
                return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            case "xls":
                //微软 Office Excel 格式（Microsoft Excel 97 - 2004 Workbook
                return "application/vnd.ms-excel"
            case "xlsx":
                ////微软 Office Excel 文档格式
                return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            case "ppt":
                return "application/vnd.ms-powerpoint"//微软 Office PowerPoint 格式（Microsoft PowerPoint 97 - 2003 演示文稿）
            case "pptx":
                return "application/vnd.openxmlformats-officedocument.presentationml.presentation"//微软 Office PowerPoint 文稿格式
            case "gz","gzip":
                return "application/x-gzip"//GZ 压缩文件格式
            case "zip","7zip":
                return "application/zip"//ZIP 压缩文件格式
            case "rar":
                return "application/rar"//RAR 压缩文件格式
            case "tar","tgz":
                return "application/x-tar"//TAR 压缩文件格式
            case "pdf":
                return "application/pdf"//PDF 是 Portable Document Format 的简称，即便携式文档格式
            case "rtf":
                return "application/rtf"//RTF 是指 Rich Text Format，即通常所说的富文本格式
            case "gif":
                return "image/gif" //GIF 图像格式
            case "jpg","jpeg":
                return "image/jpeg"//JPG(JPEG) 图像格式
            case "jpg2":
                return "image/jp2"//JPG2 图像格式
            case "png":
                return "image/png"//PNG 图像格式
            case "tif","tiff":
                return "image/tiff"//TIF(TIFF) 图像格式
            case "bmp":
                return "image/bmp"//BMP 图像格式（位图格式）
            case "svg","svgz":
                return "image/svg+xml"//SVG 图像格式
            case "webp":
                return "image/webp"//WebP 图像格式
            case "ico":
                return "image/x-icon"//ico 图像格式，通常用于浏览器 Favicon 图标
            case "wps":
                return "application/kswps"//金山 Office 文字排版文件格式
            case "et":
                return "application/kset"//金山 Office 表格文件格式
            case "dps":
                return "application/ksdps"//金山 Office 演示文稿格式
            case "psd":
                return "application/x-photoshop"//Photoshop 源文件格式
            case "cdr":
                return "application/x-coreldraw"//Coreldraw 源文件格式
            case "swf":
                return "application/x-shockwave-flash"//Adobe Flash 源文件格式
            case "txt":
                return "text/plain"//普通文本格式
            case "js":
                return "application/x-javascript"//Javascript 文件类型 text/javascript    js    表示 Javascript 脚本文件
            case "css":
                return "text/css"//表示 CSS 样式表
            case "htm","shtml","html":
                return "text/html"//HTML 文件格式
            case "xht","xhtml":
                return "application/xhtml+xml"//XHTML 文件格式
            case "xml":
                return "text/xml"//XML 文件格式
            case "vcf":
                return "text/x-vcard"//VCF 文件格式
            case "php","php3","php4","phtml":
                return "application/x-httpd-php"//PHP 文件格式
            case "jar":
                return "application/java-archive"//Java 归档文件格式
            case "apk":
                return "application/vnd.android.package-archive"//Android 平台包文件格式
            case "exe":
                return "application/octet-stream"//Windows 系统可执行文件格式
            case "crt","pem":
                return "application/x-x509-user-cert"//PEM 文件格式
            case "mp3":
                return "audio/mpeg"//mpeg 音频格式
            case "mid","midi":
                return "audio/midi"//mid 音频格式
            case "wav":
                return "audio/x-wav"//wav 音频格式
            case "m3u":
                return "audio/x-mpegurl"//m3u 音频格式
            case "m4a":
                return "audio/x-m4a"//m4a 音频格式
            case "ogg":
                return "audio/ogg"//ogg 音频格式
            case "ra":
                return "audio/x-realaudio"//Real Audio 音频格式
            case "mp4":
                return "video/mp4"//mp4 视频格式
            case "mpg","mpe","mpeg":
                return "video/mpeg"//mpeg 视频格式
            case "qt","mov":
                return "video/quicktime"//QuickTime 视频格式
            case "m4v":
                return "video/x-m4v" //m4v 视频格式
            case "wmv":
                return "video/x-ms-wmv"//wmv 视频格式（Windows 操作系统上的一种视频格式）
            case "avi":
                return "video/x-msvideo"//avi 视频格式
            case "webm":
                return "video/webm"//webm 视频格式
            case "flv":
                return "video/x-flv"//一种基于 flash 技术的视频格式
                
            default:
                return "application/*"
            }
        }
        
        return "application/*"
    }
    
    /// 判断是否为视频
    /// - Parameter _fn: String 文件名
    /// - Returns: Bool true 是视频
    static func isVideoFor(FileName _fn:String) -> Bool {
        if _fn.isEmpty == false,
           let _suffix = _fn.components(separatedBy: ".").last?.lowercased() {
            return VXIUIConfig.shareInstance.cellVideosSuffixs().contains(_suffix)
        }
        return false
    }
    
    /// 判断是否为图片
    /// - Parameter _fn: String 文件名
    /// - Returns: Bool true 是图片
    static func isPictureFor(FileName _fn:String) -> Bool {
        if _fn.isEmpty == false,
           let _suffix = _fn.components(separatedBy: ".").last?.lowercased() {
            return VXIUIConfig.shareInstance.cellPicturesSuffixs().contains(_suffix)
        }
        return false
    }
    
    /// 获取设备唯一标识
    static func getDeviceUUID() -> String {
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            return uuid.lowercased()
        } else {
            return ""
        }
    }
}


//MARK: -
extension TGSUIModel{
    //MARK: 设置RGB颜色和透明度
    /// 设置RGB颜色和透明度
    static func createColorRGBA(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
    }
    
    //MARK: 设置颜色 传入0xFF0000 转换成对应的rgb
    /// 设置颜色 传入0xFF0000 转换成对应的rgb
    /// - Parameters:
    ///   - hex: 0xFF0000
    ///   - alpha: 1.0
    static func createColorHexInt(_ hex: UInt64, alpha: CGFloat = 1.0) -> UIColor {
        let r = CGFloat((hex & 0xFF0000) >> 16)
        let g = CGFloat((hex & 0xFF00) >> 8)
        let b = CGFloat(hex & 0xFF)
        return createColorRGBA(r, g, b, alpha)
    }
    
    //MARK: 设置颜色 十六进制颜色字符串转换成对应的rgb
    /// 设置颜色 十六进制颜色字符串转换成对应的rgb
    /// - Parameters:
    ///   - hex: 十六进制颜色字符串(1:有#,2:没有#,3:含有0X)
    ///   - alpha: 1.0
    static  func createColorHexString(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var cstr = hex.trimmingCharacters(in:  CharacterSet.whitespacesAndNewlines).uppercased() as NSString
        if(cstr.length < 6){
            return UIColor.clear
        }
        if(cstr.hasPrefix("0X")){
            cstr = cstr.substring(from: 2) as NSString
        }
        if(cstr.hasPrefix("#")){
            cstr = cstr.substring(from: 1) as NSString
        }
        if(cstr.length != 6){
            return UIColor.clear
        }
        var range = NSRange.init()
        range.location = 0
        range.length = 2
        let rStr = cstr.substring(with: range)
        range.location = 2
        let gStr = cstr.substring(with: range)
        range.location = 4
        let bStr = cstr.substring(with: range)
        var r :UInt32 = 0x0
        var g :UInt32 = 0x0
        var b :UInt32 = 0x0
        Scanner.init(string: rStr).scanHexInt32(&r)
        Scanner.init(string: gStr).scanHexInt32(&g)
        Scanner.init(string: bStr).scanHexInt32(&b)
        return createColorRGBA(CGFloat(r), CGFloat(g), CGFloat(b), alpha)
    }
    
}
