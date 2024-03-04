//
//  WebDetailsViewController.swift
//  Tool
//
//  Created by apple on 2024/1/22.
//

import UIKit
import WebKit
import SnapKit
import RxSwift

/// 内部浏览器
class WebDetailsViewController: UIViewController,WKScriptMessageHandler {

    //加载结束
    var wkViewDidFinishBlock:(()->Void)?
    
    //地址重定向监听
    var navigationActionPolicyChange:((_ changeUrl:URL?)->Void)?
    
    var url: String? {
        didSet{
            weak var weakSelf = self
            if weakSelf?.url == nil || weakSelf?.url == "" {
                print("地址不存在，不做处理")
                return
            }
            
            var _path = weakSelf?.url ?? ""
            if _path.yl_isChinese() {
                _path = _path.yl_urlEncoded()
            }
            
            if _path.hasSuffix(".pdf") || _path.contains(".pdf") {
                weakSelf?.loadRequest(path: _path)
            }
            else{
                if _path.hasPrefix("file://") {
                    let _url = URL.init(fileURLWithPath: _path)
                    if #unavailable(iOS 13.0) {
                        self.wkWebview.loadFileURL(_url, allowingReadAccessTo: _url)
                        return
                    }
                    else{
                        if let _data = NSData.init(contentsOfFile: _path) {
                            self.wkWebview.load(_data as Data, mimeType: "application/pdf", characterEncodingName: "utf-8", baseURL: _url)
                        }
                    }
                }
                else if let _url = URL.init(string: _path.yl_urlEncoded()),_path.yl_isChinese() {
                    weakSelf?.wkWebview.load(URLRequest.init(url: _url))
                }
                else if let _url = URL.init(string: _path),!_path.yl_isChinese() {
                    weakSelf?.wkWebview.load(URLRequest.init(url: _url))
                }
                else{
                    if _path != "" {
                        self.wkWebview.loadHTMLString(_path, baseURL: nil)
                    }
                    else{
                        VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "内容无法识别")
                    }
                }
            }
        }
    }
    
    //MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = VXIUIConfig.shareInstance.appViewControlelrBackgroundColor()
        
        self.view.addSubview(self.navView)
        self.view.addSubview(self.wkWebview)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        VXIUIConfig.shareInstance.appSetNavigationeStyleFor(Hidden: true, andViewController: self)
    }
    
    override func updateViewConstraints() {
       
        if self.view.subviews.contains(self.navView){
            self.navView.snp.makeConstraints { make in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(VXIUIConfig.shareInstance.xp_navigationFullHeight())
            }
        }
        
        super.updateViewConstraints()
    }
    
    //MARK: - lazy laod
    lazy var target: UIViewController? = nil
    
    private lazy var navView:UIView = {
        return TGSUIModel.createDiyNavgationalViewFor(TitleStr: "",
                                                      andDisposeBag: rx.disposeBag) {[weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }()
    
    private lazy var wkWebview: WKWebView = {[unowned self] in
        let webview:WKWebView = WKWebView.init(frame: CGRect(x: 0,
                                                             y: VXIUIConfig.shareInstance.xp_navigationFullHeight(),
                                                             width: VXIUIConfig.shareInstance.YLScreenWidth,
                                                             height: VXIUIConfig.shareInstance.YLScreenHeight - VXIUIConfig.shareInstance.xp_navigationFullHeight() - VXIUIConfig.shareInstance.xp_safeDistanceBottom()),
                                               configuration: self.userConfiguration)
        webview.uiDelegate = self
        webview.navigationDelegate = self
        webview.allowsBackForwardNavigationGestures = true
        let backForwardList: WKBackForwardList = webview.backForwardList
        
        if #available(iOS 11.0, *) {
            webview.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        //进度条
        webview.addSubview(self.progressView)
        
        //监听加载进度
        webview.rx.vxi_estimatedProgress.subscribe {[weak self] (_input:Event<Double>) in
            guard let self = self else { return }
            self.progressView.isHidden = false
            self.progressView.progress = Float(_input.element ?? 0)
            let _p = self.progressView.progress
            if _p >= 1 {
                /*
                 *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
                 *动画时长0.25s，延时0.3s后开始动画
                 *动画结束后将progressView隐藏
                 */
                UIView.animate(withDuration: 0.25,
                               delay: 0.3,
                               options: .curveEaseOut) {
                    self.progressView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                } completion: { (finished:Bool) in
                    self.progressView.isHidden = true
                }
            }
        }.disposed(by: rx.disposeBag)
        
        return webview
    }()

    private lazy var userConfiguration: WKWebViewConfiguration = {[weak self] in
        let _configuration = WKWebViewConfiguration.init()
        
        let prefrence: WKPreferences = WKPreferences.init()
        prefrence.minimumFontSize = 0
        prefrence.javaScriptEnabled = true
        prefrence.javaScriptCanOpenWindowsAutomatically = true
        
        _configuration.preferences = prefrence
        _configuration.allowsInlineMediaPlayback = true
        _configuration.allowsPictureInPictureMediaPlayback = true
        _configuration.mediaTypesRequiringUserActionForPlayback = .all
        
        //_configuration.applicationNameForUserAgent = "ChinaDailyForiPad"
        let weakScriptMessageDelegate = WeakScriptMessageDelegate.init(scriptDelegate: self)
        
        let wkUController: WKUserContentController = WKUserContentController.init()
        if #available(iOS 14.0, *) {
            wkUController.removeAllScriptMessageHandlers()
        } else {
            // Fallback on earlier versions
            wkUController.removeScriptMessageHandler(forName: "jsToOcNoPrams")
            wkUController.removeScriptMessageHandler(forName: "jsToOcWithPrams")
        }
        wkUController.add(weakScriptMessageDelegate, name: "jsToOcNoPrams")
        wkUController.add(weakScriptMessageDelegate, name: "jsToOcWithPrams")
        
        //js代码
        let videos = "var videos = document.getElementsByTagName('video');function pauseVideo(){for(var i=0,len= videos.length;i<len;i++){videos[i].pause();}};var audios = document.getElementsByTagName('audio');function pauseAudio(){for(var i=0,len=audios.length;i<len;i++){ audios[i].pause();}}"
        
        // 注入网页停止播放音乐的js代码
        let pauseJS:WKUserScript = WKUserScript.init(source: videos,
                                                     injectionTime: .atDocumentEnd,
                                                     forMainFrameOnly: true)
        wkUController.addUserScript(pauseJS)
        _configuration.userContentController = wkUController
        
        return _configuration
    }()
    
    /// 进度条
    private lazy var progressView:UIProgressView = {
        let _p = UIProgressView.init(frame: .init(x: 0, y: 0, width: VXIUIConfig.shareInstance.YLScreenWidth, height: 0.3))
        _p.isHidden = true
        _p.tintColor = VXIUIConfig.shareInstance.cellMessageLinkLeftColor()
        return _p
    }()
    
    deinit {
        self.target = nil
        self.pausePlay()
        
        //移除监听
        self.wkWebview.configuration.userContentController.removeAllUserScripts()
        
        print("WebDetailsViewController 已销毁")
    }
 
    //MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("[Webview][didReceive] .name is:\(message.name)")
        print("[Webview][didReceive] .body is:\(message.body)")
    }

}

