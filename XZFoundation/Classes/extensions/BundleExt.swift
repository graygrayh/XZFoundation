//
//  BoundExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/10/9.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

public extension XZ where Base: Bundle {
    var id: String? {
        return self.base.bundleIdentifier
    }
    
    var idPrefix: String? {
        return self.base.infoDictionary?["AppIdentifierPrefix"] as? String
    }
    
    var name: String {
        return self.base.infoDictionary?["CFBundleName"] as! String
    }
    
    var versionNumber: String {
        return self.base.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    var buildNumber: String {
        return self.base.infoDictionary?["CFBundleVersion"] as! String
    }
    
    static var bundleID: String?{
        return Bundle.main.xz.id
    }
    
    static var appName: String {
        return Bundle.main.xz.name
    }
    
    static var appDisplayName: String {
        if let dis = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return dis
        }
        return Self.appName
    }
    
    static var appVersionNumber: String {
        return Bundle.main.xz.versionNumber
    }
    
    static var appBuildNumber: String {
        return Bundle.main.xz.buildNumber
    }
    
}


public extension XZ where Base: Bundle {
    
    static func bundleBy(bundleName: String?=nil, targetClass: AnyClass?=nil) -> Bundle {
        // 主工程bundle
        var bundle = Bundle.main
        
        //xib bundle
        if let targetCls = targetClass {// 一般xib这里就行
            bundle = Bundle(for: targetCls)
        }
        
        // 图片资源bundle
        if let tempBundleName = bundleName,
           let bundlePath = bundle.resourcePath?.appending("/\(tempBundleName).bundle"),
           let newBundle = Bundle(path: bundlePath) {
            return newBundle
        }
        return bundle
    }
}
