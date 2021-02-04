//
//  TimerUtil.swift
//  XZFoundation
//
//  Created by xzh on 2020/9/13.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

public typealias TimerHandlerClosure = (String, String, String, String, String)->Void

enum TimerStatu {
    case idle, resume, suspend
}

class Timer {
    // 定时器
    var timer: DispatchSourceTimer
    // 定时器运行时长
    var runDuration: TimeInterval = 0
    // 定时器任务间隔时间
    var interval: TimeInterval = 0
    // 定时器状态
    var statu: TimerStatu = .idle
    // 定时器开始时间
    var startTime: TimeInterval = 0
    init(timer: DispatchSourceTimer) {
        self.timer = timer
    }
}

public class XZTimerUtil{
    public static let shared = XZTimerUtil()
    private var timerContaier: [String: Timer] = [String: Timer]()
    private var semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    private var currentIdentifier: String?
    private init(){}
    
    public func scheduledTimer(identifier: String?=nil, start: TimeInterval, interval: TimeInterval, queue: DispatchQueue?=nil, repeatFlag: Bool=false, increase: Bool = false, handler: TimerHandlerClosure?=nil, task: VoidClosure?=nil, finished: VoidClosure?=nil, cancel: VoidClosure?=nil){
        var timerName: String = "timer-\(timerContaier.count)"
        
        if let tempName = identifier { timerName = tempName }
        
        // 销毁已存在同identifier定时器
        stopTimer(identifier: timerName)
        
        var startTime: TimeInterval = start
        if start < 0 { startTime = 0.0 }
        formateTime(time: startTime, handler: handler)
        
        if let tempHandler = handler {
            formateTime(time: startTime, handler: tempHandler)
        }
        
        var timeInterval: TimeInterval = interval
        if interval <= 0 { timeInterval = 0.001 }
        
        var timerQueue = DispatchQueue.global()
        if let tempQueue = queue { timerQueue = tempQueue }
        
        
        let timer: Timer = Timer(timer: DispatchSource.makeTimerSource(flags: [], queue: timerQueue))
        timer.interval = interval
        timer.startTime = startTime
        
        // 多线程字典访问
        semaphore.wait()
        self.timerContaier[timerName] = timer
        semaphore.signal()
        
        // 添加计时器
        timer.timer.schedule(wallDeadline: .now(), repeating: .milliseconds(Int(timeInterval)), leeway: .milliseconds(10))
        
        // 设置事件处理
        timer.timer.setEventHandler {[weak self] in
            timer.runDuration += interval
            task?()
            if increase{
                startTime += interval
            }else{
                startTime -= interval
                if startTime <= 0 {// 定时完成、移除
                    finished?()
                    self?.stopTimer(identifier: timerName)
                }
            }
            self?.formateTime(time: startTime, handler: handler)
            if !repeatFlag {
                self?.stopTimer(identifier: timerName)
            }
        }
        
        // 设置取消事件处理
        if let cancelClosure = cancel{
            timer.timer.setCancelHandler {
                cancelClosure()
            }
        }
        // 启动定时器
        timer.statu = .resume
        timer.timer.resume()
        
    }
    
    // 取消定时器，idle/suspend状态下直接cancel会导致崩溃
    public func stopTimer(identifier: String){
        if let timer = self.timerContaier[identifier]{
            semaphore.wait()
            if timer.statu != .resume {
                timer.timer.resume()
            }
            timer.timer.cancel()
            self.timerContaier.removeValue(forKey: identifier)
            semaphore.signal()
        }
    }
    
    // 暂停定时器，resume状态下才需要暂停
    public func pauseTimer(identifier: String){
        if let timer = self.timerContaier[identifier], timer.statu == .resume{
            semaphore.wait()
            timer.runDuration += timer.interval/3
            timer.statu = .suspend
            timer.timer.suspend()
            semaphore.signal()
        }
    }
    
    // 恢复定时器，非resume状态才恢复
    public func resumeTimer(identifier: String){
        if let timer = self.timerContaier[identifier], timer.statu != .resume{
            semaphore.wait()
            timer.statu = .resume
            timer.timer.resume()
            semaphore.signal()
        }
    }
    
    public func clearTimers(){
        semaphore.wait()
        for (identifier, timer) in self.timerContaier{
            if timer.statu != .resume {
                timer.timer.resume()
            }
            timer.timer.cancel()
            self.timerContaier.removeValue(forKey: identifier)
        }
        semaphore.signal()
    }
    
    // 获取定时器运行时长
    public func runDuration(identifier: String) -> TimeInterval{
        if let timer = self.timerContaier[identifier]{
            return timer.runDuration + timer.interval/3
        }
        return 0
    }
    
    // 重置定时器运行时长
    public func resetRunDuration(identifier: String){
        if let timer = self.timerContaier[identifier]{
            timer.runDuration = 0
        }
    }
    // 是否已存在当前定时器
    public func hasTimer(identifier: String) -> Bool{
        if let _ = self.timerContaier[identifier]{
            return true
        }
        return false
    }
    
    // 时间格式化
    public func formateTime(time: TimeInterval, handler: TimerHandlerClosure?){
        
        let currentTime: TimeInterval = time < 0 ? 0 : time
        let totalSeconds = currentTime/1000.0;
        let days = Int(totalSeconds/60/60/24)
        let hours = Int(totalSeconds/60/60)%24
        let minutes = Int(totalSeconds/60)%60
        let seconds = Int(totalSeconds)%60
        let sss = Double(Int(currentTime)%1000)/10
        
        let dayStr = "\(days)"
        var hourStr = "\(hours)"
        var minuteStr = "\(minutes)"
        var secondStr = "\(seconds)"
        var ms = String(format: "%.1f", sss)
        
        if hours < 10 {
            hourStr = "0\(hours)"
        }
        
        if minutes < 10 {
            minuteStr = "0\(minutes)"
        }
        
        if seconds < 10 {
            secondStr = "0\(seconds)"
        }
        
        if Int(sss) < 10 {
            ms = "0\(ms)"
        }
        
        if let timerHandler = handler{
            DispatchQueue.main.async {
                timerHandler(dayStr, hourStr, minuteStr, secondStr, ms)
            }
        }
        
    }
    
}


