//
//  String+Extension.swift
//  YLBaseChat
//
//  Created by yl on 17/5/24.
//  Copyright © 2017年 yl. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto
@_implementationOnly import VisionCCiOSSDKEngine

// MARK: - String 拓展
extension String {
    
    // text 转 NSAttributedString
    func yl_conversionAttributedString(align _align:NSTextAlignment) -> NSMutableAttributedString? {
        
        let content = self
        if (content.count == 0) {
            return nil
        }
        
        //字间距
        let paraStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        paraStyle.lineBreakMode = .byWordWrapping
        paraStyle.lineSpacing = 6 //设置行间距
        paraStyle.hyphenationFactor = 1.0
        paraStyle.firstLineHeadIndent = 0.0
        paraStyle.paragraphSpacingBefore = 0.0
        paraStyle.alignment = _align
        
        paraStyle.headIndent = 0
        paraStyle.tailIndent = 0
        
        var mutableText = NSMutableAttributedString.init(string: content)
        if let _data = content.data(using: .unicode),content.contains("\n") == false {
            debugPrint("yl_conversionAttributedString:\(content)")
            do{
                let _attr = try NSMutableAttributedString.init(data: _data,
                                                               options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html],
                                                               documentAttributes: nil)
                mutableText = _attr
            }
            catch(let _error){
                debugPrint(_error.localizedDescription)
            }
        }
        
        mutableText.yy_font = VXIUIConfig.shareInstance.cellMessageFont()
        mutableText.yy_color = VXIUIConfig.shareInstance.cellMessageColor()
        mutableText.yy_paragraphStyle = paraStyle
        let _str = mutableText.string
        
        // 匹配地址
        let stringRange = NSMakeRange(0, _str.utf16.count)
        self.yl_mateUrlFor(AttributedString: mutableText, andRang: stringRange)
        
