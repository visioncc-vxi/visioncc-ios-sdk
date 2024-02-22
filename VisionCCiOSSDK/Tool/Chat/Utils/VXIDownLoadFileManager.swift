//
//  VXIDownLoadFileManager.swift
//  Tool
//
//  Created by CQP-MacPro on 2023/12/29.
//

import UIKit
import UniformTypeIdentifiers
@_implementationOnly import VisionCCiOSSDKEngine

///文件下载
class  VXIDownLoadFileManager: NSObject {
    
    /// 创建单例对象
    static let share =  VXIDownLoadFileManager()
    
    private override init() {
        
    }
    
    //MARK: - lazy load
    private lazy var isSave:Bool = false
    
    private lazy var pickeduRL:URL? = nil
    
    /// 文件选择结果回调
    ///_fileSize:单位 KB（服务端统一规定）
    lazy var choiceFileInfoBlock:((_ _filePath:URL?,_ _data:Data?,_ _fileName:String?,_ _fileSize:Double?)->Void)? = nil
    
    /// 打开文件选择
    func openFile(_ _types:[String] = ["public.data"]){
        isSave = false
        let vc = UIDocumentPickerViewController(documentTypes: _types, in: UIDocumentPickerMode.open)
        vc.delegate = self
        vc.modalPresentationStyle = .formSheet
        //        vc.allowsMultipleSelection = true//ios11之后 加入多选功能
        VXIUIConfig.shareInstance.keyWindow().rootViewController?.present(vc, animated: true)
        //        UIApplication.shared.topViewController?.present(vc, animated: true)
        
        //清除
        self.choiceFileInfoBlock = nil
    }
    
    /// 保存文件
    func saveFileToPhone(url: URL) {
        isSave = true
        let picker = UIDocumentPickerViewController(url: url, in: .exportToService)
        picker.delegate = self
        picker.modalPresentationStyle = .formSheet
        //        vc.allowsMultipleSelection = true//ios11之后 加入多选功能
        //        VXIUIConfig.shareInstance.keyWindow().getVC()?.present(picker, animated: true)
        VXIUIConfig.shareInstance.keyWindow().rootViewController?.present(picker, animated: true)
        //        UIApplication.shared.topViewController?.present(picker, animated: true)
        
    }
    
