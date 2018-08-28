//
//  ViewController.swift
//  TouchIDSample
//
//  Created by SRAU Factory on 2018/08/28.
//  Copyright © 2018年 SRAUFactory. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let context = LAContext()
        var error : NSError?
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "サンプル確認のための認証チェック") { (success, failure) in
                if (success) {
                    NSLog("認証成功")
                } else {
                    NSLog("認証失敗：" + failure.debugDescription)
                }
            }
        } else {
            NSLog("TouchID非対応")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

