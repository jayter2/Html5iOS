//
//  WebController.swift
//  Html5iOS
//
//  Created by 刘小杰 on 16/5/13.
//  Copyright © 2016年 刘小杰. All rights reserved.
//


import UIKit
import WebKit
import JavaScriptCore

///HTML5交互XwebView
///http://www.jb51.net/article/82610.htm
///http://blog.csdn.net/woaifen3344/article/details/49452227
class XwebController: UIViewController,WKNavigationDelegate {
    private var _navTitle:String = ""
    private var _loadUrl:String = ""
    private var _cookies:[String:AnyObject] = [:]
    var webView:XwebView?

    
    
    
    ///设置或获取标题
    var navTitle:String{
        get {
            return self._navTitle
        }
        set(val) {
            self._navTitle = val
            self.navigationItem.title = val
        }
    }
    ///设置或获得cookie
    var cookies:[String:AnyObject]{
        get{ return self._cookies }
        set(val) {
            self._cookies = val
        }
    }
    
    init(title:String = "",url: String="",cookies:[String:AnyObject]=[:]) {
        super.init(nibName:nil, bundle:nil)
        self.navTitle = title
        self._loadUrl = url
        self._cookies = cookies
        self.webView = XwebView(control: self,configuration: WKWebViewConfiguration())
        //var agent = webView.stringByEvaluatingJavaScriptFromString("navigator.userAgent")
        //agent = agent!+" Xweb/"+Util.getVersion()
        //NSUserDefaults.standardUserDefaults().registerDefaults(["UserAgent":agent!])
        if(!url.isEmpty){
            self.loadUrl()
        }
        self.initView()
        Util.log("XwebController.init")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("XwebController.init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        Util.log("viewDidLoad")
    }
    ///加载URL
    func loadUrl(url: String="",title:String = "",cookies:[String:AnyObject]=[:]) {
        if(!url.isEmpty){
            self._loadUrl = url
        }
        if(!title.isEmpty){
            self._navTitle = title
        }
        if(cookies.count>0){
            self._cookies = cookies
        }
        if(!self._loadUrl.isEmpty){
            self.webView!.loadURL(self._loadUrl,cookies: self._cookies)
        }else{
            Util.log("loadUrl:url is empty!")
        }
    }
    ///初始化视图
    private func initView() {
        //let rect:CGRect = self.view.frame
        //上下留点距离
        //self.webView.frame = CGRectMake(0, 65, self.view.bounds.width, self.view.bounds.height - 65 - 50)
        self.webView!.frame = self.view.frame
        self.view.addSubview(self.webView!)
        self.webView!.navigationDelegate = self
        self.webView!.allowsBackForwardNavigationGestures = true
        //self.webView.scrollView.bounces = false //上下弹动 关闭
        //self.webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        //self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        
    }
    ///当内存不足时
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        Util.log("XwebController.didReceiveMemoryWarning");
        
        // Dispose of any resources that can be recreated.
    }
    ///开始加载
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Util.log("XwebController.webView start")
        
        
    }
    ///加载完成
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        Util.log("XwebController.webView finish")
        self.navTitle = self.webView!.title!
    }
    ///提交加载出错
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        Util.log("XwebController.webView fail1")
        
    }
    ///加载失败,错误发生时
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        Util.log("XwebController.webView fail2")
    }
    ///内容返回
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        
    }
    ///监听进度等
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        Util.log("KeyPath",keyPath)
        if (keyPath == "loading") {
            Util.log("KeyPath loading")
        } else if keyPath == "estimatedProgress" {
            print(webView!.estimatedProgress)
            Util.log("KeyPath progress",webView!.estimatedProgress)
            //self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
        
    }
    
    ///发送跳转请求之前
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        let urls = navigationAction.request.URL
        let scheme = urls?.scheme
        let host = urls?.host
        let query = urls?.query
        Util.log("XwebController.webView policy",scheme,host,query)
        if (urls!.absoluteString.hasPrefix("xweb://") && query!.isEmpty) {
            self.JSbridge(host!,query: query!);
            decisionHandler(WKNavigationActionPolicy.Cancel) //不加会报错
        } else {
            //self.loadUrl(urls!.absoluteString)
            decisionHandler(WKNavigationActionPolicy.Allow) //不加会报错
        }
        
    }
    
    
    
    
    
    

    ///解析xweb://协议
    func JSbridge(host:String,query:String)  {
        Util.log("XwebController.JSbridge: xweb://"+host+"?"+query)
        let queryStrings = Util.urlParse(query)
        switch host {
        case "call"://  xweb://call?method=setTitle&title=xxxx
            JSbridgeCall(queryStrings)
            break
        case "open"://  xweb://open?title=x&url=xxx
            let url = queryStrings["url"]
            if (!url!.isEmpty) {
                let web = XwebController(title: queryStrings["title"]!,url: url!)
                self.navigationController?.pushViewController(web, animated: true)
            }
            let title = queryStrings["title"]
            if (!title!.isEmpty) {
                self.navTitle = title!
            }
            break
        default:
            
            break
        }
        
    }
    ///JS调用内置方法
    func JSbridgeCall(queryStrings:[String: String])  {
        let method:String = queryStrings["method"]!
        switch method {
        case "setTitle"://  xweb://call?method=setTitle&title=xxxx
            self.navTitle = queryStrings["title"]!
            break
        case "close"://  xweb://call?method=close
            self.navigationController?.popViewControllerAnimated(true)
        case "login":
            Util.log("JSbridgeCall:login")
            break
        default:
            Util.log("JSbridgeCall:"+method)
            break
        }
    }
    
}
