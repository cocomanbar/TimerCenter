//
//  PermanentThread.swift
//  TimerCenter
//
//  Created by tanxl on 2023/7/11.
//

import Foundation

// MARK: - 常驻线程
public class PermanentThread: NSObject {
    
    private var thread: Thread?
    private var condition: NSCondition = NSCondition()
    private var shouldKeepRunning: Bool = true
    private var closure: (() -> Void)?
    
    public init(_ name: String?, run: (() -> Void)?) {
        super.init()
        
        closure = run
        thread = Thread(target: self, selector: #selector(runLoop), object: nil)
        thread?.name = name
        thread?.start()
    }
    
    /// 关闭常驻线程
    /// 通过Xcode运行面板直观了解运行状态
    public func stop() {
        if !shouldKeepRunning {
            return
        }
        shouldKeepRunning = false
        performTask {}
    }
    
    /// 线程是否有效
    public func isValid() -> Bool {
        shouldKeepRunning
    }
    
    @objc private func runLoop() {
        while shouldKeepRunning {
            condition.lock()
            closure?()
            condition.wait()
            condition.unlock()
        }
    }
    
    /// 线程执行任务
    public func performTask(_ task: @escaping () -> Void) {
        condition.lock()
        task()
        condition.signal()
        condition.unlock()
    }
    
    deinit {
        debugPrint("PermanentThread deinit!")
    }
}
