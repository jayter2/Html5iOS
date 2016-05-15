//
//  WebView.swift
//  Html5iOS
//
//  Created by 刘小杰 on 16/5/13.
//  Copyright © 2016年 刘小杰. All rights reserved.
//

import UIKit
import WebKit
///WKUIDelegate代理负责JS
///https://lvwenhan.com/ios/462.html
class XwebView: WKWebView,WKUIDelegate {
    internal var url:NSURL?
    weak var controller: XwebController? //weak引用
    required init(control:XwebController,configuration config: WKWebViewConfiguration) {
        super.init(frame: control.view.frame,configuration: config)
        self.UIDelegate = self
        self.controller = control
        config.preferences.minimumFontSize = 10
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = false //默认JS不自动打开窗口,必须通过交互
        //window.webkit.messageHandlers.XwebBridge.postMessage({body: 'xxx'})
        config.userContentController.addScriptMessageHandler(XwebScriptHandler(control: controller!), name: "XwebBridge")
        //加载完成后调用xwebReady
        let script = WKUserScript(source:";xwebReady();",injectionTime: .AtDocumentEnd,forMainFrameOnly: true)
        config.userContentController.addUserScript(script)
        //将Xwb/Xweb.js注入WebView实现XwebBridge
        self.runJS(["Xweb"]);
        Util.log("XwebView.init","XwebBridge")
    }
    ///加载URL
    func loadURL(urlString: String,cookies: [String: AnyObject]=[:]) {
        if(urlString.hasPrefix("http://")){
            self.url = NSURL(string:urlString)!
            if(cookies.count>0){
                self.setCookies(self.url!, cookies: cookies)
            }
        }else if(urlString.hasPrefix("file://")){
            self.url = NSURL(string: urlString)
        }else{
            self.url = NSBundle.mainBundle().URLForResource(urlString, withExtension: "html",subdirectory:"Html")
        }
        Util.log("XwebView.loadURL:",url?.absoluteURL);
        if(self.url != nil){
            let request = NSURLRequest(URL: self.url!)
            //super.customUserAgent = request.valueForHTTPHeaderField("User-Agent")!+" aaa"
            super.loadRequest(request)
        }
    }
    ///HTML中JS的alert()回调此API
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        let alert = UIAlertController(title: "提示信息", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (_) -> Void in
            // We must call back js
            completionHandler()
        }))
        controller!.presentViewController(alert, animated: true, completion: nil)
    }
    ///HTML中JS的confirm()回调此API
    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
        let alert = UIAlertController(title: "提示信息", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (_) -> Void in
            // 点击完成后，可以做相应处理，最后再回调js端
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (_) -> Void in
            // 点击取消后，可以做相应处理，最后再回调js端
            completionHandler(false)
        }))
        controller!.presentViewController(alert, animated: true, completion: nil)
    }
    ///HTML中JS的prompt()回调此API
    func webView(webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: (String?) -> Void) {
        let alert = UIAlertController(title: prompt, message: defaultText, preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.textColor = UIColor.blackColor()
        }
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (_) -> Void in
            // 处理好之前，将值传到js端
            completionHandler(alert.textFields![0].text!)
        }))
        controller!.presentViewController(alert, animated: true, completion: nil)
    }
    

    
    
    
    
    
    
    
    
   
    
    
    ///设置cookie，本地文件会设置失败
    private func setCookies(url:NSURL,cookies: [String: AnyObject]) {
        self.url = url
        var httpCookies = [NSHTTPCookie]()
        for cookie in cookies {
            var cookiesObj = [String: AnyObject]()
            cookiesObj[NSHTTPCookieName] = cookie.0       // cookie名称
            cookiesObj[NSHTTPCookieValue] = "\(cookie.1)" // NSHTTPCookieName对应的value
            cookiesObj[NSHTTPCookieDomain] = self.url!.host       // 有效域名
            cookiesObj[NSHTTPCookiePath] = self.url!.path         // 路径
            // 创建并添加cookie
            if let _cookie = NSHTTPCookie(properties: cookiesObj) {
                httpCookies.append(_cookie)
            }
        }
        // 绑定cookie到url
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(httpCookies, forURL: self.url, mainDocumentURL: nil)
        Util.log("XwebView.setCookies:",httpCookies);
    }
    func runJS(names: Array<String>) {
        for name in names {
            if let content = Util.getContents(name,ext: "js",dir: "Xweb") {
                super.evaluateJavaScript(content, completionHandler:nil)
            }
        }
    }
}
///处理postMessage信息，JS交互反射代理
class XwebScriptHandler: NSObject, WKScriptMessageHandler {
    weak var controller:XwebController? = nil //weak引用
    required init(control:XwebController) {
        self.controller = control
    }
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        
        let body = message.body as! NSDictionary
        Util.log("XwebScriptHandler",body)
        if (body.count>0){
            let className = body["class"]?.description
            let methodName = body["method"]?.description
            if let cls = NSClassFromString(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")!.description + "." + className!) as? XwebPlugin.Type{
                let obj = cls.init(control:  controller!)
                obj.taskid = body["taskid"]?.integerValue
                obj.data = body["data"] as! NSDictionary
                let funcSelector = Selector(methodName!)
                if obj.respondsToSelector(funcSelector) {
                    obj.performSelector(funcSelector)
                } else {
                    Util.log("XwebScriptHandler: method=\(methodName)方法未找到！")
                }
            }else{
                Util.log("XwebScriptHandler: class=\(className)类未找到！")
            }

        }
    }
}

