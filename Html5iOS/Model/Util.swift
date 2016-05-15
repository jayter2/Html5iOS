//
//  Util.swift
//  Html5iOS
//
//  Created by 刘小杰 on 16/5/13.
//  Copyright © 2016年 刘小杰. All rights reserved.
//

import UIKit

class Util:NSObject{
    static let bundleDict = NSBundle.mainBundle().infoDictionary
    ///日志输出
    static func log(str:Any...,err:Bool=false){
        if(err){
            NSLog("xxx\(str)")
        }else{
            NSLog(">>>\(str)")
        }
    }
    ///获取本地Html,JS,css文件路径
    static func getPath(name:String,ext:String="html",dir:String="Html")->String?{
        return NSBundle.mainBundle().pathForResource(name, ofType:ext , inDirectory:dir)
    }
    ///获取本地Html,JS,css文件内容
    static func getContents(name:String,ext:String="js",dir:String="Html")->String?{
        if let path = Util.getPath(name,ext: ext,dir: dir) {
            do {
                return try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            } catch let error as NSError {
                Util.log("Util.getContent",error.debugDescription)
            }
        }
        return ""
    }
    ///获得版本号
    ///version=APP版本,bundle=版本,system=系统版本,udid
    static func getVersion(key:String="version")->String{
        if(key=="version"){
            return bundleDict!["CFBundleShortVersionString"] as! String
        }else if(key=="bundle"){
            return bundleDict!["CFBundleVersion"] as! String
        }else if(key=="system"){
            return UIDevice.currentDevice().systemVersion
        }else if(key=="udid"){
            //return UIDevice.currentDevice().identifierForVendor as String
        }
        return ""
    }
    ///URL字符串转字典
    static func urlParse(querystring: String) -> [String: String] {
        var query = [String: String]()
        for qs in querystring.componentsSeparatedByString("&") {
            let key = qs.componentsSeparatedByString("=")[0]
            var value = qs.componentsSeparatedByString("=")[1]
            value = value.stringByReplacingOccurrencesOfString("+", withString: " ")
            value = value.stringByRemovingPercentEncoding!
            query[key] = value
        }
        
        return query
    }
    
}