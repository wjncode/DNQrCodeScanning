//
//  ReadQRViewController.swift
//  DNQrCodeScanning
//
//  Created by mainone on 16/10/14.
//  Copyright © 2016年 wjn. All rights reserved.
//

import UIKit

class ReadQRViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let image = UIImage(named: "5")
        DispatchQueue.global().async {
            let recognizeResult = image?.recognizeQRCode()
            
            let str = recognizeResult ?? "无法判断"
            print(str)

            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
