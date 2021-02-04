//
//  CommonUtil.swift
//  XZFoundation
//
//  Created by xzh on 2020/10/5.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

public func synchronized<T>(_ lock: AnyObject, _ closure: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    return try closure()
}

public enum XZCommonUtil {
    public static func generateRandomStr(digits: Int = 6) -> String{
        var val: String = ""
        for _ in 0..<digits {
            // 输出数字还是字母
            let charNumber: Int = Int(arc4random_uniform(2))
            if charNumber == 0{// 字母
                let choice = (Int(arc4random_uniform(2)) == 0 ? 65 : 97) + Int(arc4random_uniform(26))
                val += choice.xz.str
            }else{// 数字
                val += String(Int(arc4random_uniform(10)))
            }
        }
        return val
    }
}
