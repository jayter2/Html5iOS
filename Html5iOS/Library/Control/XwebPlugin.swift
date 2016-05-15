//
//  XwebCallBack.swift
//  Html5iOS
//
//  Created by 刘小杰 on 16/5/15.
//  Copyright © 2016年 刘小杰. All rights reserved.
//
import UIKit
///XwebPlugin插件基类
class XwebPlugin:NSObject {
    weak var controller:XwebController! //weak引用
    var taskid: Int!
    var data:NSDictionary = [:]
    required init(control:XwebController) {
        self.controller = control
    }
    func onSuccess(values: NSDictionary) -> Bool {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(values, options: NSJSONWritingOptions())
            if let jsonStr = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as? String {
                let js = "_XwebOnSuccess(\(self.taskid), '\(jsonStr)');"
                self.controller.webView!.evaluateJavaScript(js, completionHandler: nil)
                Util.log("XwebPlugin.onSuccess",jsonStr)
                return true
            }
        } catch let error as NSError{
            Util.log("XwebPlugin.onSuccess","error",error.debugDescription)
            return false
        }
        return false
    }
    func onError(message: String) {
        let js = "_XwebOnError(\(self.taskid), '\(message)');"
        self.controller.webView!.evaluateJavaScript(js, completionHandler: nil)
        Util.log("XwebPlugin.onError",message)
    }
    
    
    
    /// JS打开窗体XwebBridge.call('open',{url:'http://www.xwebcms.com'})
    func open() {
        Util.log("XwebScriptHandler.open",data)
        let url:String = (data["url"]?.description)!
        if (!url.isEmpty) {
            let web = XwebController(url: url)
            web.loadUrl(url,title: "",cookies: (controller?.cookies)!)
            controller!.navigationController?.pushViewController(web, animated: true)
            self.onSuccess([:])
        }else{
            self.onError("open: url is empty!")
        }
        
    }
    ///本地通知XwebBridge.call('notify',{body:'testssssss'})
    func notify(){
        Util.log("XwebScriptHandler.notify",data)
        let id = Notify.add((data["body"]?.description)!)
        self.onSuccess(["id":id])
    }
    ///JS关闭窗体XwebBridge.call('close')
    func close(){
        Util.log("XwebScriptHandler.close")
        controller!.navigationController?.popViewControllerAnimated(true)
    }
    ///JS调试
    func log(){
        NSLog("console.log>>>"+(data["log"]?.description)!)
    }
}
