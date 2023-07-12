//
//  AsyncTimer.swift
//  TimerCenter
//
//  Created by tanxl on 2023/7/11.
//

import UIKit

/// 定时器的封装，可单独使用，宿主释放随之释放
/// 页面内如有需求销毁`AsyncTimer`旧实例重新构造新实例，旧实例务必执行`invalidateTimer`

public class AsyncTimer: NSObject {
    
    /// 回调线程，默认主程
    public var executeOnMain: Bool = true
    
    /// 定时器周期回调
    public var timerClosure: ((Timer?) -> Void)?
    
    private var timer: Timer?
    private var weakProxy: TimerProxy?
    private var timeInterval: TimeInterval
    private var mode: RunLoop.Mode
    private var userInfo: Any?
    private var innerThread: PermanentThread?
    
    public static func scheduledTimer(timeInterval: TimeInterval,
                                      target: AnyObject,
                                      mode: RunLoop.Mode = .common,
                                      userInfo: Any? = nil,
                                      onThread: PermanentThread? = nil) -> AsyncTimer {
        AsyncTimer(timeInterval: timeInterval, target: target, mode: mode, userInfo: userInfo, onThread: onThread)
    }
    
    public init(timeInterval: TimeInterval,
                target: AnyObject,
                mode: RunLoop.Mode = .common,
                userInfo: Any? = nil,
                onThread: PermanentThread? = nil) {
        
        self.timeInterval = timeInterval
        self.mode = mode
        self.userInfo = userInfo
        super.init()
        
        weakProxy = TimerProxy(proxy: target)
        weakProxy?.invalidateWhenWeakProxy = true
        weakProxy?.validClosure = { [weak self] timer in
            guard let self = self else { return }
            if self.executeOnMain {
                DispatchQueue.main.async {
                    self.timerClosure?(timer)
                }
            } else {
                self.timerClosure?(timer)
            }
        }
        weakProxy?.inValidClosure = { [weak self] timer in
            guard let self = self else { return }
            self.innerThread?.stop()
        }
        
        let makeThread: (() -> Void) = {
            self.innerThread = PermanentThread("AsyncTimer Thread", run: { [weak self] in
                guard let self = self else { return }
                self.makeTimeRuner()
            })
        }
        
        if let thread = onThread {
            if !thread.isValid() {
                assertionFailure("Debug线程状态错误！")
                makeThread()
            } else {
                thread.performTask {
                    self.makeTimeRuner()
                }
            }
        } else {
            makeThread()
        }
    }
    
    private func makeTimeRuner() {
        self.timer = Timer(timeInterval: timeInterval,
                           target: weakProxy as Any,
                           selector: #selector(TimerProxy.timeCountDown(_:)),
                           userInfo: userInfo,
                           repeats: true)
        DispatchQueue.main.async {
            RunLoop.current.add(self.timer!, forMode: self.mode)
        }
    }
    
    /// 定时器工作状态
    public func isValid() -> Bool {
        weakProxy?.isValid() ?? false
    }
    
    /// 手动销毁`AsyncTimer`实例前需要调用
    public func invalidateTimer() {
        weakProxy?.invalidate()
    }
    
    deinit {
        invalidateTimer()
        innerThread?.stop()
        debugPrint("AsyncTimer deinit!")
    }
}
