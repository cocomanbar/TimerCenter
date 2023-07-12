//
//  SingleViewController.swift
//  TimerCenter_Example
//
//  Created by tanxl on 2023/7/12.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import TimerCenter

class SingleViewController: UIViewController {
    
    // proxy = self
    var asyncTimer1: AsyncTimer?
    
    // proxy = aProperty
    var asyncTimer2: AsyncTimer?
    var timeLocalProxy: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // 1.定时器跟随self生命周期
        asyncTimer1 = AsyncTimer(timeInterval: 1, target: self)
        asyncTimer1?.executeOnMain = true
        asyncTimer1?.timerClosure = { timer in
            print("asyncTimer1 ~")
        }
        
        // 2.定时器跟随timeLocalProxy生命周期
        timeLocalProxy = UIView()
        asyncTimer2 = AsyncTimer(timeInterval: 1, target: timeLocalProxy!)
        asyncTimer2?.executeOnMain = true
        asyncTimer2?.timerClosure = { timer in
            print("asyncTimer2 ~")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 1.手动置空
        asyncTimer1?.invalidateTimer()
        
        // 2.置空宿主
        timeLocalProxy = nil
        
    }
    
}
