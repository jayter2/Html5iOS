//
//  TestController.swift
//  Html5iOS
//
//  Created by 刘小杰 on 16/5/13.
//  Copyright © 2016年 刘小杰. All rights reserved.
//

import UIKit

class TestController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        Util.log("Test")
    }
    //当内存不足时
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        Util.log("didReceiveMemoryWarning");
        
        // Dispose of any resources that can be recreated.
    }
}
