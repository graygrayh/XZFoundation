//
//  UIColorExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/5.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit

public extension UIColor{
    #if !os(watchOS)
    /// Create a UIColor with different colors for light and dark mode.
    ///
    /// - Parameters:
    ///     - light: Color to use in light/unspecified mode.
    ///     - dark: Color to use in dark mode.
    @available(iOS 13.0, tvOS 13.0, *)
    convenience init(light: UIColor, dark: UIColor) {
        self.init(dynamicProvider: { $0.userInterfaceStyle == .dark ? dark : light })
    }
    #endif
    
    /// Create a UIColor with hex
    ///
    ///     UIColor(hex: 0xcafe00)
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

public extension XZ where Base: UIColor {
    
    class func colorWith(hexString: String?) -> UIColor? {
        guard let hex = hexString else {
            return nil
        }
        var str = hex.xz.trimed
        str = str.replacingOccurrences(of: "0x", with: "")
        str = str.replacingOccurrences(of: "#", with: "")
        str = String(str.prefix(6))
        if let hexValue = UInt32(str, radix: 16) {
            return UIColor(hex: hexValue)
        }
        return nil
    }
    
    
    var hexString: String? {
        guard let components = base.cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = components[0]
        let g = components[1]
        let b = components[2]
        return  String(format: "%02X%02X%02X", (Int)(r * 255), (Int)(g * 255), (Int)(b * 255))
    }
    
    ///Inverted color
    func invert() -> UIColor {
        var red: CGFloat = 255.0
        var green: CGFloat = 255.0
        var blue: CGFloat = 255.0
        var alpha: CGFloat = 1.0
        
        base.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        red = 255.0 - (red * 255.0)
        green = 255.0 - (green * 255.0)
        blue = 255.0 - (blue * 255.0)
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
    
    static var random: UIColor {
        let max = CGFloat(UInt32.max)
        let red = CGFloat(arc4random()) / max
        let green = CGFloat(arc4random()) / max
        let blue = CGFloat(arc4random()) / max
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /// Create a 1x1 image with a solid color
    ///
    ///     button.setBackgroundImage(UIColor.red.imageValue, for: .normal)
    var imageValue: UIImage {
        let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(base.cgColor)
        context.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}

#endif
