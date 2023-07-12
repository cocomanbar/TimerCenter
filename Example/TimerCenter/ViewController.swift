//
//  ViewController.swift
//  TimerCenter
//
//  Created by cocomanbar on 07/12/2023.
//  Copyright (c) 2023 cocomanbar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // SingleViewController
        // ListViewController
        let controller = ListViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}

