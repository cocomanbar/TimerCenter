//
//  PureProxy.swift
//  TimerCenter
//
//  Created by tanxl on 2023/7/11.
//

import UIKit

open class PureProxy: NSObject {
    
    public private(set) weak var proxy: AnyObject?
    
    public init(proxy: AnyObject? = nil) {
        self.proxy = proxy
    }
    
    open func isValid() -> Bool {
        proxy != nil
    }
    
    open func invalidate() {
        proxy = nil
    }
    
    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if let proxy = proxy, proxy.responds(to: aSelector) {
            return proxy
        }
        debugPrint("can't responds aSelector = \(String(describing: aSelector))")
        return nil
    }
    
    deinit {
        debugPrint("PureProxy deinit!")
    }
}
