//
//  ListViewController.swift
//  TimerCenter_Example
//
//  Created by tanxl on 2023/7/12.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import TimerCenter

class ListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "查询", style: .plain, target: self, action: #selector(lookup))
        
        var task = TimerTask(timeInterval: 1, target: self, mode: .default)
        task.timerClosure = { userInfo in
            print("1 ~")
        }
        TimerCenter.default.add(task)
        
        
        task = TimerTask(timeInterval: 2, target: self, mode: .default)
        task.timerClosure = { userInfo in
            print("2 ~")
        }
        TimerCenter.default.add(task)
        
        
        task = TimerTask(timeInterval: 3, target: self, mode: .default)
        task.timerClosure = { userInfo in
            print("3 ~")
        }
        TimerCenter.default.add(task)
    }
        
    @objc func lookup() {
        
        print("当前工作：count = \(TimerCenter.default.counts())")
    }
}
