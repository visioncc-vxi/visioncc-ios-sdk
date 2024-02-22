//
//  Extension.swift
//  YLBaseChat
//
//  Created by yl on 17/5/24.
//  Copyright © 2017年 yl. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


//MARK: - Date
extension Date {
    
    // 返回聊天室的时间
    func getShowFormat() -> String {
        
        let requestDate = self
        
        //获取当前时间
        let calendar = Calendar.current
        //判断是否是今天
        if calendar.isDateInToday(requestDate as Date) {
            //获取当前时间和系统时间的差距(单位是秒)
            //强制转换为Int
            let since = Int(Date().timeIntervalSince(requestDate as Date))
            //  是否是刚刚
            if since < 60 {
                return "刚刚"
            }
            //  是否是多少分钟内
            if since < 60 * 60 {
                return "\(since/60)分钟前"
            }
            //  是否是多少小时内
            return "\(since / (60 * 60))小时前"
        }
        
        //判断是否是昨天
        var formatterString = " HH:mm"
        if calendar.isDateInYesterday(requestDate as Date) {
            formatterString = "昨天" + formatterString
        } else {
            //判断是否是一年内
            formatterString = "MM-dd" + formatterString
            //判断是否是更早期
            
            let comps = calendar.dateComponents([Calendar.Component.year], from: requestDate, to: Date())
            
            if comps.year! >= 1 {
                formatterString = "yyyy-" + formatterString
            }
        }
        
        //按照指定的格式将日期转换为字符串
        //创建formatter
        let formatter = DateFormatter()
        //设置时间格式
        formatter.dateFormat = formatterString
        //设置时间区域
        formatter.locale = NSLocale(localeIdentifier: "en") as Locale
        
        //格式化
        return formatter.string(from: requestDate as Date)
    }
}


//MARK: - UIColor
extension UIColor {
    
    class func colorFromRGB(_ rgb:Int) -> UIColor {
        return UIColor(red: CGFloat(CGFloat((rgb & 0xFF0000) >> 16) / 255.0) ,
                       green: CGFloat(CGFloat((rgb & 0xFF00) >> 8) / 255.0) ,
                       blue: CGFloat(CGFloat(rgb & 0xFF) / 255.0) ,
                       alpha: 1.0)
        
    }
    
    /**
     * 获取颜色
     * @parameter hex:#开头字符串("#ffffff")
     * @return UIColor
     */
    func colorFromHexString(hex:String) -> UIColor {
        
        var strTemp = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if strTemp.hasPrefix("#") {
            strTemp = NSString.init(string: strTemp).substring(from: 1)
        }
        
        if strTemp.count != 6 {
            if #available(iOS 13.0, *) {
                let _tc = UIColor.init { (trainCollection:UITraitCollection) -> UIColor in
                    if trainCollection.userInterfaceStyle == .dark {
                        return UIColor.white
                    }
                    return UIColor.gray
                }
                return _tc
            }
            
            return UIColor.gray
        }
        
        let rStr:String = NSString.init(string: strTemp).substring(to: 2)
        let gStr:String = (NSString.init(string: strTemp).substring(from: 2) as NSString).substring(to: 2)
        let bStr:String = NSString.init(string: strTemp).substring(from: 4)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner.init(string: rStr).scanHexInt32(&r)
        Scanner.init(string: gStr).scanHexInt32(&g)
        Scanner.init(string: bStr).scanHexInt32(&b)
        
        let tc = UIColor.init(red: CGFloat.init(r)/255.0,
                              green: CGFloat.init(g)/255.0,
                              blue: CGFloat.init(b)/255.0,
                              alpha: 1)
        
        if #available(iOS 13.0, *) {
            let _tc = UIColor.init { (trainCollection:UITraitCollection) -> UIColor in
                if trainCollection.userInterfaceStyle == .dark {
                    return UIColor.white
                }
                return tc
            }
            return _tc
        }
        return tc
    }
    
    /**
     * 获取颜色
     * @parameter hex:十六进制 0xffffff
     * @return UIColor
     */
    func colorFromHexInt(hex:Int,alpha:CGFloat = CGFloat.init(1)) -> UIColor {
        return UIColor.init(red: CGFloat.init((hex & 0xFF0000) >> 16) / 255.0,
                            green: CGFloat.init((hex & 0xFF00) >> 8) / 255.0,
                            blue: CGFloat.init(hex & 0xFF) / 255.0,
                            alpha: alpha)
    }
    
}

//MARK: - UIDevice
extension UIDevice {
    
