//
//  TimerCenter.swift
//  TimerCenter
//
//  Created by tanxl on 2023/7/11.
//

import UIKit

public class TimerCenter: NSObject {

    public static let `default` = TimerCenter()
    
    private override init() {
        super.init()
    }
    
    @discardableResult
    public func add(_ task: TimerTask?) -> Bool {
        guard let task = task else { return false }
        lock()
        if thread == nil {
            thread = PermanentThread("TimerCenter Thread", run: {})
        }
        if let group = search(task.timeInterval, mode: task.mode) {
            group.add(task)
        } else {
            insert(task)
        }
        unlock()
        return true
    }
    
    public func remove(_ task: TimerTask?) {
        guard let task = task else { return }
        lock()
        if let group = search(task.timeInterval, mode: task.mode) {
            group.remove(task)
        }
        unlock()
    }
    
    public func lookup(_ taskId: String?) -> TimerTask? {
        var aTask: TimerTask?
        guard let taskId = taskId else { return aTask }
        lock()
        for group in listGroups {
            if let task = group.lookup(taskId) {
                aTask = task
                break
            }
        }
        unlock()
        return aTask
    }
    
    public func counts() -> Int {
        lock()
        let count = listGroups.count
        unlock()
        return count
    }
    
    // MARK: - Lazy Load
    
    private var thread: PermanentThread?
    
    private lazy var listGroups: [TimerTaskGroup] = {
        [TimerTaskGroup]()
    }()
    
    private lazy var locker: NSLock = {
        let lock = NSLock()
        lock.name = "\(Self.self).lock"
        return lock
    }()
}

extension TimerCenter {
    
    /// 查找出合适的定时组
    private func search(_ timeInterval: TimeInterval, mode: RunLoop.Mode) -> TimerTaskGroup? {
        let result = listGroups.filter({ ($0.timeInterval == timeInterval) && ($0.mode == mode) })
        return result.first
    }
    
    /// 插入合适的定时组
    private func insert(_ task: TimerTask) {
        let group = TimerTaskGroup(on: thread, timeInterval: task.timeInterval, mode: task.mode)
        group.invalidateSelf = { group in
            self.removeGroup(group)
        }
        listGroups.append(group)
        group.add(task)
    }
    
    private func removeGroup(_ group: TimerTaskGroup) {
        self.lock()
        let groups = self.listGroups.filter({ $0 != group })
        self.listGroups.removeAll()
        self.listGroups.append(contentsOf: groups)
        if groups.isEmpty {
            thread?.stop()
            thread = nil
        }
        self.unlock()
    }
}


extension TimerCenter: NSLocking {
    
    public func lock() {
        locker.lock()
    }
    
    public func unlock() {
        locker.unlock()
    }
}
