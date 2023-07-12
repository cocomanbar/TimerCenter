//
//  TimerTaskGroup.swift
//  TimerCenter
//
//  Created by tanxl on 2023/7/11.
//

import UIKit

class TimerTaskGroup: NSObject {
    
    var mode: RunLoop.Mode
    var timeInterval: TimeInterval
    
    var invalidateSelf: ((TimerTaskGroup) -> Void)?
    
    private var asyncTimer: AsyncTimer?
    
    private lazy var listTasks: [TimerTask] = [TimerTask]()
    
    private lazy var locker: NSLock = {
        let lock = NSLock()
        lock.name = "\(Self.self).lock"
        return lock
    }()
    
    /// 虽然没有任务在执行，但是仍需要在第N个定时周期时才置空
    /// 解决类似业务端在刷新数据`手动置空`定时任务`又开启`定时任务的反复创建`性能`问题，hold住N个定时周期基本可以达到无缝连接使用
    private lazy var invalidateCount: Int = 3

    
    init(on thread: PermanentThread?, timeInterval: TimeInterval, mode: RunLoop.Mode) {
        
        self.mode = mode
        self.timeInterval = timeInterval
        
        super.init()
        
        asyncTimer = AsyncTimer(timeInterval: timeInterval, target: self, mode: mode, userInfo: nil, onThread: thread)
        asyncTimer?.executeOnMain = false
        asyncTimer?.timerClosure = { [weak self] timer in
            self?.execute()
        }
    }
    
    func add(_ task: TimerTask) {
        
        lock()
        listTasks.append(task)
        unlock()
    }
    
    func remove(_ task: TimerTask) {
        
        lock()
        listTasks.removeAll { item in
            if item == task {
                task.invalidate()
                return true
            }
            return false
        }
        unlock()
    }
    
    func lookup(_ identifier: String?) -> TimerTask? {
        guard let identifier = identifier else { return nil }
        lock()
        let result = listTasks.filter({ $0.identifier == identifier })
        unlock()
        return result.first
    }
    
    func execute() {
        
        var invalid = false
        
        lock()
        let valids = listTasks.filter({ $0.target != nil })
        if valids.isEmpty {
            invalid = true
        } else {
            valids.forEach({ $0.execute() })
        }
        listTasks.removeAll()
        listTasks.append(contentsOf: valids)
        unlock()
        
        if invalid {
            invalidate()
        }
    }
    
    func invalidate() {
        
        asyncTimer?.invalidateTimer()
        asyncTimer = nil
        invalidateSelf?(self)
    }
    
    deinit {
        debugPrint("TimerTaskGroup deinit!")
    }
}

extension TimerTaskGroup: NSLocking {
    
    func lock() {
        locker.lock()
    }
    
    func unlock() {
        locker.unlock()
    }
}
