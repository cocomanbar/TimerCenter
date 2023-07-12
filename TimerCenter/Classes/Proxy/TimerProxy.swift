//
//  TimerProxy.swift
//  TimerCenter
//
//  Created by tanxl on 2023/7/11.
//

import UIKit

public class TimerProxy: PureProxy {
    
    /// 定时器回调，同步定时器执行次数
    public var validClosure: ((Timer?) -> Void)?
    
    /// 宿主置空后，如果定时器还在工作就会回调一次
    public var inValidClosure: ((Timer?) -> Void)?
    
    /// 检测到宿主置空，是否主动将定时器设置成无效状态
    public var invalidateWhenWeakProxy: Bool = false
    
    @objc open func timeCountDown(_ timer: Timer) {
        if proxy == nil {
            if invalidateWhenWeakProxy, timer.isValid {
                timer.invalidate()
            }
            inValidClosure?(timer)
            inValidClosure = nil
            return
        }
        validClosure?(timer)
    }
    
    deinit {
        debugPrint("TimerProxy deinit!")
    }
}