//MARK: -
extension WebDetailsViewController {
    
    /// 加载地址
    private func loadRequest(path: String) {
        if path.isEmpty { return }
        var urlPath: String = path
        if urlPath.yl_isChinese() {
            urlPath = urlPath.yl_urlEncoded()
        }
        
        var url: URL? = URL(string: urlPath.yl_urlEncoded())
        if url != nil && urlPath.hasPrefix("file://") {
            if #unavailable(iOS 13.0) {
                url = URL.init(fileURLWithPath: urlPath)
                self.wkWebview.loadFileURL(url!, allowingReadAccessTo: url!)
                return
            }
            else{
                if let _data = NSData.init(contentsOfFile: path) {
                    self.wkWebview.load(_data as Data, mimeType: "application/pdf", characterEncodingName: "utf-8", baseURL: url!)
                }
            }
        }
        
        if url != nil {
            let request: URLRequest = URLRequest.init(url: url!)
            self.wkWebview.load(request)
        }
        else{
            debugPrint("loadRequest-\(String(describing: url))")
            VXIUIConfig.shareInstance.keyWindow().showErrInfo(at: "地址不存在")
        }
    }
    
    
    //关闭网页退出视频还在播放的问题
    //https://blog.csdn.net/levebe/article/details/105996359
    func pausePlay(){
        self.wkWebview.evaluateJavaScript("pauseVideo()", completionHandler: nil)
        self.wkWebview.evaluateJavaScript("pauseAudio()", completionHandler: nil)
    }
}


