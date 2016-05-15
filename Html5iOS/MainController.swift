//
//  ViewController.swift
//  Html5iOS
//
//  Created by 刘小杰 on 16/5/13.
//  Copyright © 2016年 刘小杰. All rights reserved.
//

import UIKit

class MainController: UIViewController {

  
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Util.log("Main");
    }
    //当内存不足时
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func button2Event(sender: AnyObject) {
        //参考 http://www.jianshu.com/p/356e4329f562
        //1、实例后跳转(这个跳转后会报错)
        let web = XwebController(url: "http://www.baidu.com",title: "testttt",cookies: ["aaa":1,"bbb":222])
        self.navigationController?.pushViewController(web, animated: true)
        //self.presentViewController(web, animated: true, completion: nil)
        //2、连接好Segue跳转，传参需要重写prepareForSegue
        //self.performSegueWithIdentifier("gotoTest", sender: self)
        //3、当有多个StoryBoard时 可以类比xib的实例对象获取方式
        //var storyboard = UIStoryboard(name: "Other", bundle: nil)
        //var newVC = storyboard.instantiateViewControllerWithIdentifier("NewViewController") as NewViewController
        //presentViewController(newVC, animated: true, completion: nil)
    }

    @IBAction func button3Event(sender: AnyObject) {
        let web = XwebController()
        web.cookies = ["aaa":10000,"_TOKEN":2220000]
        web.loadUrl("index")//http://m.artsbao.com/?c=service&a=index
        self.navigationController?.pushViewController(web, animated: true)
    }
    //StoryBoard连线跳转传参(performSegueWithIdentifier跳转)
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "gotoWeb"){
            //let web = segue.destinationViewController as! WebController
            //web.webUrl = "http://www.baidu.com"
            //web.webUrl = "index"
        }else if(segue.identifier == "gotoTest"){
            Util.log("gotoTest")
        }
        
    }
}

