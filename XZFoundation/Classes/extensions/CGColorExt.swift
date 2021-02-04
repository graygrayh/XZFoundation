//
//  CGColorExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/6.
//  Copyright © 2020 xzh. All rights reserved.
//

#if canImport(CoreGraphics)
import CoreGraphics

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

public extension CGColor {
    
    #if canImport(UIKit)
    var uiColor: UIColor? {
        return UIColor(cgColor: self)
    }
    #endif
    
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    var nsColor: NSColor? {
        return NSColor(cgColor: self)
    }
    #endif
    
}

#endif
