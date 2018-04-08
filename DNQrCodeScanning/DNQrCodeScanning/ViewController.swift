//
//  ViewController.swift
//  DNQrCodeScanning
//
//  Created by mainone on 16/10/12.
//  Copyright © 2016年 wjn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func ScanClick(_ sender: UIButton) {
        let scanVC = ScanQRViewController()
        self.navigationController?.pushViewController(scanVC, animated: true)
    }
    
    
    @IBAction func CreateClick(_ sender: UIButton) {
        let myQrVC = MyQRViewController()
        self.navigationController?.pushViewController(myQrVC, animated: true)
    }
    
    @IBAction func ReadClick(_ sender: UIButton) {
        let readQrVC = ReadQRViewController()
        self.navigationController?.pushViewController(readQrVC, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