    /// 手机型号
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
            //TODO:iPod touch
        case "iPod1,1":                                       return "iPod touch"
        case "iPod2,1":                                       return "iPod touch (2nd generation)"
        case "iPod3,1":                                       return "iPod touch (3rd generation)"
        case "iPod4,1":                                       return "iPod touch (4th generation)"
        case "iPod5,1":                                       return "iPod touch (5th generation)"
        case "iPod7,1":                                       return "iPod touch (6th generation)"
        case "iPod9,1":                                       return "iPod touch (7th generation)"
            
            //TODO:iPad
        case "iPad1,1":                                       return "iPad"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
        case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
        case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
        case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
        case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
        case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
        case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
            
            //TODO:iPad Air
        case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
        case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
        case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
        case "iPad13,1", "iPad13,2":                          return "iPad Air (4rd generation)"
            
            //TODO:iPad Pro
        case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
        case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch)"
        case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
        case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch)"
        case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
        case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
            
            //TODO:iPad mini
        case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                            return "iPad Mini 4"
        case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
        case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
            
            //TODO:iPhone
        case "iPhone1,1":                               return "iPhone"
        case "iPhone1,2":                               return "iPhone 3G"
        case "iPhone2,1":                               return "iPhone 3GS"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE (1st generation)"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,8":                              return "iPhone XR"
        case "iPhone11,2":                              return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
        case "iPhone12,1":                              return "iPhone 11"
        case "iPhone12,3":                              return "iPhone 11 Pro"
        case "iPhone12,5":                              return "iPhone 11 Pro Max"
        case "iPhone12,8":                              return "iPhone SE (2nd generation)"
        case "iPhone13,1":                              return "iPhone 12 mini"
        case "iPhone13,2":                              return "iPhone 12"
        case "iPhone13,3":                              return "iPhone 12 Pro"
        case "iPhone13,4":                              return "iPhone 12 Pro Max"
        case "iPhone14,4":                              return "iPhone 13 mini"
        case "iPhone14,5":                              return "iPhone 13"
        case "iPhone14,2":                              return "iPhone 13 Pro"
        case "iPhone14,3":                              return "iPhone 13 Pro Max"
        case "iPhone14,6":                              return "iPhone SE (3rd generation)"
        case "iPhone14,7":                              return "iPhone 14"
        case "iPhone14,8":                              return "iPhone 14 Plus"
        case "iPhone15,2":                              return "iPhone 14 Pro"
        case "iPhone15,3":                              return "iPhone 14 Pro Max"
            
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "iPhone Simulator"
        default:                                        return identifier
        }
    }
    
}


//MARK: - 函数防抖节流
extension Reactive where Base: UIButton {
    
    var safeTap: ControlEvent<Void> {
        return ControlEvent.init(events: tap.throttle(.milliseconds(1500), latest: false, scheduler: MainScheduler.instance))
    }
    
    ///避免连续点击(1.5 秒响应一次)
    func safeDrive(onNext: @escaping ((Base) -> Void)) -> Disposable {
        return self.safeTap
            .asControlEvent()
            .asDriver()
            .drive {
                onNext(self.base)
            } onCompleted: {
                
            } onDisposed: {
                
            }
    }
}

extension Reactive where Base: UITextField {
    ///避免连续调用(1.5 秒响应一次)
    func safeDrive(_ dueTime: RxSwift.RxTimeInterval = .milliseconds(1500), onNext: @escaping ((String) -> Void)) -> Disposable {
        return text.orEmpty
            .asDriver()
            .distinctUntilChanged()
            .debounce(dueTime)
            .drive(onNext: { (query) in
                onNext(query)
            }) {
                
            } onDisposed: {
                
            }
    }
}

extension Reactive where Base: UISearchBar{
    ///避免连续调用(1.5 秒响应一次)
    func safeDrive(_ dueTime: RxSwift.RxTimeInterval = .milliseconds(1500), onNext: @escaping ((String) -> Void)) -> Disposable {
        return text.orEmpty
            .asDriver()
            .distinctUntilChanged()
            .debounce(dueTime)
            .drive(onNext: { (query) in
                onNext(query)
            }) {
                
            } onDisposed: {
                
            }
    }
}

extension UIButton{
    ///避免连续调用(1.5 秒响应一次)
    func rxDrive(onNext: @escaping ((UIButton) -> Void)) -> Disposable {
        return self.rx.safeDrive(onNext: onNext)
    }
}

extension UITextField {
    ///避免连续调用(1.5 秒响应一次)
    func rxDrive(onNext: @escaping ((String) -> Void)) -> Disposable {
        return self.rx.safeDrive(onNext: onNext)
    }
}

extension UISearchBar {
    ///避免连续调用(1.5 秒响应一次)
    func rxDrive(onNext: @escaping ((String) -> Void)) -> Disposable {
        return self.rx.safeDrive(onNext: onNext)
    }
}

