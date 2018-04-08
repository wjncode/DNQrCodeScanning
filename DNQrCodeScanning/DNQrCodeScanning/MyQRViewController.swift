//
//  MyQRViewController.swift
//  DNQrCodeScanning
//
//  Created by mainone on 16/10/13.
//  Copyright © 2016年 wjn. All rights reserved.
//

import UIKit

class MyQRViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let url = "http://www.baidu.com"
        let image = url.generateQRCode()
        let imageV = UIImageView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        imageV.backgroundColor = UIColor.yellow
        imageV.image = image
        self.view.addSubview(imageV)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