        return mutableText
    }
    
    /// 匹配地址
    func yl_mateUrlFor(AttributedString attributedString:NSMutableAttributedString,
                       andRang stringRange:NSRange){
        var arrReplace = [[String:Any]]()
        let strRegex = VXIUIConfig.shareInstance.cellMessageLinkRegex()
        if let regexps:NSRegularExpression = try? NSRegularExpression.init(pattern: strRegex, options: NSRegularExpression.Options(rawValue: 0)) {
            
            let _str = attributedString.string
            regexps.enumerateMatches(in: _str,
                                     options: NSRegularExpression.MatchingOptions.init(rawValue: 0),
                                     range: stringRange) { (result:NSTextCheckingResult?, _:NSRegularExpression.MatchingFlags, _:UnsafeMutablePointer<ObjCBool>) in
                //可能为网址的字符串及其所在位置
                if let urlRange = result?.range {
                    var _url = NSString.init(string: _str).substring(with: urlRange)
                    
                    //加入数组，好替换
                    arrReplace.append([
                        "url":_url,
                        "rang":urlRange
                    ])
                    
                    attributedString.yy_setTextHighlight(urlRange,
                                                         color: UIColor.init().colorFromHexInt(hex: 0x00AEFF),
                                                         backgroundColor: UIColor.clear) { (_v:UIView, attr:NSAttributedString, _rang:NSRange, _rect:CGRect) in
                        print("匹配网址：\(_url)")
                        
                        
                        if _url.lowercased().hasPrefix("http") || _url.lowercased().hasPrefix("https") {
                            _url = _url.yl_isChinese() ? _url.yl_urlEncoded():_url
                        }
                        else{
                            _url = ("http://" + _url).yl_isChinese() ? ("http://" + _url).yl_urlEncoded():("http://" + _url)
                        }
                        
                        TGSUIModel.gotoWebViewFor(Path: _url)
                    }
                }
            }
            
            //从后往前替换
            var i = arrReplace.count - 1
            while i >= 0, arrReplace.count > 0 {
                let dicTemp = arrReplace[i]
                if let _rang = dicTemp["rang"] as? NSRange,let _url = dicTemp["url"] as? String {
                    attributedString.replaceCharacters(in: _rang, with: _url)
                }
                i -= 1
            }
        }
    }
    
    /// 匹配文本中所有地址消息及剔除地址后的文本
    func yl_mateUrlFor(Rang stringRange:NSRange) -> ([String],String)? {
        var _arrUrls = [String]()
        var _title = self
        
        let strRegex = VXIUIConfig.shareInstance.cellMessageLinkRegex()
        if let regexps:NSRegularExpression = try? NSRegularExpression.init(pattern: strRegex, options: NSRegularExpression.Options(rawValue: 0)) {
            
            regexps.enumerateMatches(in: _title,
                                     options: NSRegularExpression.MatchingOptions.init(rawValue: 0),
                                     range: stringRange) { (result:NSTextCheckingResult?, _:NSRegularExpression.MatchingFlags, _:UnsafeMutablePointer<ObjCBool>) in
                //可能为网址的字符串及其所在位置
                if let urlRange = result?.range {
                    let _url = NSString.init(string: _title).substring(with: urlRange)
                    
                    //加入数组，好替换
                    _arrUrls.append(_url)
                }
            }
            
            //替换
            for _url in _arrUrls {
                _title = _title.replacingOccurrences(of: _url, with: "")
            }
            
            if _title.isEmpty == true,self.contains(" ") {
                _title = self.components(separatedBy: " ").last ?? ""
            }
            return (_arrUrls,_title)
        }
        
        return nil
    }
    
    
    /// 获取文本的高度
    func yl_getLabelHeight(Font font:UIFont,
                           andWidth width:CGFloat) -> (CGFloat,CGSize) {
        let size = NSString.init(string: self).boundingRect(with: CGSize(width:width,height: CGFloat(MAXFLOAT)),
                                                            options: [.usesLineFragmentOrigin,.usesFontLeading],
                                                            attributes: [NSAttributedString.Key.font : font],
                                                            context: nil)
        
        return (size.height,size.size)
    }
    
    /// 获取文本宽度
    func yl_getLabelWidth(Font font:UIFont,
                          andHeight h:CGFloat) -> CGFloat {
        let size = NSString.init(string: self).boundingRect(with: CGSize(width:CGFloat(MAXFLOAT),height: h),
                                                            options: [.usesLineFragmentOrigin,.usesFontLeading],
                                                            attributes: [NSAttributedString.Key.font : font],
                                                            context: nil)
        
        return size.width
    }
    
    /// 获取文本的宽度
    func yl_getWidthFor(Font _f:UIFont) -> CGFloat {
        var fw = CGFloat.init(0)
        let size = NSString.init(string: self).size(withAttributes: [
            NSAttributedString.Key.font:_f
        ])
        fw = size.width
        
        return fw
    }
    
    /// 设置富文本
    /// - Parameters:
    ///   - textFont: <#textFont description#>
    ///   - textColor: <#textColor description#>
    ///   - changeText: <#changeText description#>
    ///   - changFont: <#changFont description#>
    ///   - changeColor: <#changeColor description#>
    ///   - isLineThrough: <#isLineThrough description#>
    ///   - _align: <#_align description#>
    ///   - _lbm: <#_lbm description#>
    ///   - _ls: <#_ls description#>
    /// - Returns: NSAttributedString
    func yl_setAttributeStringText(FullTextFont textFont:UIFont,
                                   andFullTextColor textColor:UIColor,
                                   withChangeText changeText:String,
                                   withChangeFont changFont:UIFont,
                                   withChangeColor changeColor:UIColor,
                                   isLineThrough:Bool = false,
                                   andAlign _align:NSTextAlignment = .left,
                                   andLineBreakMode _lbm:NSLineBreakMode = .byWordWrapping,
                                   andLineSpacing _ls:CGFloat = 6) -> NSAttributedString {
        
        let paraStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        paraStyle.lineBreakMode = _lbm
        paraStyle.lineSpacing = _ls //设置行间距
        paraStyle.hyphenationFactor = 1.0
        paraStyle.firstLineHeadIndent = 0.0
        paraStyle.paragraphSpacingBefore = 0.0
        paraStyle.alignment = _align
        
        paraStyle.headIndent = 0
        paraStyle.tailIndent = 0
        
        var dicAttr:[NSAttributedString.Key:Any]?
        let attributeString = NSMutableAttributedString.init(string: self)
        
        //不需要改变的文本
        var range = NSRange.init(location: 0, length: self.count)
        
        dicAttr = [
            NSAttributedString.Key.font:textFont,
            NSAttributedString.Key.foregroundColor:textColor,
            NSAttributedString.Key.paragraphStyle:paraStyle,
        ]
        attributeString.addAttributes(dicAttr!, range: range)
        
        //需要改变的文本
        range = NSString.init(string: self).range(of: changeText)
        
        dicAttr = [
            NSAttributedString.Key.font:changFont,
            NSAttributedString.Key.foregroundColor:changeColor,
        ]
        
        if #available(iOS 14.0, *) {
            dicAttr?[.tracking] = 1.0
        }
        
        if isLineThrough {
            dicAttr?[NSAttributedString.Key.strikethroughStyle] = NSNumber.init(value: 1)
        }
        attributeString.addAttributes(dicAttr!, range: range)
        
        return attributeString
    }
    
    /**!
     * 验证手机号、座机号
     * @return true 通过验证
     */
    func yl_checkTelephoneOrMobilephone() -> Bool {
        
        if self.isEmpty {
            return false
        }
        
        let strRegex = "^\\d{3,4}[-]?\\d{7,8}$"
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", strRegex)
        
        return predicate.evaluate(with: self)
    }
    
    /// 验证是否为手机号
    ///
    /// - Returns: ture or false
    func yl_isMobelNumber() -> Bool {
        guard self.isEmpty == false else {
            return false
        }
        let mobile = "^1[3456789]\\d{9}$"
        let regextestmobiel = NSPredicate(format: "SELF MATCHES %@", mobile)
        return regextestmobiel.evaluate(with: self)
    }
    
    /**!
     * 验证邮箱
     * @return true 通过验证
     */
    func yl_checkEmail() -> Bool {
        
        if self.isEmpty {
            return false
        }
        
        let strRegex = "^[A-Z0-9a-z_\\.\\-]+\\@([A-Za-z0-9\\-]+\\.)+([A-Za-z0-9])+$"
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", strRegex)
        
        return predicate.evaluate(with: self)
    }
    
    /// 将原始的url编码为合法的url
    /// - Returns: String
    func yl_urlEncoded() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
    /// !判断是否存在中文以及中文符号(true 存在)
    func yl_isChinese() -> Bool {
        //        if self != "" {
        //            for item in self {
        //                //汉字和中文标点，三个字节
        //                if "\(item)".lengthOfBytes(using: .utf8) == 3 {
        //                    return true
        //                }
        //            }
        //            return false
        //        }
        //        return false
        
        //去掉首尾空格
        let _str = self.trimmingCharacters(in: .whitespaces)
        var pattern = "[\\u4e00-\\u9fa5]+" // Unicode范围内的汉字
        if NSPredicate(format:"SELF MATCHES %@", pattern).evaluate(with: _str) {
            return true
        } else {
            pattern = "[\u{2E80}-\u{FE4F}]"
            if NSPredicate(format:"SELF MATCHES %@", pattern).evaluate(with: _str) {
                return true
            }
            //中间空格也需要编码(有的文件上传没有重命名，中间带有空格)
            else if self.contains(" ") {
                return true
            }
            else{
                for item in self {
                    //汉字和中文标点，三个字节
                    if "\(item)".lengthOfBytes(using: .utf8) == 3 {
                        return true
                    }
                }
            }
            return false
        }
    }
    
    /// utf8Stirng
    /// - Returns: <#description#>
    func yl_toUTF8String() -> String {
        do{
            if let encodedData:Data = self.data(using: .utf8) {
                
                let attributedOptions = [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html]
                if let attributedString = try? NSAttributedString.init(data: encodedData,
                                                                       options: attributedOptions,
                                                                       documentAttributes: nil) {
                    return attributedString.string
                }
            }
        }
        
        return self
    }
    
    /// 将编码后的url转换回原始的url
    /// - Returns: String
    func yl_urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
    
    
    //MARK: 加密
    /**
     * 加密设置
     * 例子：
     * 1、shar256 加密：
     * string.hmac(by: .SHA256, key: APP_SECRET.bytes).base64String
     * string.hmac(by: .SHA256, key: APP_SECRET.bytes).hexString
     *
     * 2、MD5加密
     * string.hash(by: .MD5).hexString
     */
    func hmac(by algorithm: Algorithm, key: [UInt8]) -> [UInt8] {
        var result = [UInt8](repeating: 0, count: algorithm.digestLength())
        CCHmac(algorithm.algorithm(), key, key.count, self.bytes, self.bytes.count, &result)
        return result
    }
    
    func hashHex(by algorithm: Algorithm) -> String {
        return algorithm.hash(string: self).hexString
    }
    
    func hash(by algorithm: Algorithm) -> [UInt8] {
        return algorithm.hash(string: self)
    }
}