//MARK: - WKNavigationDelegate
extension WebDetailsViewController : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("开始加载网页:\(self.url ?? "--")")
        
        if let _url = self.url, _url.hasSuffix(".pdf") {
            self.webviewScrollContainUpdateCall()
        }
        
        //开始加载网页时展示出progressView
        self.progressView.isHidden = false
        
        //开始加载网页的时候将progressView的Height恢复为1倍
        self.progressView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        //防止progressView被网页挡住
        self.wkWebview.bringSubviewToFront(self.progressView)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("[WebView][load error] error is:\(error)")
        
        //加载完成后隐藏progressView
        self.progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("[WebView][didFail] error is:\(error)")
        
        //加载完成后隐藏progressView
        self.progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.wkViewDidFinishBlock?()
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("didReceiveServerRedirectForProvisionalNavigation")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let _url = navigationAction.request.url
        
        //[S] AppStore Link:
        // https://itunes.apple.com/cn/app/id1529401844?mt=8
        // https://apps.apple.com/cn/app/id1529401844
        if _url?.absoluteString.contains("itunes.apple.com") == true ||
            _url?.absoluteString.contains("apps.apple.com") == true {
            if _url != nil && UIApplication.shared.canOpenURL(_url!) {
                UIApplication.shared.open(_url!, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }
        //[E]
        
        //[S] 拨打电话
        else if _url?.absoluteString.hasPrefix("tel:") == true {
            if UIApplication.shared.canOpenURL(_url!) {
                UIApplication.shared.open(_url!, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }
        //[E]
        
        self.navigationActionPolicyChange?(_url)
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        print("decisionHandler")
    }
    
    @objc private func webviewScrollContainUpdateCall() {
        self.wkWebview.scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        self.wkWebview.evaluateJavaScript("window.scrollTo(0,0)", completionHandler: nil)
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        
    }
    
}


//MARK: - WKUIDelegate
extension WebDetailsViewController : WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController: UIAlertController = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        if self.target != nil {
            self.target?.present(alertController, animated: true, completion: nil)
        }
        else{
            debugPrint("未指定 target")
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController: UIAlertController = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (action) in
            completionHandler(false)
        }))
        alertController.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        if self.target != nil {
            self.target?.present(alertController, animated: true, completion: nil)
        }
        else{
            debugPrint("未指定 target")
        }
        
    }
    
    /**
     * iOS WkWebview不支持 window.open的解决方法
     * https://zhidao.baidu.com/question/1903559282262804060.html
     */
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil && navigationAction.request.url != nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        /*
         NSURLSessionAuthChallengeUseCredential = 0,                     使用证书
         NSURLSessionAuthChallengePerformDefaultHandling = 1,            忽略证书(默认的处理方式)
         NSURLSessionAuthChallengeCancelAuthenticationChallenge = 2,     忽略书证, 并取消这次请求
         NSURLSessionAuthChallengeRejectProtectionSpace = 3,             拒绝当前这一次, 下一次再询问
         */
        let _strUrl = webView.url?.absoluteString
        DispatchQueue.global().async {
            let card = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
            if _strUrl != nil && _strUrl!.hasPrefix("https") {
                completionHandler(URLSession.AuthChallengeDisposition.useCredential,card)
            }
            else{
                completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling,card)
            }
        }
    }
}


//MARK: -
/// WKWebView 扩展
extension Reactive where Base: WKWebView {
    
    var vxi_estimatedProgress: Observable<Double> {
        base.rx
            .observeWeakly(Double.self, #keyPath(WKWebView.estimatedProgress))
            .compactMap { $0 }
    }

}

//MARK: - WeakScriptMessageDelegate
/// WKUserContentController
/// https://juejin.cn/post/6981355574357131272
class WeakScriptMessageDelegate: NSObject {

    //MARK:- 属性设置 之前这个属性没有用weak修饰,所以一直持有,无法释放
    private weak var scriptDelegate: WKScriptMessageHandler?

    //MARK:- 初始化
    convenience init(scriptDelegate: WKScriptMessageHandler?) {
        self.init()
        self.scriptDelegate = scriptDelegate
    }
    
    deinit {
        print("WeakScriptMessageDelegate 已销毁")
    }
}

extension WeakScriptMessageDelegate: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        scriptDelegate?.userContentController(userContentController, didReceive: message)
    }
}
