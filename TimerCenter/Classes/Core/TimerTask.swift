//
//  TimerTask.swift
//  TimerCenter
//
//  Created by tanxl on 2023/7/11.
//

import UIKit

/// 定时任务  
public class TimerTask: NSObject {
    
    /// 定时回调在主程
    public var executeOnMain: Bool = true
    
    /// 定时回调
    public var timerClosure: ((_ userInfo: Any?) -> Void)?
    
    /// 绑定id（不查重）
    public var identifier: String?
    
    /// 定位任务耗时（DEBUG）
    public var debugRunTime: Bool = false
    
    private(set) var timeInterval: TimeInterval
    private(set) weak var target: AnyObject?
    private(set) var mode: RunLoop.Mode
    private(set) var userInfo: Any?
    
    public static func scheduledTimer(timeInterval: TimeInterval,
                                      target: AnyObject,
                                      mode: RunLoop.Mode = .default,
                                      userInfo: Any? = nil) -> TimerTask {
        TimerTask(timeInterval: timeInterval, target: target, mode: mode, userInfo: userInfo)
    }
    
    public init(timeInterval: TimeInterval,
                target: AnyObject,
                mode: RunLoop.Mode = .default,
                userInfo: Any? = nil) {
        
        self.mode = mode
        self.target = target
        self.userInfo = userInfo
        self.timeInterval = timeInterval
        
        super.init()
    }
    
    func execute() {
        if target == nil {
            return
        }
        
        let closure = {
            #if DEBUG
            if self.debugRunTime {
                let startTime = CFAbsoluteTimeGetCurrent()
                self.timerClosure?(self.userInfo)
                let executionTime = CFAbsoluteTimeGetCurrent() - startTime
                debugPrint("TimerTask(id=\(self.identifier ?? "")) Execution time: \(executionTime * 1000) milliseconds")
            } else {
                self.timerClosure?(self.userInfo)
            }
            #else
            self.timerClosure?(self.userInfo)
            #endif
        }
        
        if executeOnMain {
            DispatchQueue.main.async {
                closure()
            }
        } else {
            closure()
        }
    }
    
    public func invalidate() {
        target = nil
    }
    
    deinit {
        debugPrint("TimerTask deinit! id：\(identifier ?? "")")
    }
}
