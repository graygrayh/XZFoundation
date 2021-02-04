//
//  DateExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/10/9.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

extension Date: XZCompatible{}

public extension XZ where Base == Date{
    
    func toString(format: String="yyyy-MM-dd HH:mm:ss") -> String{
        let dateformatter = XZDateFormatterUtil.shared[format]
        dateformatter.dateFormat = format
        return dateformatter.string(from: self.base)
    }
    
    static var nowGMTString: String{
        let format = "EEE, dd MMM yyyy HH:mm:ss z"
        let dateformatter = XZDateFormatterUtil.shared[format]
        dateformatter.locale = Locale(identifier: "en_US")
        dateformatter.timeZone = TimeZone(abbreviation: "GMT")
        return dateformatter.string(from: Date())
    }
    
    var nowGMTString: String{
        let format = "EEE, dd MMM yyyy HH:mm:ss z"
        let dateformatter = XZDateFormatterUtil.shared[format]
        dateformatter.locale = Locale(identifier: "en_US")
        dateformatter.timeZone = TimeZone(abbreviation: "GMT")
        return dateformatter.string(from: self.base)
    }
    
    static func formatDataTime(totalSeconds: TimeInterval, format: String="yyyy年MM月dd日") -> String {
        let date = Date(timeIntervalSince1970: totalSeconds)
        return date.xz.toString(format: format)
    }
    
    // 计算日期相差天数，
    // 左边>=右边返回0，否则在减去当天不足24小时部分，再按24小时计算，
    func daysBetweenDate(toDate: Date) -> Int {
        if base.compare(toDate) == .orderedDescending {
            return 0
        }else{
            
            let components = Calendar.current.dateComponents([.hour], from: base, to: toDate)
            var days: Int = 0
            if let tempHours = components.hour, tempHours > 0 {
                let hours = Calendar.current.component(.hour, from: base)
                days = (tempHours + hours) / 24
            }
            return days
        }
    }
    
    func hoursBetweenDate(toDate: Date) -> Int{
        let components = Calendar.current.dateComponents([.hour], from: base, to: toDate)
        return components.hour ?? 0
    }
    
    func minutesBetweenDate(toDate: Date) -> Int{
        let components = Calendar.current.dateComponents([.minute], from: base, to: toDate)
        return components.minute ?? 0
    }
    
    func secondsBetweenDate(toDate: Date) -> Int{
        let components = Calendar.current.dateComponents([.second], from: base, to: toDate)
        return components.second ?? 0
    }
    
    
    
    
    // MARK: -
    static func minutesWithSeconds(_ totalSeconds: Int) -> Int {
        //let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600
        return hours * 60 + minutes
    }

    static func formatHMS(totalSeconds: Int) -> String {
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    static func formatHMSFull(totalSeconds: Int) -> String {
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600
        
        if hours > 0 {
            return String(format: "%02d时%02d分%02d秒", hours, minutes, seconds)
        }
        return String(format: "%02d分%02d秒", minutes, seconds)
    }

    
    ///当前微秒(15位)
    static var curMicroseconds: UInt64 {
        var info = mach_timebase_info()
        guard mach_timebase_info(&info) == KERN_SUCCESS else {
            return UInt64(abs(Date().timeIntervalSince1970*1000))
        }
        let currentTime = mach_absolute_time()
        let nanos = currentTime * UInt64(info.numer) / UInt64(info.denom)
        return nanos
    }
    
    ///当前毫秒(13位)
    static var curMilliseconds: Int64 {
        return Int64(abs(Date().timeIntervalSince1970*1000))
    }
    
    ///当前秒
    static var curSeconds: Int64 {
        return Int64(abs(Date().timeIntervalSince1970))
    }
    
}