//MARK: -
extension String {
    
    
    /// 读取数据
    /// - Parameter key: <#key description#>
    /// - Returns: <#description#>
    static func readLocalCacheDataWithKey(key: String) -> Data? {
        return UserDefaults.standard.data(forKey: key)
    }
    
    
    /// 保存数据
    /// - Parameters:
    ///   - data: <#data description#>
    ///   - key: <#key description#>
    static func writeLocalCacheData(data: Data?,
                                    key: String,
                                    andOtherData _dicOther:[String:Any]? = nil) {
        if data != nil {
            UserDefaults.standard.setValue(data!, forKey: key)
        }
        else{
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
        
        //配置更新，发送通知
        if key == VXIUIConfig.shareInstance.getGlobalCgaKey() {
            //发送通知更新
            NotificationCenter.default.post(name: VXIUIConfig.shareInstance.getInputQuickReplyHandleKey(),
                                            object: nil,
                                            userInfo: ["isShow" : true])
            
            //转人工配置更新
            NotificationCenter.default.post(name: VXIUIConfig.shareInstance.getEnabledEntranceKey(),
                                            object: nil,
                                            userInfo: ["isShow" : (_dicOther?["channel"] as? [String:Any])?["enabled_entrance"] as? Bool ?? false])
            
            //            //是否开启访客自主评价信息(以推送设置显示与否为准)
            //            NotificationCenter.default.post(name: VXIUIConfig.shareInstance.getEnabledGuestSensitiveKey(),
            //                                            object: nil,
            //                                            userInfo: [
            //                                                "isShow":(_dicOther?["guest"] as? [String:Any])?["enabledGuestSensitive"] as? Bool ?? false
            //                                            ])
            
            //发送表情通知
            NotificationCenter.default.post(name: VXIUIConfig.shareInstance.getFaceConfigkey(),
                                            object: nil,
                                            userInfo: [
                                                "data":_dicOther?["stickerPkgs"] ?? [[String:Any]]()
                                            ])
        }
    }
    
}


//MARK: - Algorithm
enum Algorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func algorithm() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:    result = kCCHmacAlgMD5
        case .SHA1:   result = kCCHmacAlgSHA1
        case .SHA224: result = kCCHmacAlgSHA224
        case .SHA256: result = kCCHmacAlgSHA256
        case .SHA384: result = kCCHmacAlgSHA384
        case .SHA512: result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:    result = CC_MD5_DIGEST_LENGTH
        case .SHA1:   result = CC_SHA1_DIGEST_LENGTH
        case .SHA224: result = CC_SHA224_DIGEST_LENGTH
        case .SHA256: result = CC_SHA256_DIGEST_LENGTH
        case .SHA384: result = CC_SHA384_DIGEST_LENGTH
        case .SHA512: result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
    
    func hash(string: String) -> [UInt8] {
        var hash = [UInt8](repeating: 0, count: self.digestLength())
        switch self {
        case .MD5:    CC_MD5(   string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA1:   CC_SHA1(  string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA224: CC_SHA224(string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA256: CC_SHA256(string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA384: CC_SHA384(string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA512: CC_SHA512(string.bytes, CC_LONG(string.bytes.count), &hash)
        }
        return hash
    }
}


extension Array where Element == UInt8 {
    var hexString: String {
        return self.reduce(""){$0 + String(format: "%02x", $1)}
    }
    
    var base64String: String {
        return self.data.base64EncodedString(options: Data.Base64EncodingOptions.lineLength76Characters)
    }
    
    var data: Data {
        return Data(self)
    }
}

extension String {
    var bytes: [UInt8] {
        return [UInt8](self.utf8)
    }
}

extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}
