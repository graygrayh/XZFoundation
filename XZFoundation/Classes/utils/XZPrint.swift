//
//  LKPrintUtil.swift
//  XZFoundation
//
//  Created by xzh on 2020/8/26.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

public class XZPrint {
    private static let instance = XZPrint()
    public static var debugMode = false
    private init(){}
    
    public static func info<T>(message: T?, fileName: String = #file, methodName: String =  #function, lineNumber: Int = #line){
        #if DEBUG || ADHOC
        if debugMode {
            instance.printText(message: message, fileName: fileName, methodName: methodName, lineNumber: lineNumber, flag: "😊")
        }
        #endif
    }
    
    public static func success<T>(message: T?, fileName: String = #file, methodName: String =  #function, lineNumber: Int = #line){
        #if DEBUG || ADHOC
        if debugMode {
            instance.printText(message: message, fileName: fileName, methodName: methodName, lineNumber: lineNumber, flag: "✅")
        }
        #endif
    }
    
    public static func error<T>(message: T?, fileName: String = #file, methodName: String =  #function, lineNumber: Int = #line){
        #if DEBUG || ADHOC
        if debugMode {
            instance.printText(message: message, fileName: fileName, methodName: methodName, lineNumber: lineNumber, flag: "❌")
        }
        #endif
    }
    
    public static func warning<T>(message: T?, fileName: String = #file, methodName: String =  #function, lineNumber: Int = #line){
        #if DEBUG || ADHOC
        if debugMode {
            instance.printText(message: message, fileName: fileName, methodName: methodName, lineNumber: lineNumber, flag: "⚠️")
        }
        #endif
    }
    
    private func printText<T>(message: T?, fileName: String = #file, methodName: String =  #function, lineNumber: Int = #line, flag: String)
    {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.sss"
        let currentTimeStr = formatter.string(from: Date())
        
        var outStr : String = fileName
        if let lastComponent = fileName.components(separatedBy: "/").last {
            outStr = lastComponent.replacingOccurrences(of: "swift", with: "")
        }
        if let dict = message as? [String:Any], let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted), let jsonStr = String(data: data, encoding: .utf8){
            print("\(currentTimeStr) \(outStr)\(methodName)[\(lineNumber)]\(flag): \(jsonStr)")
        }else if let arr = message as? [Any], let data = try? JSONSerialization.data(withJSONObject: arr, options: .prettyPrinted), let jsonStr = String(data: data, encoding: .utf8){
            print("\(currentTimeStr) \(outStr)\(methodName)[\(lineNumber)]\(flag): \(jsonStr)")
        }else if let data = message as? Data, let jsonStr = String(data: data, encoding: .utf8){
            print("\(currentTimeStr) \(outStr)\(methodName)[\(lineNumber)]\(flag): \(jsonStr)")
        }else if let msg = message {
            print("\(currentTimeStr) \(outStr)\(methodName)[\(lineNumber)]\(flag): \(msg)")
        }else {
            print("\(currentTimeStr) \(outStr)\(methodName)[\(lineNumber)]\(flag): nil")
        }
        
    }
    
    private func printText<T>(messages:[T]){
        
    }
}
