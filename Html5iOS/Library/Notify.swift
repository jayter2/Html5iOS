//
//  Notification.swift
//  Html5iOS
//
//  Created by 刘小杰 on 16/5/14.
//  Copyright © 2016年 刘小杰. All rights reserved.
//

import UIKit
class Notify{
    /**推送一条本地通知（在AppDelegate注册）
     if #available(iOS 8.0, *) {
        let uns = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(uns)
     }
     */
    static func add(body:String,dict:[String : AnyObject]=[:],alert:String="打开应用")->String {
        let dicts:[String : AnyObject]?
        let localNoti = UILocalNotification()
        if(dict.count>0){
            dicts = dict
        }else{
            dicts = ["id":"1"]
        }
        // 通知的触发时间，例如即刻起15分钟后
        //let fireDate = NSDate().dateByAddingTimeInterval(-15*60)
        //localNoti.fireDate = fireDate
        localNoti.timeZone = NSTimeZone.defaultTimeZone()
        // 通知上显示的主题内容
        localNoti.alertBody = body
        // 收到通知时播放的声音，默认消息声音
        localNoti.soundName = UILocalNotificationDefaultSoundName
        //待机界面的滑动动作提示
        localNoti.alertAction = alert
        // 应用程序图标右上角显示的消息数
        localNoti.applicationIconBadgeNumber = 1
        // 通知上绑定的其他信息，为键值对
        localNoti.userInfo = dicts
        // 添加通知到系统队列中，系统会在指定的时间触发
        UIApplication.sharedApplication().scheduleLocalNotification(localNoti)
        return dicts!["id"] as! String
    }
    /**获取本地所有通知*/
    static func getAll()->[UILocalNotification]{
        return UIApplication.sharedApplication().scheduledLocalNotifications!
    }
    /**取消一条本地通知*/
    static func delete(id: String){
        if id.isEmpty {
            return
        }
        if let locals = UIApplication.sharedApplication().scheduledLocalNotifications {
            for localNoti in locals {
                if let dict = localNoti.userInfo {
                    if dict.keys.contains("id") && dict["id"] is String && (dict["id"] as! String) == id {
                        UIApplication.sharedApplication().cancelLocalNotification(localNoti)
                    }
                }
            }
        }
    }
    /**点击本地通知后（在AppDelegate添加）
     func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if let dict = notification.userInfo {
            Notify.click(dict)
            return
        }
        // 后面作相应处理...
     }
     */
    static func click(dict:[NSObject : AnyObject]){
        if(dict.keys.contains("id")){
            delete(dict["id"] as! String)
            Util.log("Notify.click",dict)
        }
    }
    
    
}