    /// 预览功能
    func previewFile(filePath:String,
                     andFileName _fn:String? = nil,
                     withDelegate _d:UIDocumentInteractionControllerDelegate? = nil){
        
        var pickeduRL:URL? = URL(string: filePath.yl_isChinese() ? filePath.yl_urlEncoded() : filePath)
        if !filePath.hasPrefix("http") {
            pickeduRL = URL.init(fileURLWithPath: filePath.yl_isChinese() ? filePath.yl_urlEncoded() : filePath)
        }
        
        self.pickeduRL = pickeduRL
        if pickeduRL != nil {
            let documentVC = UIDocumentInteractionController.init()
            documentVC.delegate = _d
            documentVC.name = _fn ?? "文件预览"
            documentVC.url = pickeduRL
            documentVC.presentPreview(animated: true)
        }else{
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at:"文件路径错误")
        }
    }
    
    
    //MARK: 下载
    /// 下载文件
    func downloadFile(fileUrl:String?) {
        
        guard let urlStr = fileUrl, let taskUrl = URL(string: urlStr.yl_isChinese() ? urlStr.yl_urlEncoded() : urlStr) else { return }
        debugPrint("文件下载url:\(taskUrl)")
        
        let request = URLRequest(url: taskUrl)
        let session = URLSession(configuration: .default)
        session.downloadTask(with: request) { [weak self] tempUrl, response, error in
            guard let self = self, let tempUrl = tempUrl, error == nil else {
                debugPrint("文件下载失败")
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "文件下载失败")
                return
            }
            debugPrint("文件下载完成\(tempUrl)")
            // 下载完成之后会自动删除temp中的文件，把文件移动到document中。
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            debugPrint("文件下载完成 documentsDirectory \(documentsDirectory)")
            
            // 建议使用的文件名，一般跟服务器端的文件名一致
            let destinationPath = documentsDirectory.appendingPathComponent(response?.suggestedFilename ?? "")
            
            // 如果存在同名的
            if FileManager.default.fileExists(atPath: destinationPath.path) {
                do {
                    try FileManager.default.removeItem(atPath: destinationPath.path)
                } catch _ {
                    
                }
            }
            debugPrint("文件下载 document下的可保存的url:\(destinationPath)")
            do {
                // 文件移动至document
                try FileManager.default.copyItem(atPath: tempUrl.path, toPath: destinationPath.path)
                // main
                DispatchQueue.main.async {
                    self.saveFileToPhone(url: destinationPath)
                }
            } catch let error {
                debugPrint(error)
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "\(error.localizedDescription)")
            }
        }.resume()
    }
    
    /// 下载文件到缓存中
    /// - Parameters:
    ///   - _fp: 缓存中的路径
    ///   - _strUrl: 文件地址
    ///   - _title: 名称
    func downloadFileInCacheFor(Url _strUrl:String,
                                andTitle _title:String,
                                andLoading _loading:Bool = false,
                                withProgressBlock _progressBlock:((_ progress:Double) -> (Void))? = nil,
                                andFinishBlock _fb:((_ _isOK:Bool,_ _data:Data?,_ _fileCachePath:String?,_ _msg:String) -> Void)? = nil) {
        
        //1、判断缓存是否存在该文件
        let fm = FileManager.default
        let _p = VXIUIConfig.shareInstance.getCachePath() + "/\(_title.yl_isChinese() ? _title.yl_urlEncoded() : _title)"
        debugPrint("downloadFileInCacheFor:{cachePath:\(_p),url:\(_strUrl)}")
        
        //存在
        if fm.fileExists(atPath: _p) {
            let url = URL.init(fileURLWithPath: _p)
            _progressBlock?(1)
            _fb?(true,try? Data.init(contentsOf: url),_p,"文件获取成功")
        }
        //不存在,下载到缓存
        else{
            var _nUrl = _strUrl
            if _strUrl.yl_isChinese(){
                _nUrl = _strUrl.yl_urlEncoded()
            }
            CMRequest.shareInstance().downloadFileForServer(strUrl: _nUrl,
                                                            AndSuccessBack: { responseData in
                if let _data = responseData as? Data {
                    if FileManager.default.createFile(atPath: _p, contents: _data) {
                        _fb?(true,_data,_p,"文件获取成功")
                    }
                    else{
                        VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "缓存文件失败请稍后重试")
                    }
                }
                else{
                    debugPrint("文件不存在请重试")
                    _fb?(false,nil,_p,"文件不存在请重试")
                }
            }, AndFailureBack: { responseString in
                debugPrint(responseString ?? "下载失败请稍后再试")
                _fb?(false,nil,_p,responseString ?? "下载失败请稍后再试")
            }, AndProgressBlock: { progress in
                _progressBlock?(progress)
                if progress >= 1.0 {
                    SVProgressHUD.dismiss()
                }
            }, WithisLoading: _loading)
        }
    }
}


//MARK: -
extension VXIDownLoadFileManager {
    
    func sizeForLocalFilePath(filePath:String) -> UInt64 {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = fileAttributes[FileAttributeKey.size] as? UInt64  {
                return fileSize
            } else {
                print("Failed to get a size attribute from path: \(filePath)")
            }
        }
        catch {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }
    
    
    /// 文件大小格式化
    /// - Parameter size: <#size description#>
    /// - Returns: <#description#>
    func foramtFileStringFor(Size size: Double) -> String {
        var convertedValue: Double = size
        var multiplyFactor = 0
        //服务端返回的文件最小单位为KB
        let tokens = ["KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
    
    private func covertToFileString(with size: UInt64) -> String {
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
    
}


//MARK: - UIDocumentPickerDelegate
extension VXIDownLoadFileManager : UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // 保存成功
        if isSave {
            VXIUIConfig.shareInstance.keyWindow().showSuccessInfo(at: "保存成功")
        }else{
            guard let pickedURL = urls.first else {
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "选择的文件路径不存在")
                
                choiceFileInfoBlock?(nil,nil,nil,nil)
                return
            }
            print("选择的文件路径 = \(pickedURL)")
            
            if pickedURL.startAccessingSecurityScopedResource() {
                debugPrint("授权成功")
                
                let fileName:String = pickedURL.lastPathComponent
                //文件单位：bytes
                let fileInt = sizeForLocalFilePath(filePath: pickedURL.path)
                let fileIntStr = covertToFileString(with: fileInt)
                let fileData:Data? = try? Data.init(contentsOf: pickedURL)
                debugPrint("文件名称 = \(fileName), 文件大小 = \(fileIntStr)")
                
                _ = try? Data(contentsOf: pickedURL, options: Data.ReadingOptions.mappedIfSafe)
                pickedURL.stopAccessingSecurityScopedResource()
                
                choiceFileInfoBlock?(pickedURL,fileData,fileName,Double(fileInt) / 1000)
            }else{
                VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "授权失败，请您去设置页面打开授权")
                choiceFileInfoBlock?(nil,nil,nil,nil)
            }
            
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        debugPrint("操作被取消")
    }
    
}
